#!/bin/sh
#MySQL local+external FTP backup script
#Last update 2019/04/13
#Made by xboxfly15
now="$(date +%a_%d-%b-%Y)/$(date +%I%p-%Z)"
localstorage="PATH_TO_STORE_BACKUPS_LOCALLY"
mysqluser="MYSQL_USER"
mysqlpassword="MYSQL_PASSWORD"

mkdir -p $localstorage/$now
echo 'Created folder, starting dump'

databases=`mysql --user=$mysqluser -p"$mysqlpassword" -e "SHOW DATABASES;" | grep -Ev "(Database|phpmyadmin|sys|information_schema|performance_schema)"`
for db in $databases; do
  echo "Starting dumping $db"
  mysqldump --user=$mysqluser -p"$mysqlpassword" --force --opt --databases $db | gzip > "$localstorage/$now/$db.gz"
  echo "Finished dumping $db"
done
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
