---
---
```bash
#!/bin/bash
#Minecraft Wings local+external FTP backup script
#Last update 2024/11/04
#Made by xboxfly15
set -u
date="$(date +%d.%m.%Y)"
time="$(date +%H_%Z)"
keepxdaysofbackups=5
localstorage="PATH_TO_STORE_BACKUPS_LOCALLY"

mkdir -p $localstorage/$date-$time
echo 'Created folder, deleting old backups'

[ -z "${localstorage:-}" ]
[ -z "${keepxdaysofbackups:-}" ]
[ -z "${date:-}" ]
[ -z "${time:-}" ]
find "$localstorage"/ -maxdepth 1 -type d -mmin +$((60*24*$keepxdaysofbackups)) | xargs rm -rf --preserve-root

echo 'Finished deleting old backups, starting dump'

cd /var/lib/pterodactyl/volumes

for i in *; do
  echo "Processing folder $i";
  [ -d "$i" ] && tar -cvpzf "$i.tar.gz" "$i"
  echo "SUCCESS! Created ${i%/}.tar.gz"
  mv $i.tar.gz $localstorage/$date-$time
  echo "SUCCESS! Moved ${i%/}.tar.gz"
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