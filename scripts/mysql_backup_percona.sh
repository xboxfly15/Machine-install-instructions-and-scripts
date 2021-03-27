#!/bin/sh
#Percona MySQL local+external FTP backup script
#Last update 2021/03/17
#Made by xboxfly15
now="$(date +%a_%d-%b-%Y)/$(date +%I%p-%Z)"
localstorage="PATH_TO_STORE_BACKUPS_LOCALLY"
mysqluser="MYSQL_USER"
mysqlpassword="MYSQL_PASSWORD"

mkdir -p $localstorage/$now
echo 'Created folder'

echo 'Starting dump'
databases=`mysql --user=$mysqluser -p"$mysqlpassword" -e "SHOW DATABASES;" | grep -Ev "(Database|phpmyadmin|information_schema)" | xargs`
xtrabackup --user=$mysqluser --password="$mysqlpassword" --backup --databases="$databases" --target-dir="$localstorage/$now"
echo 'Finished dump'

sleep 10

ftpuser="EXTERNAL_FTP_USER"
export LFTP_PASSWORD="EXTERNAL_FTP_PASSWORD"
ftphost="EXTERNAL_FTP_HOSTNAME"
ftpport="EXTERNAL_FTP_PORT"
ftpexternalstorage="/FTP_PATH_TO_STORE_BACKUPS_EXTERNALLY"
echo 'Starting FTP upload'
lftp --env-password ftp://"$ftpuser"@"$ftphost" -p $ftpport \
     -e "set ftp:ssl-allow no; mirror -R -x .git -p $localstorage/$now $ftpexternalstorage/$now ; quit"
echo 'Finished FTP upload'
unset LFTP_PASSWORD
# This script doesn't delete backups YET, as it's very important data and if FTP fails then very important could be lost
