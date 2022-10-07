# zabbiz-http-logs-grep
Zabbiz template for monitoring http logs with grep

Add next string to zabbix agent config:
UserParameter=httpd_logs_monit[*],/etc/zabbix/scripts/httpd_logs_codes.sh $1 $2

Put script httpd_logs_codes.sh to /etc/zabbix/scripts/ dir