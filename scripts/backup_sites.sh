#!/bin/sh
#Virtualmin upload external FTP backup script
#Last update 2022/03/20
#Made by xboxfly15
now="$(date +%d-%b-%Y)/$(date +%I%p-%Z)"
keepxdaysofbackups=5
localstorage="PATH_TO_STORE_BACKUPS_LOCALLY"

echo 'Deleting old backups'

[ -z "${localstorage:-}" ]
[ -z "${keepxdaysofbackups:-}" ]
find "$localstorage"/ -maxdepth 1 -type d -mmin +$((60*24*$keepxdaysofbackups)) | xargs rm -rf --preserve-root

echo 'Finished deleting old backups'

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

