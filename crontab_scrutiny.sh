#!/bin/sh

#Réalisez un script qui permet de surveiller les modifications du fichier /etc/crontab et 
#envoie un mail à root si celui-ci a été modifié. 
#Créez une tache plannifiée pour script tous les jours à minuit.

# Nom du fichier a surveiller
FILE=/etc/crontab1
# Date de la dernière modification du fichier ci-dessus
DERNIERE_MODIF=$(date -r ${FILE} '+%d/%m/%Y')
# Date de la veille
DATE_BKP=$(date --date='yesterday' '+%d/%m/%Y')
# Date du jour
DATE=$(date '+%d/%m/%Y')

# fichier du MD5 du fichier du jour
md5sum $FILE > /etc/CronDailyMd5
# Fichier du backup
FILE_BKP=/etc/crontab_bkp
echo "1"

if [ ! -f $FILE_BKP ]
then
	cp $FILE $FILE_BKP
	md5sum $FILE_BKP > CronBkpMd5
	echo "2"
	exit
elif [ CronDailyMd5 != CronBkpMd5 ]
then
	diff $FILE $FILE_BKP | egrep "<|>" > /etc/crontab.tmp
	mail -s "Alerte niveau 3,  modifications de $FILE, consulter le fichier /etc/crontab.tmp" root
	echo "3"
elif [ DERNIERE_MODIF==DATE_BKP || DERNIERE_MODIF==DATE ]
then
	mail -s "Alerte	niveau 2, modification de la date de $FILE depuis hier" root
	echo "4"
elif [ wc -c $FILE != wc -c $FILE_BKP ] 
then
	mail -s -c root "Arlete niveau 1, modification de la taille de $FILE depuis hier" root
	echo "5"
fi

cp $FILE $FILE_BKP
md5sum $FILE_BKP > /etc/CronBkpMd5
echo "6"
