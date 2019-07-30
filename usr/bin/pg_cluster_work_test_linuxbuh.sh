#!/bin/bash

status=`pg_lsclusters | grep -i down | awk '{printf $2"\n"}'`
server=`hostname`

if [ -n "$status" ]; then
echo "ВНИМАНИЕ! Базы $status на сервере $server НЕ РАБОТАЮТ!!! ПРИМИТЕ СРОЧНЫЕ МЕРЫ ИЛИ ГОТОВЬТЕ ВАЗЕЛИН :)" | mail -s "Ахтунг!!! Базы $status на сервере $server НЕ РАБОТАЮТ" $1
else
echo "Все базы работают"
fi


