#!/bin/bash
#Mail local+external FTP backup script
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

export MAILCOW_BACKUP_LOCATION="$localstorage/$date-$time"
/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup all
echo 'Finished dump'

# Delete mailcow-{date} directory, as when a backup is restored the directory can be generated again
# based upon the date/time information from the parent directories name
shopt -s dotglob
mv $localstorage/$date-$time/mailcow-*/* $localstorage/$date-$time
shopt -u dotglob
rm -R $localstorage/$date-$time/mailcow-*

sleep 3

ftpuser="EXTERNAL_FTP_USER"
export LFTP_PASSWORD="EXTERNAL_FTP_PASSWORD"
ftphost="EXTERNAL_FTP_HOSTNAME"
ftpport="EXTERNAL_FTP_PORT"
ftpexternalstorage="/FTP_PATH_TO_STORE_BACKUPS_EXTERNALLY"
ftpcertfingerprint="EXTERNAL_FTP_SSL_CERTIFICATE_FINGERPRINT_TO_TRUST"
echo 'Starting FTP upload'
lftp --env-password ftp://"$ftpuser"@"$ftphost" -p $ftpport \
     -e "set ftp:ssl-allow yes; set ssl:verify-certificate/$ftpcertfingerprint no; mirror -R -x .git --no-perms $localstorage/$date-$time $ftpexternalstorage/$date-$time ; quit"
echo 'Finished FTP upload'
unset LFTP_PASSWORD