Dva mysql servery s master-master replikací dat
===============================================


Postup instalace:

    echo -en "\nnet.ipv6.conf.default.autoconf = 0\nnet.ipv6.conf.all.autoconf = 0\nnet.ipv6.conf.eth0.autoconf = 0\n" >> /etc/sysctl.conf
    sed -i 's/http:\/\/ftp.sh.cvut.cz\/MIRRORS\//http:\/\/ftp.cz.debian.org\//'   /etc/apt/sources.list



    apt-get update
    apt-get dist-upgrade

    apt-get -y install ca-certificates apache2-mpm-itk libapache2-mod-php5 php-db php5-cli php5-common php5-mcrypt php5-mysql php5-suhosin php5-xcache mysql-server patch ufw sudo nagios-plugins-basic pwgen nagios-nrpe-server figlet openvpn wipe nagios-nrpe-server
    apt-get clean

    apt-get -y install wipe


    hostname -f | figlet -f smslant > /etc/motd.tail 
    echo >> /etc/motd.tail

    cp /etc/mysql/my.cnf /etc/mysql/my.cnf.dist
    edit /etc/mysql/my.cnf:


## Vytvoření PKI - klíčů a certů

Použijeme easy-rsa z openvpn (pracuje neinteraktivně).

    cp -a /usr/share/doc/openvpn/examples/easy-rsa/2.0 /root/easy-rsa

    echo "export KEY_SIZE=4096" >> /root/easy-rsa/vars

    echo "export KEY_COUNTRY=\"CZ\"" >> /root/easy-rsa/vars
    echo "export KEY_PROVINCE=\"Czech Republic\"" >> /root/easy-rsa/vars
    echo "export KEY_CITY=\"Prague\"" >> /root/easy-rsa/vars
    echo "export KEY_ORG=\"ORGANIZACE\"" >> /root/easy-rsa/vars
    echo "export KEY_EMAIL=\"admin@$domain\"" >> /root/easy-rsa/vars

    cd /root/easy-rsa
    . vars
    ./clean-all
     sed -i 's/--interact //' build-ca
     sed -i 's/--interact //' build-key-server

    h=`hostname -f`
    ./build-ca
    ./build-key-server $h


    cp /root/easy-rsa/keys/$h.key /etc/ssl/private 
    cp /root/easy-rsa/keys/$h.crt /etc/ssl/certs  
    cp /root/easy-rsa/keys/ca.crt /etc/ssl/certs/
    cp /root/easy-rsa/keys/ca.crt /var/www

    chown root:ssl-cert /etc/ssl/private/$h.key
    chmod 640 /etc/ssl/private/$h.key

    /etc/init.d/mysql restart

    echo "show variables like 'ssl%';" | mysql

## Kontrola nastavení mysqltunerem

Jelikož zatím nejsou přítomna data, tak zejména kontroluji, zda se mysql vejde do RAMky.

     wget -O /usr/local/sbin/mysqltuner.pl mysqltuner.pl
     chmod +x /usr/local/sbin/mysqltuner.pl
     /usr/local/sbin/mysqltuner.pl

## Vytvoření slave a propojení serverů


     ssh-keygen -N '' -f /root/.ssh/id_rsa

     #virtualmaster.rb image new db1.$domain --name "db.$domain" --public no
     #virtualmaster.rb server new --image "$domain" --ram 512M --hostname "db2.$domain"


- on db2

    hostname -f | figlet -f smslant > /etc/motd.tail ; echo >> /etc/motd.tail

    mv /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
    wipe /root/.ssh/id_rsa
    ssh-keygen -N '' -f /root/.ssh/id_rsa
    
    

- on db1
    scp db2:/root/.ssh/id_rsa.pub  /root/.ssh/authorized_keys
    
    echo "ip.add.re.ss db2.$domain" >> /etc/hosts
    test ssh


- na obou:

       sed -i 's/bind-address/#bind-address/' /etc/mysql/my.cnf

- on db2

    server-id = 2
    auto_increment_offset=2

    cd /root/easy-rsa
    . vars
    
    /build-key-server $h

    cp /root/easy-rsa/keys/$h.key /etc/ssl/private 
    cp /root/easy-rsa/keys/$h.crt /etc/ssl/certs  

    chown root:ssl-cert /etc/ssl/private/$h.key
    chmod 640 /etc/ssl/private/$h.key

     
- sync /etc/hosts
- restart mysqld on both
                                          

    wget -O - https://raw.github.com/phokz/mysql-master-master/master/setup_replication.sh | bash
    run setup_replication.sh on both nodes


## Změna root hesla a debian-sys-maint

      wget -O /usr/local/sbin/fix_mysql_passwords https://raw.github.com/phokz/mysql-master-master/master/fix_mysql_passwords
      chmod +x /usr/local/sbin/fix_mysql_passwords
      touch /etc/mysql/change_password
      /usr/local/sbin/fix_mysql_passwords

## apache2/mpm-itk + adminer + tls
    wget -O /var/www/adminer.php http://downloads.sourceforge.net/adminer/adminer-3.3.3.php
    a2ensite default-ssl
    a2enmod ssl

cd /etc/apache2/sites-available
(cat <<EOF
--- /etc/apache2/sites-available/default-ssl    2011-09-26 14:49:00.000000000 +0200
+++ /etc/apache2/sites-available/default-ssl    2011-09-26 14:48:37.000000000 +0200
@@ -42,6 +42,8 @@
        #   SSL Engine Switch:
        #   Enable/Disable SSL for this virtual host.
        SSLEngine on
+       SSLProtocol -ALL +SSLv3 +TLSv1
+       SSLCipherSuite ALL:!aNULL:!ADH:!DH:!EDH:!eNULL:!LOW:!EXP:RC4+RSA:+HIGH
 
        #   A self-signed (snakeoil) certificate can be created by installing
        #   the ssl-cert package. See
EOF
) | patch

  echo "zadej hostname pro ssl cert/klic"
  read h
  sed -i s/ssl-cert-snakeoil.pem/$h.crt/ /etc/apache2/sites-available/default-ssl
  sed -i s/ssl-cert-snakeoil.key/$h.key/ /etc/apache2/sites-available/default-ssl
  /etc/init.d/apache2 restart


## mysql limity


 sed -i "s/key_buffer\t\t= 16M/key_buffer\t\t= 4M/" /etc/mysql/my.cnf
 sed -i 's/#max_connections        = 100/max_connections        = 20/' /etc/mysql/my.cnf
 sed -i 's/query_cache_size        = 16M/query_cache_size        = 4M/' /etc/mysql/my.cnf

 /etc/init.d/mysql restart

 wget -O /usr/local/sbin/mysqltuner.pl mysqltuner.pl

 chmod +x /usr/local/sbin/mysqltuner.pl

 /usr/local/sbin/mysqltuner.pl


## php limity


  sed -i 's/memory_limit = 128M/memory_limit = 12M/' /etc/php5/apache2/php.ini
  sed -i 's/MaxClients          150/MaxClients          15/g' /etc/apache2/apache2.conf
  sed -i 's/KeepAliveTimeout 15/KeepAliveTimeout 4/' /etc/apache2/apache2.conf

  #suhosin
  sed -i 's/;suhosin.mail.protect = 0/suhosin.mail.protect = 1/' /etc/php5/conf.d/suhosin.ini
  sed -i 's/;suhosin.memory_limit = 0/suhosin.memory_limit = 12M/' /etc/php5/conf.d/suhosin.ini
  sed -i 's/;suhosin.executor.disable_eval = off/;suhosin.executor.disable_eval = on/' /etc/php5/conf.d/suhosin.ini


  /etc/init.d/apache2 restart

## lokální zálohování mysqldumpem

_provest jenom na db2_

   wget -O /etc/cron.daily/mysqldump_local_backup https://raw.github.com/phokz/mysql-master-master/master/mysqldump_local_backup
   chmod +x /etc/cron.daily/mysqldump_local_backup

## minimalni dohled

   apt-get -y install nagios-nrpe-server
   wget -O /etc/nagios/nrpe.cfg https://raw.github.com/phokz/mysql-master-master/master/nrpe.cfg
   /etc/init.d/nagios-nrpe-server restart

   dohled='nagios.virtualmaster.cz'
   dohled_ip=`ping $dohled -c 1 | grep from | cut -d '(' -f 2 | cut -d ')' -f1`

   ufw allow from $dohled_ip to any proto tcp port 5666

   . /etc/virtualmaster.cfg.disabled

   wget -O - https://raw.github.com/phokz/mysql-master-master/master/nagios.cfg | \
   sed -e s/_ip_/$virtualmaster_ipv4_address/ | \
   sed -e s/_hostname_/$virtualmaster_hostname/ | \
   sed -e s/_common_template_/common-$virtualmaster_hostname/ \
   > /root/nagios-$virtualmaster_hostname.cfg

- on e.g. vpnserver

   echo "ssh $virtualmaster_ipv4_address sudo cat /root/nagios-$virtualmaster_hostname.cfg | \\"
   echo "ssh $dohled sudo dd of=/etc/nagios/customers/$virtualmaster_hostname.cfg"


## firewall

Začneme s poměrně otevřeným firewallem, 80 a 443 bude open, 3306 bude open ze subnetu
a 22 bude open z nasich adres.

  sed -i s/IPV6=no/IPV6=yes/ /etc/default/ufw

  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw allow from 195.140.252.0/22 to any port 3306
  ufw allow from 2a01:430:d:0::/64 to any port 3306

  ufw allow from 195.140.252.0/22 to any port 22
  ufw allow from 80.79.29.0/24 to any port 22
  ufw allow from 2a01:430:d:0::/64 to any port 22
  ufw allow from 89.250.246.192/26 to any port 22

  ufw allow from 117.121.247.51/32 to any port 22
  ufw allow from 2403:cc00:5000:0:200:20ff:fe01:132/128 to any port 22


  ufw allow from 90.183.57.64/26 to any port 22
  ufw allow from 193.85.164.152/32 to any port 22

  
  ufw --force enable


