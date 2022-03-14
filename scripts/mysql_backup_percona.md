---
---
```bash
#!/bin/bash
#Percona MySQL local+external FTP backup script
#Last update 2022/03/11
#Made by xboxfly15
now="$(date +%a_%d-%b-%Y)/$(date +%I%p-%Z)"
keepxdaysofbackups=5
localstorage="PATH_TO_STORE_BACKUPS_LOCALLY"
mysqluser="MYSQL_USER"
mysqlpassword="MYSQL_PASSWORD"

mkdir -p $localstorage/$now
echo 'Created folder, deleting old backups'

[ -z "${localstorage:-}" ]
[ -z "${keepxdaysofbackups:-}" ]
find "$localstorage"/ -maxdepth 1 -type d -mmin +$((60*24*("$keepxdaysofbackups"-1))) | xargs rm -rf --preserve-root

echo 'Finished deleting old backups, starting dump'

echo 'Starting dump'
databases=`mysql --user=$mysqluser -p"$mysqlpassword" -e "SHOW DATABASES;" | grep -Ev "(Database|phpmyadmin|information_schema)" | xargs`
xtrabackup --user=$mysqluser --password="$mysqlpassword" --backup --databases="$databases" --target-dir="$localstorage/$now"
echo 'Finished dump'

echo 'Zipping dump'
tar -zcvf "$localstorage/$now.gz" "$localstorage/$now" --remove-files
echo 'Zipped dump'

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
```
