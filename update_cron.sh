#!/bin/sh

OUTPUT="/var/log/update_script.log"
TIME="Info du $(date +'%d-%m-%Y %H:%M:%S')"

print_title()
{
    echo "">>$OUTPUT
    echo "------------------------------------------" >>$OUTPUT
    echo "\033[35;1m   $TIME\033[0m" >>$OUTPUT
    echo "------------------------------------------" >>$OUTPUT
}

check_update()
{
	apt-get -y update 2>&1 && apt-get -y upgrade 2>&1 >>$OUTPUT
}

print_title
check_update
