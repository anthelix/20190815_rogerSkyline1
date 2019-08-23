#!/usr/bin/env bash

## Crontab monitoring
## To schedule the monitoring, add the following lines to /etc/crontab:
##      0 0 * * *  roger sh /home/roger/crontab_monitor.sh

backup='/home/roger/crontab.bak'
script='/home/roger/crontab_monitor.sh'

testsum="$(md5sum /etc/crontab | cut -d" " -f1)"

if [ -f $backup ]
then
	baksum="$(md5sum $backup | cut -d" " -f1)"
	if [ "$testsum" != "$baksum" ]
	then
		cat /etc/crontab | mail -s "Crontab: modification in the last 24 hours" root
		cp /etc/crontab $backup
	fi
else
	cp /etc/crontab $backup
fi
