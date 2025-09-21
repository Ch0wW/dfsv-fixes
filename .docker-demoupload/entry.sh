#!/bin/sh

echo "Setup backup cron job with cron expression DEMO_FTPS_CRONTAB: ${DEMO_FTPS_CRONTAB}"
echo "${DEMO_FTPS_CRONTAB} /usr/bin/flock -n /var/run/backup.lock /bin/backup >> /var/log/cron.log 2>&1" > /var/spool/cron/crontabs/root