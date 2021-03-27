#!/bin/sh
#Mail local+external FTP backup script
#Last update 2019/07/20
#Made by xboxfly15
now="$(date +%a_%d-%b-%Y)/$(date +%I%p-%Z)"
localstorage="PATH_TO_STORE_BACKUPS_LOCALLY"

mkdir -p $localstorage/$now
echo 'Created folder, starting dump'

export MAILCOW_BACKUP_LOCATION="$localstorage/$now"
/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup all
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
