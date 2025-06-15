#!/bin/bash
#Set date as parameter
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

#Stop mastodon server processes
    systemctl stop 'mastodon-*'

#Dump database to backup file
   su - mastodon -c "cd /home/mastodon/live && pg_dump -Fc mastodon_production > /backup/db/backup-$DATE.dump"

#Copy other files
    cp /home/mastodon/live/.env.production /backup/.env.production
    cp /var/lib/redis/dump.rdb /backup/db/redis_dump-$DATE.rdb
    cp -r -f /etc/nginx/sites-available/ /backup/sites-available/ --recursive

#Starting server processes
    systemctl start mastodon-streaming.service mastodon-web.service mastodon-sidekiq.service

#Use Gzip to compress the backup file.
    gzip /backup/db/backup-$DATE.dump

#Delete old backups
    find /backup/db -type f -name "*.gz" -mtime +7 -delete
    find /backup/db -type f -name "*.rdb" -mtime +7 -delete
