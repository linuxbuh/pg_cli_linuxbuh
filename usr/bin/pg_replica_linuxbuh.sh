#!/bin/bash

source /etc/postgresql/pg_cli_linuxbuh.conf

BASEOUT=$1
BASEIN=$2
SERVER=$3
PORT=$4


STATUS=`pg_isready -h $SERVER -p $PORT | grep -i принимает | awk '{printf $4"\n"}'`

if [ -n "$STATUS" ]; then

systemctl stop postgresql@$POSTGRESQLVER-$BASEIN

rm -Rf $POSTGRESQLPATH/$BASEIN

su postgres -c "pg_basebackup -h $SERVER -p $PORT -U postgres -D $POSTGRESQLPATH/$BASEIN -R -P --xlog-method=stream"

rm -f $POSTGRESQLPATH/$BASEIN/recovery.conf

sleep 10

systemctl start postgresql@$POSTGRESQLVER-$BASEIN

sleep 10

systemctl restart postgresql@$POSTGRESQLVER-$BASEIN

pg_lsclusters | grep -i $BASEIN | awk 'NR > 1 {printf $2 "\t" $3 "\t" $4 "\t" "\n"}'
echo
echo "Зеркало базы $BASEOUT создано в базе $BASEIN на сервере $HOSTNAME"
echo
else
echo "ВНИМАНИЕ! Базы $BASEOUT на сервере $SERVER НЕ РАБОТАЮТ!!! ПРИМИТЕ СРОЧНЫЕ МЕРЫ :)"
fi