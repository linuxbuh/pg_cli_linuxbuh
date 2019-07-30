#!/bin/bash

source /etc/postgresql/pg_cli_linuxbuh.conf

BASE=$1
SERVER=$2
PORTBASE=$3


wal_backup_path="$POSTGRESQLPATH/$LOCALWALBASE/$BASE"
wal_backup_path_arhiv="$POSTGRESQLPATH/$LOCALWAL/$BASE"
wal_backup_path_backupserver="$SERVERBACKUPPATHWALBASE1/$BASE"
wal_backup_path_backupserver_arhiv="$SERVERBACKUPPATHWAL1/$BASE"

find $wal_backup_path -type f -mtime +2 -exec rm {} \;
find $wal_backup_path_arhiv -type f -mtime +2 -exec rm {} \;
find $wal_backup_path_backupserver -type f -mtime +7 -exec rm {} \;
find $wal_backup_path_backupserver_arhiv -type f -mtime +7 -exec rm {} \;

su postgres -c "mkdir -p /tmp/wal_backup_$BASE"
su postgres -c "pg_basebackup -h $SERVER -U postgres -D /tmp/wal_backup_$BASE -Ft -z -Xf -Pv --port=$PORTBASE"
cp /tmp/wal_backup_$BASE/base.tar.gz $wal_backup_path/$(date +%Y-%m-%d).tar.gz
cp /tmp/wal_backup_$BASE/base.tar.gz $wal_backup_path_backupserver/$(date +%Y-%m-%d).tar.gz
su postgres -c "cp $wal_backup_path_arhiv/* $wal_backup_path_backupserver_arhiv"
rm -Rf /tmp/wal_backup_$BASE
echo
echo "Архив базы $BASE создан"
echo