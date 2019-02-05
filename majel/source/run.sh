#!/bin/bash
source env/bin/activate
volttron -vv -l v.log > /dev/null 2>&1&
disown
sleep 2
./upgrade-control 
./upgrade-energyplus
./upgrade-listener 
tail -f v.log | grep "Topic: 'DMS/eventNotification'"
