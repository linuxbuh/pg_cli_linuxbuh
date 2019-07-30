#!/bin/bash

source /etc/postgresql/pg_cli_linuxbuh.conf

BASE=$1
SERVER=$2
PORT=$3
HOST=`hostname`

STATUS=`pg_lsclusters | grep -i down | awk '{printf $2"\n"}'`

if [ -n "$STATUS" ]; then
echo "ВНИМАНИЕ! Базы $STATUS на сервере $SERVER НЕ РАБОТАЮТ!!! ПРИМИТЕ СРОЧНЫЕ МЕРЫ :)"
else

systemctl stop postgresql@$POSTGRESQLVER-$BASE

rm -Rf $POSTGRESQLPATH/$BASE

su postgres -c "pg_basebackup -h $SERVER -p $PORT -U postgres -D $POSTGRESQLPATH/$BASE -R -P --xlog-method=stream"

rm -f $POSTGRESQLPATH/$BASE/recovery.conf

sleep 10

systemctl start postgresql@$POSTGRESQLVER-$BASE

sleep 10

systemctl restart postgresql@$POSTGRESQLVER-$BASE

pg_lsclusters | grep -i $BASE | awk 'NR > 1 {printf $2 "\t" $3 "\t" $4 "\t" "\n"}'
echo
echo "Зеркало базы $BASE создано на сервере $HOST"
echo