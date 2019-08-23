#!/bin/sh

# Nom du fichier a surveiller
FILE=/etc/crontab
# Date de la dernière modification du fichier ci-dessus
DERNIERE_MODIF=$(date -r ${FILE} '+%d/%m/%Y')
# Date de la veille
DATE_BKP=$(date --date='yesterday' '+%d/%m/%Y')
# Date du jour
DATE=$(date '+%d/%m/%Y')
# Fichier du Sha256sum du fichier du jour
sha256sum $FILE > /etc/CronDailySha
# Fichier du backup
FILE_BKP=/etc/crontab_bkp
# Poid du ficchier a surveiller
WC_FILE=$(stat --format "%s" /etc/crontab1)

if [ ! -f $FILE_BKP ] #un fichier n’existe  pas 
then
	cp $FILE $FILE_BKP
	md5sum $FILE_BKP > CronBkpMd5
	exit
else
	WC_BKP=$(stat --format "%s" /etc/crontab_bkp)
	if [ CronDailySha = CronBkpSha ]
	then
		diff $FILE $FILE_BKP | egrep "<|>" > /etc/crontab.tmp
		cat /etc/crontab | mail -s "Alerte niveau 3,  modifications de $FILE, consulter le fichier /etc/crontab.tmp" root
	elif [ $DERNIERE_MODIF = $DATE_BKP ] || [ $DERNIERE_MODIF = $DATE ]
	then
		cat /etc/crontab | mail -s "Alerte niveau 2, modification de la date de $FILE depuis hier" root
	elif [ $WC_FILE -ne $WC_BKP ] 
	then
		cat /etc/crontab mail | -s "Arlete niveau 1, modification de la taille de $FILE depuis hier" root
	fi
fi
cp $FILE $FILE_BKP
sha256sum $FILE_BKP > /etc/CronBkpSha
