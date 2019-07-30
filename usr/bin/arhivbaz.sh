#!/bin/sh

pg_dump -h 192.168.10.112 -p $2 -U postgres --format custom -b --section pre-data --section data --section post-data --verbose --file /tmp/$1.backup $1

#pg_restore -d $1 --clean -h 192.168.10.112 -p $2 -U postgres --section pre-data --section data --section post-data /tmp/$1.backup

#tar -cvzf /tmp/$1-$(date +%Y-%m-%d).backup.gz /tmp/$1.backup

rm /opt/arhiv/$1.backup

cp /tmp/$1.backup /opt/arhiv

#mv /tmp/$1-$(date +%Y-%m-%d).backup.gz /server/win/backupsql2/$1.day
cp /tmp/$1.backup /server/win/backupsql2/$1/$1-$(date +%Y-%m-%d).backup
#cp /tmp/$1.backup /server/win/backupsql2/$1

rm /tmp/$1.backup

#echo "Создан архив базы $1" | mail -v -s "Создан архив базы $1" tzaharchuk@sinikon.ru ddubenko@sinikon.ru