TODO
----


- změna root hesla a debian-sys-maint.
- stažení tls certu na slave

- apache2/mpm-itk + adminer + tls

- nahrání reálných dat a mysqltuner
- nahrání reálných dotazů z prod. serveru a replay

- minimální dohled
- lokální zálohování mysqldumpem

- dokumentace


DONE
-----

- instalace základního systému
  - dist-upgrade
  - nastaveni ipv6 RA fix
  - instalace mysql-server

- konfigurace parametrů mysql
  - thready - 40
  - query cache - 80
  - innodb_buffer_pool - 100
  - binlog
  - server id
  - innodb file per table
  - auto_increment offset

- vytvoření ca a tls certifikátu na masteru

