# Google Home Automation
Google Home (Assistant) Automation With Telldus

## Description
The script acts as a small web server, as a proxy between IFTTT and NetHomeServer. The applet (see Requirements) uses Google Assistant (Google Home) phrases as input. E.g "hey google, light off kitchen". The request is then sent by IFTTT to this server which parses the request and uses the NetHome REST API to invoke the given request. In this example, turn off the light in the kitchen. The light in NetHome is named "kitchen" in this case.

The script retrives all controls/lamps from the NetHome server and matches your spoken requests towards the list of available devices. With some fuzzy matching it acts on the best given match.

## Requirements
- NetHomeServer (http://opennethome.org/)
- IFTTT Account (https://ifttt.com) connected to your google account.
- IFTTT Applet: 

## Usage
Run the script on a server (I use an Raspberry PI 2). You can modify the "start.sh" script and make a cronjob for it in order to always make the script execute and restart if it fails.

    */1 * * * * /bin/bash /home/nergal/start.sh
