#!/bin/sh

### Configuration ###
BACKUPDIR=/backup-dir
DATE=`date "+%y%m%d%H%M%S"`
DUMP="$(which pg_dump)"
PSQL="$(which psql)"
### End Configuration ###

## Prune old backups older than 3 days ####
find $BACKUPDIR/zabbixdb* -mtime +3 -delete 1>/dev/null 2>&1

#delete old data http://semonkey.com/2017-10-26-zabbix_purge.html
$PSQL -Uzabbix -dzabbix -c "delete FROM history where age(to_timestamp(history.clock)) > interval '15 days';" 1>/dev/null
$PSQL -Uzabbix -dzabbix -c "delete FROM history_uint where age(to_timestamp(history_uint.clock)) > interval '15 days';" 1>/dev/null
$PSQL -Uzabbix -dzabbix -c "delete FROM history_str where age(to_timestamp(history_str.clock)) > interval '15 days';" 1>/dev/null
$PSQL -Uzabbix -dzabbix -c "delete FROM history_text where age(to_timestamp(history_text.clock)) > interval '15 days';" 1>/dev/null
$PSQL -Uzabbix -dzabbix -c "delete FROM history_log where age(to_timestamp(history_log.clock)) > interval '15 days';" 1>/dev/null
$PSQL -Uzabbix -dzabbix -c "delete from history where itemid not in (select itemid from items where status='0');" 1>/dev/null
$PSQL -Uzabbix -dzabbix -c "delete from history_uint where itemid not in (select itemid from items where status='0');" 1>/dev/null
$PSQL -Uzabbix -dzabbix -c "delete from history_str where itemid not in (select itemid from items where status='0');" 1>/dev/null
$PSQL -Uzabbix -dzabbix -c "delete from history_text where itemid not in (select itemid from items where status='0');" 1>/dev/null
$PSQL -Uzabbix -dzabbix -c "delete from history_log where itemid not in (select itemid from items where status='0');" 1>/dev/null
$PSQL -Uzabbix -dzabbix -c "delete from trends where itemid not in (select itemid from items where status='0');" 1>/dev/null
$PSQL -Uzabbix -dzabbix -c "delete from trends_uint where itemid not in (select itemid from items where status='0');" 1>/dev/null

#dump
if $DUMP zabbix > $BACKUPDIR/zabbixdb$DATE --format=custom --compress=9 --username=zabbix --exclude-table-data=history* --exclude-table-data=trends* ; then
# if dump was sucessfull, touch the canary file to notify monitoring. You can send e-mail here or something like that instead.
touch $BACKUPDIR/DNBackupTestFile-zabbixdb
fi
