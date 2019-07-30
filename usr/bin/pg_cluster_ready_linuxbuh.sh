#!/bin/bash

status=`pg_isready -h $1 -p $2 | grep -i принимает | awk '{printf $4"\n"}'`
SERVER=`hostname`

if [ -n "$status" ]; then
echo "База работает"
else
echo "ВНИМАНИЕ! База $status на сервере $SERVER НЕ РАБОТАЕТ!!!"
fi


