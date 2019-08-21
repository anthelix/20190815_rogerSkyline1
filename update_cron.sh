#!/bin/sh

#----------------
# VARIABLES
#----------------
OUTPUT="/var/log/update_script.log"
TIME="Info.$(date +'%d-%m-%Y')"
#----------------

# FUNCTION
#----------------

print_title()
{
    echo "">>$OUTPUT
    echo "------------------------------------------" >>$OUTPUT
    echo "\033[35;1m   $TIME\033[0m" >> $OUTPUT
    echo "------------------------------------------" >>$OUTPUT
}

check_root()
{
    local meid=$(id -u)
    if [ $meid -ne 0 ]
    then
    echo "Be root to use the script"
    exit 999
    fi
}
check_update()
{
	apt-get -y update && apt-get -y upgrade >>  $OUTPUT
	
}


check_root
print_title
check_update


#Réalisez un script qui met à jour l’ensemble des sources de package
#puis de vos packages et 
#qui log l’ensemble dans un fichier nommé /var/log/update_script.log.
# Créez une tache planifiée pour ce script une fois par semaine à 4h00 du matin et à chaque reboot de la machine.