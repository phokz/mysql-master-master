Dva mysql servery s master-master replikací dat
===============================================


Postup instalace:

    echo -en "\nnet.ipv6.conf.default.autoconf = 0\nnet.ipv6.conf.all.autoconf = 0\nnet.ipv6.conf.eth0.autoconf = 0\n" >> /etc/sysctl.conf
    sed -i 's/http:\/\/ftp.sh.cvut.cz\/MIRRORS\//http:\/\/ftp.cz.debian.org\//'   /etc/apt/sources.list



    apt-get update
    apt-get dist-upgrade

    apt-get -y install ca-certificates apache2-mpm-itk libapache2-mod-php5 php-db php5-cli php5-common php5-mcrypt php5-mysql php5-suhosin php5-xcache mysql-server patch ufw sudo nagios-plugins-basic pwgen nagios-nrpe-server figlet openvpn

    hostname -f | figlet -f smslant > /etc/motd.tail 
    echo >> /etc/motd.tail

    cp /etc/mysql/my.cnf /etc/mysql/my.cnf.dist

    edit /etc/mysql/my.cnf:
    

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


