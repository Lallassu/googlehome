#!/bin/bash
# Cronjob:
#  */1 * * * * /bin/bash /path/to/start.sh
RUN="/usr/bin/screen -dmS ghome_server ruby /path/to/ghome_server.rb"
CHECK=`ps axuf|grep -i "ghome_server.rb" |grep -v grep`
if [ $? == 1 ]; then
  eval $RUN &
fi
