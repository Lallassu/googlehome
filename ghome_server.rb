###############################################################
# Date: 2017-11-13
# Author: Magnus Persson
# Description: Act as a server between IFTTT and NetHome in
# order to control telldus(lights etc.) with Google Home.
# Use together with my NetHome Applet from IFTTT..
# Works in this way:
#  1. Say to Google home <keyword> <action> <device>
#     e.g "hey google, light on kitchen"
#     where "light" is the keyword, "on" is the action and
#     "kitchen" is the device.
#  2. Applet sends a post request to this script
#  3. The script parses the request and compared the action
#     towards the name of the devices. Best match is chosen.
#  3. The script performs a REST request to the NetHome REST API
#     to on/off/toggle the light.
###############################################################
require 'awesome_print'
require 'net/http/server'
require 'fuzzy_match'
require 'httparty'

###############################################################
#
#  CONFIGURATION
#
###############################################################
# Port to listen for commands on
$port = 8080

# IP to listen on (default all)
$ip = "0.0.0.0"

# Net Home Server settings
# http://opennethome.org/
$net_home_domain_path = "example.com"
$net_home_protocol = "http"
$net_home_username = "username"
$net_home_password = "password"
###############################################################
# End of configuration
###############################################################
#
class NetHome
  include HTTParty

  def initialize
      @auth = {:username => $net_home_username, :password => $net_home_password}
      self.class.base_uri "#{$net_home_protocol}://#{$net_home_domain_path}"
  end

  # Get all controls from NetHomeServer (categories Lamps & Controls)
  # which fetches both lamps and controls for multiple lights.
  def getControls
      controls = {}
      response = self.class.get("/rest/items",:basic_auth => @auth)
      JSON.parse(response.body).each do |r|
          if r["category"] == "Controls" || r["category"] == "Lamps"
              controls[r["id"]] = r["name"]
          end
      end
      return controls
  end

  # Perform a post request to NetHomeServer and invokes the given action.
  def action(id, type)
    res = self.class.post("/rest/items/#{id}/actions/#{type}/invoke",  :headers => {"Content-Type" => "application/json"}, :basic_auth => @auth)
    return res.parsed_response["attributes"][0]["value"]
  end
end

# Start a simple web-server
Net::HTTP::Server.run(:port => 8080) do |request,stream|
    # IFTTT sends the content-length with lowercase while
    # curl sends it with case.
    if request[:headers]["content-length"]
        size = request[:headers]["content-length"].to_i
    else
        size = request[:headers]["Content-Length"].to_i
    end
    data = stream.read(size)
    stream.close

    # Get body
    data.gsub!(/.*\r\n/, "")
    data.downcase!

    # Get device and what action  (<device> <action>)
    device = data.sub(/(.*).*\s.*/, '\1').downcase
    action = data.gsub(/.*\s/, "").downcase

    # Check if reversed (<action> <device>)
    if device.include?("on") || device.include?("toggle") || device.include?("off") 
        action = data.sub(/\s.*$/, '')
        device = data.sub("#{action} ", '')
    end

    ap "Device: #{device} Action: #{action}"

    # Get all controls configured in NetHomeServer
    net = NetHome.new
    controls = net.getControls

    # Fuzzy check for device name
    all_devices = []
    controls.each do |id, name|
        all_devices.push(name)
    end
    match = FuzzyMatch.new(all_devices).find(device)

    controls.each do |id, name|
        if match.downcase == name.downcase
            res = ""
            if(action.include?("on")) 
                res = net.action(id, "on")
            elsif(action.include?("toggle"))
                res = net.action(id, "toggle")
            elsif(action.include?("off"))
                res = net.action(id, "off")
            end
            ap "Action: #{id} (#{name}) => Request: #{action}, Result: #{res}"
        end
    end
    [200, {'Content-Type' => 'text/html'}, ["OK"]]
end
