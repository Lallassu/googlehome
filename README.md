# Google Home Automation
Google Home (Assistant) Automation with NetHome server. Can be used to control telldus etc with voice commands.

## Description
The script acts as a small web server, as a proxy between IFTTT and NetHomeServer. The applet (see Requirements) uses Google Assistant (Google Home) phrases as input. E.g "hey google, light off kitchen". The request is then sent by IFTTT to this server which parses the request and uses the NetHome REST API to invoke the given request. In this example, turn off the light in the kitchen. The light in NetHome is named "kitchen" in this case.

The script retrives all controls/lamps from the NetHome server and matches your spoken requests towards the list of available devices. With some fuzzy matching it acts on the best given match.

## Requirements
- NetHomeServer (http://opennethome.org/)
- IFTTT Account (https://ifttt.com) connected to your google account.
- IFTTT Maker account: https://platform.ifttt.com/maker (Free to use)
- IFTTT Applet: (As the screenshot below, which is created in the "maker" dashboard)

Note that the applet is not possible to publish as public since it uses the webhook service.

## Usage
First modify the scripts configure-section for your values of choice. And install required Ruby gems
    gem install awesome_print
    gem install net-http-server
    gem install fuzzy_match
    gem install httparty
Test if the script can execute:
    ruby ghome_server.rb
(Should output nothing, just starts to listen)
    
1. Run the script on a server (I use an Raspberry PI 2). You can modify the "start.sh" script and make a cronjob for it in order to always make the script execute and restart if it fails.

    */1 * * * * /bin/bash /path/to/start.sh

2. Create an IFTTT applet like the screenshot shows. The only required change is the URL.
<p align="center">
  <img src="https://github.com/Lallassu/googlehome/blob/master/ifttt_applet_howto.png" width="350"/>
</p>

3. Hey google, light off bedroom!
