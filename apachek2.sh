#!/bin/bash

p80=$(ss -ltn | grep :80 | awk '{print $1}')
fe=$(ls /var/www/html/index.html)

p80r=LISTEN
fer=/var/www/html/index.html

if [ "$p80" = "$p80r" ]; then echo 'port 80 is open';
else echo 'check failed, port 80 is not open'; exit 1;
fi
if [ "$fe" = "$fer" ]; then echo 'file index.html exists';
else echo 'check failed, file index.html does not exist'; exit 1;
fi