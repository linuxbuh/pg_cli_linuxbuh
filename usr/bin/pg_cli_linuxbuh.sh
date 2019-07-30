#!/bin/bash

source /etc/postgresql/pg_cli_linuxbuh.conf

echo
echo -e "Восстановить базу, сделать зеркало или архив базы"
echo
PS3='Выберите: '
echo
select VIBOR in "Управление_базами" "Создать_зеркало" "Создать_архив" "Восстановить_базу"
do
    echo
    echo -e "Вы выбрали $VIBOR"
    echo
    break
done

if [[ -z "$VIBOR" ]];then
    echo
    echo "Вы не выбрали"
    echo
    exit 1
fi


if [ $VIBOR = "Создать_архив" ]; then
echo
echo "Список баз для архивации"
echo
pg_lsclusters | awk 'NR > 1 {printf $2 "\t" "\n"}'
echo
read -i "" -p "Введите название базы для архивации: " -e BASEBACKUP
echo
if [[ -z "$BASEBACKUP" ]];then
    echo
    echo "База не выбрана"
    echo
    exit 1
fi
echo
echo "Вы ввели $BASEBACKUP"
echo
read -i "" -p "Введите IP сервера с которого делать архив: " -e SERVERBACKUP
echo
if [[ -z "$SERVERBACKUP" ]];then
    echo
    echo "Сервер не выбран"
    echo
    exit 1
fi

echo
echo "Сервер $SERVERBACKUP"
echo
echo "Базы данных и их порты"
echo
pg_lsclusters | awk 'NR > 1 {printf $2 "\t" $3 "\t" "\n"}'
echo
read -i "" -p "Введите порт базы данных: " -e PORTBACKUP
echo
if [[ -z "$PORTBACKUP" ]];then
    echo
    echo "Порт не выбран"
    echo
    exit 1
fi


#PORTBACKUP=`pg_lsclusters | grep -i $BASEBACKUP | awk '{printf $3 "\t" "\n"}'`
echo
echo "Порт базы $PORTBACKUP"
echo
pg_wal_backup_linuxbuh.sh $BASEBACKUP $SERVERBACKUP $PORTBACKUP

fi

if [ $VIBOR = "Создать_зеркало" ]; then
echo
echo "Список баз для репликации"
echo
pg_lsclusters | awk 'NR > 1 {printf $2 "\t" "\n"}'
echo
read -i "" -p "Введите название базы для репликации: " -e BASEREPLIKA
echo
if [[ -z "$BASEREPLIKA" ]];then
    echo
    echo "База не выбрана"
    echo
    exit 1
fi
echo
echo "Вы ввели $BASEREPLIKA"
echo
read -i "" -p "Введите IP сервера с которого делать репликацию: " -e SERVERREPLIKA
echo
if [[ -z "$SERVERREPLIKA" ]];then
    echo
    echo "Сервер не выбран"
    echo
    exit 1
fi

#PORTREPLIKA=`pg_lsclusters | grep -i $BASEREPLIKA | awk '{printf $3 "\t" "\n"}'`
echo
echo "Базы данных и их порты"
echo
pg_lsclusters | awk 'NR > 1 {printf $2 "\t" $3 "\t" "\n"}'
echo
read -i "" -p "Введите порт базы данных: " -e PORTREPLIKA
echo
if [[ -z "$PORTREPLIKA" ]];then
    echo
    echo "Порт не выбран"
    echo
    exit 1
fi
echo
echo "Порт базы $PORTREPLIKA"
echo

pg_replica_linuxbuh.sh $BASEREPLIKA $SERVERREPLIKA $PORTREPLIKA

fi

if [ $VIBOR = "Восстановить_базу" ]; then
echo
echo -e "Восстановить базу"
echo
PS3='Выберите: '
echo
select VIBORVOSTANOVIT in "Восстановить_базу_из_локального_wal_архива" "Восстановить_базу_из_wal_архива_с_сервера_архивов"
do
    echo
    echo -e "Вы выбрали $VIBORVOSTANOVIT"
    echo
    break
done

if [[ -z "$VIBORVOSTANOVIT" ]];then
    echo
    echo "Вы не выбрали"
    echo
    exit 1
fi


if [ $VIBORVOSTANOVIT = "Восстановить_базу_из_локального_wal_архива" ]; then

ARHIVSPATH="$POSTGRESQLPATH/$LOCALWALBASE"
LSARHIVBASE1=`ls $ARHIVSPATH`
echo
echo "Список архивов с базами на сервере"
echo
echo $LSARHIVBASE1
echo

read -i "" -p "Введите название базы для восстановления: " -e BASE

if [[ -z "$BASE" ]];then
    echo
    echo "База не выбрана"
    echo
    exit 1
fi
echo
echo "Вы ввели $BASE"
echo
ARHIVPATH="$POSTGRESQLPATH/$LOCALWALBASE/$BASE"
ARHIVPATH0="$POSTGRESQLPATH/$LOCALWAL/$BASE"


LSARHIVPATHFILES=`ls $ARHIVPATH`
echo
echo "Список архивных файлов базы $BASE"
echo
echo $LSARHIVPATHFILES
echo
fi

if [ $VIBORVOSTANOVIT = "Восстановить_базу_из_wal_архива_с_сервера_архивов" ]; then 

ARHIVPATH="$SERVERBACKUPPATHWALBASE1/$BASE"
ARHIVPATH0="$SERVERBACKUPPATHWAL1/$BASE"

LSARHIVBASE=`ls $ARHIVPATH`
echo
echo "Список баз на архивном сервере"
echo
echo $LSARHIVBASE
echo
LSARHIVPATHFILES=`ls $ARHIVPATH`
echo
echo "Список архивных файлов базы $BASE"
echo
echo $LSARHIVPATHFILES
echo
fi


echo
read -i "" -p "Введите название файла базы для восстановления: " -e BASEFILE
echo
if [[ -z "$BASEFILE" ]];then
    echo
    echo "Файл базы не выбран"
    echo
    exit 1
fi
echo
echo "Вы выбрали $BASEFILE"
echo
read -i "" -p "Введите IP сервера базы для восстановления: " -e SERVER
echo
if [[ -z "$SERVER" ]];then
    echo
    echo "Сервер базы не выбран"
    echo
    exit 1
fi
echo
echo "Вы ввели $SERVER"
echo
PORT=`pg_lsclusters | grep -i $BASE | awk '{printf $3 "\t" "\n"}'`
echo
echo "Порт базы номер $PORT"
echo
echo
echo "Начинаем восстановление базы $BASE из архивного файла $BASEFILE"
echo
pg_ctlcluster $POSTGRESQLVER $BASE stop
rm -Rf $POSTGRESQLPATH/$BASE
su postgres -c "mkdir -m 0700 $POSTGRESQLPATH/$BASE"
su postgres -c "tar -xvf $ARHIVPATH/$BASEFILE -C $POSTGRESQLPATH/$BASE"
rm -Rf $POSTGRESQLPATH/$BASE/pg_xlog
su postgres -c "mkdir -m 0700 $POSTGRESQLPATH/$BASE/pg_xlog"
su postgres -c "cp $ARHIVPATH0/* $POSTGRESQLPATH/$BASE/pg_xlog"
echo "standby_mode = 'on'
primary_conninfo = 'user=postgres host=$SERVER port=$PORT sslmode=prefer sslcompression=1 krbsrvname=postgres'" >> $POSTGRESQLPATH/$BASE/pg_xlog/recovery.conf

pg_ctlcluster $POSTGRESQLVER $BASE start
echo
echo "Восстановление базы $BASE из архивного файла $BASEFILE завершено"
echo
BASEWORK=`pg_lsclusters | grep -i $BASE | awk '{printf $4}'`
echo
echo "База $BASE $BASEWORK"
echo

fi

#fi

if [ $VIBOR = "Управление_базами" ]; then
SERVERHOSTNAME=`hostname`
echo
echo -e "Управление базами"
echo
PS3='Выберите: '
echo
select VIBORUPRAV in "Статус_базы" "Запустить_базу" "Остановить_базу" "Перезапустить_базу" "Создать_базу" "Удалить_базу"
do
    echo
    echo -e "Вы выбрали $VIBORUPRAV"
    echo
    break
done

if [[ -z "$VIBORUPRAV" ]];then
    echo
    echo "Вы не выбрали"
    echo
    exit 1
fi

fi

if [ $VIBORUPRAV = "Статус_базы" ]; then

echo
echo "Список баз на сервере $SERVERHOSTNAME"
echo
pg_lsclusters | awk 'NR > 1 {printf $2 "\t" $3 "\t" "\n"}'
echo
read -i "" -p "Введите название базы: " -e STATUSBASENAME
echo
if [[ -z "$STATUSBASENAME" ]];then
    echo
    echo "База не выбрана"
    echo
    exit 1
fi
echo
echo "Для выхода нажмите Shift+Q"
echo
systemctl status postgresql@$POSTGRESQLVER-$STATUSBASENAME.service

fi

if [ $VIBORUPRAV = "Запустить_базу" ]; then

echo
echo "Список баз на сервере $SERVERHOSTNAME"
echo
pg_lsclusters | awk 'NR > 1 {printf $2 "\t" $3 "\t" "\n"}'
echo
read -i "" -p "Введите название базы: " -e STARTBASENAME
echo
if [[ -z "$STARTBASENAME" ]];then
    echo
    echo "База не выбрана"
    echo
    exit 1
fi

systemctl start postgresql@$POSTGRESQLVER-$STARTBASENAME.service
echo
echo "База $STARTBASENAME запущена"
echo
pg_lsclusters

fi

if [ $VIBORUPRAV = "Остановить_базу" ]; then

echo
echo "Список баз на сервере $SERVERHOSTNAME"
echo
pg_lsclusters | awk 'NR > 1 {printf $2 "\t" $3 "\t" "\n"}'
echo
read -i "" -p "Введите название базы: " -e STOPBASENAME
echo
if [[ -z "$STOPBASENAME" ]];then
    echo
    echo "База не выбрана"
    echo
    exit 1
fi

systemctl stop postgresql@$POSTGRESQLVER-$STOPBASENAME.service
echo
echo "База $STOPBASENAME остановлена"
echo
pg_lsclusters

fi

if [ $VIBORUPRAV = "Перезапустить_базу" ]; then

echo
echo "Список баз на сервере $SERVERHOSTNAME"
echo
pg_lsclusters | awk 'NR > 1 {printf $2 "\t" $3 "\t" "\n"}'
echo
read -i "" -p "Введите название базы: " -e RESTARTBASENAME
echo
if [[ -z "$RESTARTBASENAME" ]];then
    echo
    echo "База не выбрана"
    echo
    exit 1
fi

systemctl restart postgresql@$POSTGRESQLVER-$RESTARTBASENAME.service
echo
echo "База $RESTARTBASENAME перезапущена"
echo
pg_lsclusters
fi

if [ $VIBORUPRAV = "Создать_базу" ]; then

echo
echo "Список баз на сервере $SERVERHOSTNAME"
echo
pg_lsclusters | awk 'NR > 1 {printf $2 "\t" "\n"}'
echo
echo "ВНИМАНИЕ!!! Нельзя создавать базу с уже занятым именем. Имя базы должно содержать только латинские символы и цифры."
echo
read -i "" -p "Введите название создаваемой базы: " -e CREATEBASENAME1
echo
if [[ -z "$CREATEBASENAME1" ]];then
    echo
    echo "База не выбрана"
    echo
    exit 1
fi
#Заменяем - на _
CREATEBASENAME=${CREATEBASENAME1//-/_}
echo
echo "Вы ввели $CREATEBASENAME"
echo
echo
echo "Список занятых портов баз на сервере $SERVERHOSTNAME"
echo
pg_lsclusters | awk 'NR > 1 {printf $3 "\t" "\n"}'
echo
echo "ВНИМАНИЕ!!! Нельзя создавать базу с уже занятым портом (введите не занятый порт начинающийся с 54"
echo
read -i "" -p "Введите порт создаваемой базы: " -e CREATEPORT
echo
if [[ -z "$CREATEPORT" ]];then
    echo
    echo "Порт не выбран"
    echo
    exit 1
fi
echo
echo "Вы ввели $CREATEPORT"
echo
#Создаем кластер
su postgres -c "pg_createcluster $POSTGRESQLVER -p $CREATEPORT $CREATEBASENAME"
echo
echo "Создаем папки для бэкапа в локальном хранилище"
su postgres -c "mkdir -p $POSTGRESQLPATH/$LOCALWALBASE/$CREATEBASENAME"
su postgres -c "mkdir -p $POSTGRESQLPATH/$LOCALWAL/$CREATEBASENAME"
echo "Создаем папки для бэкапа на сервере для бэкапов"
su postgres -c "mkdir -p $SERVERBACKUPPATHWALBASE1/$CREATEBASENAME"
su postgres -c "mkdir -p $SERVERBACKUPPATHWAL1/$CREATEBASENAME"
echo "Копируем конфигурационные файлы Postgres"
su postgres -c "cp -R /usr/share/postgresql/$POSTGRESQLVER/postgresql.example.conf /etc/postgresql/$POSTGRESQLVER/$CREATEBASENAME/postgresql.conf"
su postgres -c "cp -R /usr/share/postgresql/$POSTGRESQLVER/pg_hba.example.conf /etc/postgresql/$POSTGRESQLVER/$CREATEBASENAME/pg_hba.conf"
echo "Заменяем имя базы данных в файле postgresql.conf"
su postgres -c "grep '$SEDCREATEBASENAME' -P -R -I -l /etc/postgresql/$POSTGRESQLVER/$CREATEBASENAME/postgresql.conf | xargs sed -i 's/$SEDCREATEBASENAME/$CREATEBASENAME/g'"
echo "Заменяем порт базы данных в файле postgresql.conf"
su postgres -c "grep '$SEDCREATEBASEPORT' -P -R -I -l /etc/postgresql/$POSTGRESQLVER/$CREATEBASENAME/postgresql.conf | xargs sed -i 's/$SEDCREATEBASEPORT/$CREATEPORT/g'"
echo
echo "Запускаем кластер"
systemctl start postgresql@$POSTGRESQLVER-$CREATEBASENAME
echo "Список кластеров"
pg_lsclusters
echo
echo "База $CREATEBASENAME создана"
echo

fi

if [ $VIBORUPRAV = "Удалить_базу" ]; then

echo
echo "Список баз на сервере $SERVERHOSTNAME"
echo
pg_lsclusters | awk 'NR > 1 {printf $2 "\t" "\n"}'
echo
echo "ВНИМАНИЕ!!! База будет уничтожена безвозвратно. Её можно будет восстановить только из архивов"
echo
read -i "" -p "Введите название удаляемой базы: " -e DROPBASENAME
echo
if [[ -z "$DROPBASENAME" ]];then
    echo
    echo "База не выбрана"
    echo
    exit 1
fi
echo
echo "Вы удаляете базу данных $DROPBASENAME"
echo
systemctl stop postgresql@$POSTGRESQLVER-$DROPBASENAME
su postgres -c "pg_dropcluster $POSTGRESQLVER $DROPBASENAME"
echo
echo
pg_lsclusters
echo
echo "База $DROPBASENAME удалена"
echo
echo
echo -e "Удалить архивы базы данных $DROPBASENAME"
echo
PS3='Выберите: '
echo
select DROPARHIV in "Да" "Нет"
do
    echo
    echo -e "Вы выбрали $DROPARHIV"
    echo
    break
done

if [[ -z "$DROPARHIV" ]];then
    echo
    echo "Вы не выбрали"
    echo
    exit 1
fi

if [ $DROPARHIV = "Да" ]; then
rm -fR $POSTGRESQLPATH/$LOCALWALBASE/$DROPBASENAME
rm -fR $POSTGRESQLPATH/$LOCALWAL/$DROPBASENAME
rm -fR $SERVERBACKUPPATHWALBASE1/$DROPBASENAME
rm -fR $SERVERBACKUPPATHWAL1/$DROPBASENAME
echo
echo "Урхивы базы данных $DROPBASENAME удалены"
echo
fi

if [ $DROPARHIV = "Нет" ]; then
echo
echo "Урхивы базы данных $DROPBASENAME не удалены"
echo
fi

fi

