---
---
```bash
#!/bin/bash
#MySQL local+external FTP backup script
#Last update 2024/11/04
#Made by xboxfly15
set -u
date="$(date +%d.%m.%Y)"
time="$(date +%H_%Z)"
keepxdaysofbackups=5
localstorage="PATH_TO_STORE_BACKUPS_LOCALLY"
mysqluser="MYSQL_USER"
mysqlpassword="MYSQL_PASSWORD"

mkdir -p $localstorage/$date-$time
echo 'Created folder, deleting old backups'

[ -z "${localstorage:-}" ]
[ -z "${keepxdaysofbackups:-}" ]
[ -z "${date:-}" ]
[ -z "${time:-}" ]
find "$localstorage"/ -maxdepth 1 -type d -mmin +$((60*24*$keepxdaysofbackups)) | xargs rm -rf --preserve-root

echo 'Finished deleting old backups, starting dump'

databases=`mysql --user=$mysqluser -p"$mysqlpassword" -e "SHOW DATABASES;" | grep -Ev "(Database|phpmyadmin|sys|information_schema|performance_schema|mysql)"`
for db in $databases; do
  echo "Starting dumping $db"
  mysqldump --user=$mysqluser -p"$mysqlpassword" --force --opt --databases $db | gzip > "$localstorage/$date-$time/$db.gz"
  echo "Finished dumping $db"
done
echo 'Finished dump'

sleep 3

ftpuser="EXTERNAL_FTP_USER"
export LFTP_PASSWORD="EXTERNAL_FTP_PASSWORD"
ftphost="EXTERNAL_FTP_HOSTNAME"
ftpport="EXTERNAL_FTP_PORT"
ftpexternalstorage="/FTP_PATH_TO_STORE_BACKUPS_EXTERNALLY"
ftpcertfingerprint="EXTERNAL_FTP_SSL_CERTIFICATE_FINGERPRINT_TO_TRUST"
echo 'Starting FTP upload'
lftp --env-password ftp://"$ftpuser"@"$ftphost" -p $ftpport \
      -e "set ftp:ssl-allow yes; set ssl:verify-certificate/$ftpcertfingerprint no; mirror -R -x .git -p $localstorage/$date-$time $ftpexternalstorage/$date-$time ; quit"
echo 'Finished FTP upload'
unset LFTP_PASSWORD
```