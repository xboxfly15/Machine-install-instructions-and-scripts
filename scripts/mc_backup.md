---
---
```bash
#!/bin/bash
#Minecraft Multicraft local+external FTP backup script
#Last update 2022/03/14
#Made by xboxfly15
now="$(date +%a_%d-%b-%Y)/$(date +%I%p-%Z)"
keepxdaysofbackups=5
localstorage="PATH_TO_STORE_BACKUPS_LOCALLY"

mkdir -p $localstorage/$now
echo 'Created folder, deleting old backups'

[ -z "${localstorage:-}" ]
[ -z "${keepxdaysofbackups:-}" ]
find "$localstorage"/ -maxdepth 1 -type d -mmin +$((60*24*("$keepxdaysofbackups"-1))) | xargs rm -rf --preserve-root

echo 'Finished deleting old backups, starting dump'

cd /home/minecraft/multicraft/servers

for i in *; do
  echo "Processing folder $i";
  [ -d "$i" ] && tar -cvpzf "$i.tar.gz" "$i"
  echo "SUCCESS! Created ${i%/}.tar.gz"
  mv $i.tar.gz $localstorage/$now
  echo "SUCCESS! Moved ${i%/}.tar.gz"
done
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
