Dokumentace
============

Soubory zde slouží k sestavení páru mysql serverů s master-master replikací,
se základním dohledem a s administračním rozhraním Adminer.

Instalace je popsána v README.md

Licence díla je WFTPL: http://sam.zoy.org/wtfpl/


Po instalaci
-------------

root heslo k mysql databázi naleznete v souboru `/root/.my.cnf`.
Pozor, na každém ze serverů bude jiné. Tento soubor můžete dle svého uvážení odstranit, např.
příkazem `wipe /root/.my.cnf`.

Po instalaci podle README.md není nastaven firewall, jeho nastavení se však důrazně doporučuje.

K administračnímu přístupu přes web se doporučuje nainstalovat do prohlížeče soubor
ca.crt, který naleznete na adrese http://server/ca.crt. Poté můžete přistupovat k admineru
přes adresu https://server/adminer

Na serveru 2 probíhá 1x denně lokální zálohování db mysqldumpem do složky /home/backup.
Po dobu běhu zálohy může mít db2 horší odezvu. Doporučuje se doplnit vzdálené zálohování,
ideálně na třetí úložiště.


V /root je po instalaci přítomen soubor nagios_hostname.cfg, který lze umístit do dohledového
serveru.


