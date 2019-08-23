#!/usr/bin/env bash

##
## Packages upgrade script initialisation
## To schedule the upgrade, add the following lines to /etc/crontab:
##      @reboot root sh /home/roger/package_upgrade.sh
##      0 4 * * 0 root sh /home/roger/package_upgrade.sh
##

log_file='/var/log/update_script.log'

apt-get update >> $log_file 2>&1 && apt-get upgrade -y >> $log_file 2>&1
