---
---
```bash
#!/bin/bash
#Percona MySQL local+external FTP backup script
#Last update 2022/03/17
#Made by xboxfly15
date="$(date +%a_%d-%b-%Y)"
time="$(date +%I%p-%Z)"
keepxdaysofbackups=5
localstorage="PATH_TO_STORE_BACKUPS_LOCALLY"
mysqluser="MYSQL_USER"
mysqlpassword="MYSQL_PASSWORD"

mkdir -p $localstorage/$date/$time
echo 'Created folder, deleting old backups'

[ -z "${localstorage:-}" ]
[ -z "${keepxdaysofbackups:-}" ]
find "$localstorage"/ -maxdepth 1 -type d -mmin +$((60*24*"$keepxdaysofbackups")) | xargs rm -rf --preserve-root

echo 'Finished deleting old backups, starting dump'

echo 'Starting dump'
databases=`mysql --user=$mysqluser -p"$mysqlpassword" -e "SHOW DATABASES;" | grep -Ev "(Database|phpmyadmin|information_schema)" | xargs`
xtrabackup --user=$mysqluser --password="$mysqlpassword" --backup --databases="$databases" --target-dir="$localstorage/$date/$time"
echo 'Finished dump'

echo 'Zipping dump'
tar -zcvf "$localstorage/$date/$time.gz" "$localstorage/$date/$time" --remove-files
echo 'Zipped dump'

sleep 10

ftpuser="EXTERNAL_FTP_USER"
export LFTP_PASSWORD="EXTERNAL_FTP_PASSWORD"
ftphost="EXTERNAL_FTP_HOSTNAME"
ftpport="EXTERNAL_FTP_PORT"
ftpexternalstorage="/FTP_PATH_TO_STORE_BACKUPS_EXTERNALLY"
echo 'Starting FTP upload'
lftp --env-password ftp://"$ftpuser"@"$ftphost" -p $ftpport \
     -e "set ftp:ssl-allow no; mkdir $ftpexternalstorage/$date; put -O $ftpexternalstorage/$date $localstorage/$date/$time.gz; quit"
echo 'Finished FTP upload'
unset LFTP_PASSWORD
```
