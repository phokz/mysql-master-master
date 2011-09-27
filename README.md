Dva mysql servery s master-master replikací dat
===============================================


Postup instalace:

    echo -en "\nnet.ipv6.conf.default.autoconf = 0\nnet.ipv6.conf.all.autoconf = 0\nnet.ipv6.conf.eth0.autoconf = 0\n" >> /etc/sysctl.conf
    sed -i 's/http:\/\/ftp.sh.cvut.cz\/MIRRORS\//http:\/\/ftp.cz.debian.org\//'   /etc/apt/sources.list



    apt-get update
    apt-get dist-upgrade

    apt-get -y install ca-certificates apache2-mpm-itk libapache2-mod-php5 php-db php5-cli php5-common php5-mcrypt php5-mysql php5-suhosin php5-xcache mysql-server patch ufw sudo nagios-plugins-basic pwgen nagios-nrpe-server figlet openvpn
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
    echo "export KEY_ORG=\"Artycok.TV\"" >> /root/easy-rsa/vars
    echo "export KEY_EMAIL=\"admin@artycok.tv\"" >> /root/easy-rsa/vars

    cd /root/easy-rsa
    . vars
    ./clean-all
     sed -i 's/--interact //' build-ca
     sed -i 's/--interact //' build-key-server
     
    ./build-ca
    ./build-key-server `hostname -f`

    cp /root/easy-rsa/keys/db1.artycok.tv.key /etc/ssl/private 
    cp /root/easy-rsa/keys/db1.artycok.tv.crt /etc/ssl/certs  
    cp /root/easy-rsa/keys/ca.crt /etc/ssl/certs/

    /etc/init.d/mysql restart
    echo "show variables like 'ssl%';" | mysql

## Kontrola nastavení mysqltunerem

Jelikož zatím nejsou přítomna data, tak zejména kontroluji, zda se mysql vejde do RAMky.

     wget -O /usr/local/sbin/mysqltuner.pl mysqltuner.pl
     chmod +x /usr/local/sbin/mysqltuner.pl
     /usr/local/sbin/mysqltuner.pl

## Vytvoření slave a propojení serverů


     ssh-keygen -N '' -f /root/.ssh/id_rsa

     virtualmaster.rb image new db1.artycok.tv --name "db.artycok.tv" --public no
     virtualmaster.rb server new --image "db.artycok.tv" --ram 512M


- on db2

    hostname -f | figlet -f smslant > /etc/motd.tail ; echo >> /etc/motd.tail

    mv /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
    wipe /root/.ssh/id_rsa
    ssh-keygen -N '' -f /root/.ssh/id_rsa
    
copy /root/.ssh/id_rsa.pub on db1-authorized_keys

- on db1

    echo "195.140.253.114 db2.artycok.tv" >> /etc/hosts
    test ssh


- na obou:

       sed -i 's/bind-address/#bind-address/' /etc/mysql/my.cnf

- on db2

    server-id = 2
    auto_increment_offset=2

    cd /root/easy-rsa
    . vars
    
    /build-key-server `hostname -f`

    cp /root/easy-rsa/keys/`hostname -f`.key /etc/ssl/private 
    cp /root/easy-rsa/keys/`hostname -f`.crt /etc/ssl/certs  
     
- sync /etc/hosts
- restart mysqld on both
                                          


    run setup_replication.sh on both nodes

