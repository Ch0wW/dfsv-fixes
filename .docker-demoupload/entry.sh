#!/bin/sh

echo "Setup backup cron job with cron expression DEMO_FTPS_CRONTAB: ${DEMO_SFTP_CRONTAB}"
echo "${DEMO_SFTP_CRONTAB} /usr/bin/flock -n /var/run/backup.lock /bin/backup >> /var/log/cron.log 2>&1" > /var/spool/cron/crontabs/root

# Make sure the file exists before we start tail
touch /var/log/cron.log

# start the cron deamon
crond

exec "$@"