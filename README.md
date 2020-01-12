# zabbix-backup
Zabbix PGSQL backup script without history

History tables can occupy gigabytes and in order to do just configuration backup, are not necessary.

This backup script combines deleting history data (you can turn off housekeeper for history).
Also, history tables are not backed up.
