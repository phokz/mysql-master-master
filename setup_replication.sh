
master_status=`echo show master status | mysql --column-names=false`
master_file=`echo $master_status | awk '{print $1}'`
master_pos=`echo $master_status | awk '{print $2}'`

myhostn=`hostname -f`
hostn=`hostname -s | sed -e s/^db//`
hostn="db"$((3-$hostn))

ipaddr=`cat /etc/hosts | grep $hostn | grep -v : | awk '{print $1}'`

heslo=`pwgen -s 20`
grant="GRANT REPLICATION SLAVE ON *.* TO 'repl-$hostn'@'$ipaddr' IDENTIFIED BY '$heslo';"
change="change master to MASTER_HOST='$myhostn', MASTER_USER='repl-$hostn', master_password='$heslo',  MASTER_SSL=1, MASTER_SSL_CA = '/etc/ssl/certs/ca.crt', MASTER_LOG_FILE='$master_file', MASTER_LOG_POS=$master_pos;"

echo "$grant" | mysql

echo "$change" | ssh $hostn mysql
echo "start slave" | ssh $hostn mysql
