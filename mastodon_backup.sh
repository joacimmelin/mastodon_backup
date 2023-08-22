#!/bin/bash
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
#Stopping mastodon processes
    systemctl stop 'mastodon-*'

#Generating a database dump backup
    su - mastodon -c "cd /home/mastodon/live && pg_dump -Fc mastodon_production > backup.dump"

#Moving the database backup
    mv /home/mastodon/live/backup.dump /backup/db/backup-$DATE.dump
#Copying important files
    cp /home/mastodon/live/.env.production /backup/.env.production
    cp /var/lib/redis/dump.rdb /backup/db/redis_dump-$DATE.rdb
    cp -r -f -v /etc/nginx/sites-available/ /backup/sites-available/ --recursive

#Starting the mastodon processes
    systemctl start 'mastodon-*'
gzip /backup/db/backup-$DATE.dump
find /backup/db -type f -name "*.gz" -mtime +7 -delete
find /backup/db -type f -name "*.rdb" -mtime +7 -delete
