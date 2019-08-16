#!/bin/bash

DATE=`date +%Y-%m-%d`
SERVER=$1
BASE=$2
ADMIN=$3
PASSWORD=$4
DTPATH=/home/guest/$BASE-$DATE.dt
LOGPATH=/tmp/1cctreatedt.log
# если с паролем 12345
#/opt/1C/v8.3/x86_64/1cv8  CONFIG /S"1cserver-test\ohtruda-pg" /N"Администратор" /P"rfnztdfrfpzdrb" /Out"/home/guest/1c.log" /DumpIB"/home/guest/ohtruda-pg_"$DATE".dt"
#/opt/1C/v8.3/x86_64/1cv8  CONFIG /S"$SERVER\\$BASE" /N"$ADMIN" /P"$PASSWORD" /Out"$LOGPATH" /DumpIB"$DTPATH"
#/opt/1C/v8.3/x86_64/1cv8 ENTERPRISE /S"$SERVER\\$BASE" /N"$ADMIN" /P"$PASSWORD" /DisableStartupMessages /C"ЗавершитьРаботуПользователей"
/opt/1C/v8.3/x86_64/1cv8 ENTERPRISE /S"$SERVER\\$BASE" /N"$ADMIN" /P"$PASSWORD" /DisableStartupMessages /C"РазрешитьРаботуПользователей" /UC"КодРазрешения"
# если без пароля
#/opt/1C/v8.3/x86_64/./1cv8  CONFIG /S"xp962_1\demo" /N"admin" /Out"/home/user/1c.log" /DumpIB"/home/user/buh_"$DATE".dt"