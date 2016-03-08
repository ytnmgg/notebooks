# Contents


1. [bind](#bind)
2. [ftp](#ftp)
3. [centos mail](#centos-mail)
---
# BIND

* isntall bind
```bash
yum install bind
```
* revise `/etc/named.conf`
```bash
listen-on port 53 { any; };
allow-query     { localhost; 192.168.168.0/24;};
```
* revise `/etc/named.rfc1912.zones`
```bash
zone "ytnmgg.com" IN{
        type master;
        file "ytnmgg.com.zone";
};
zone "168.168.192.in-addr.arpa" IN{
        type master;
        file "192.168.168.zone";
};
```
* check if this file is OK
```bash
named-checkconf
```
* revise `/var/named/ytnmgg.com.zone`
```bash
$TTL 600
$ORIGIN ytnmgg.com.
@    IN SOA   ns.ytnmgg.com. root.ytnmgg.com. (
              2016030801; Serial
              3H; Refresh
              5M; Retry
              3D; Expire
              2H); Minimum
     IN NS    ns.ytnmgg.com.
     IN MX 10 mail.ytnmgg.com.
ns   IN A     192.168.168.202
mail IN A     192.168.168.202
www1 IN A     192.168.168.202
pop3 IN CNAME mail
```
* check if this file is OK
```bash
named-checkzone ytnmgg.com /var/named/ytnmgg.com.zone
```
---

# FTP

* install the vsftpd
```bash
yum -y install vsftpd
```
* start the service
```bash
service vsftpd start
```
* set to start automatically after reboot
``` bash
chkconfig vsftpd on
```
* close the firewall
``` bash
iptables -F
```
* configure the FTP `/etc/vsftpd/vsftpd.conf`
```bash
anonymous_enable=YES
write_enable=YES
listen=YES
listen_ipv6=NO
anon_mkdir_write_enable=YES
anon_root=/var/ftp
anon_upload_enable=YES
no_anon_password=YES
```
* close SELinux
```bash
sestatus
setenforce 0
```

  + Revise `/etc/selinux/config`
```bash
SELINUX=enforcing
SELINUX=disabled
```
* Change credential
```bash
chmod 777 /var/ftp/pub
chown ftp /var/ftp/pub
service vsftpd restart
```
---
# Centos Mail
```markdown
This file describe some detail to use 'mail' command in Centos7
```

* Edit `/etc/postfix/main.cf`
```bash
myhostname = desktop.ytnmgg.com
mydomain = ytnmgg.com
myorigin = $myhostname
inet_interfaces = all
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
mynetworks = 168.100.189.0/28, 127.0.0.0/8, 127.0.0.1/8, 192.168.168.0/24
relay_domains = $mydestination, 126.com
```

* To use ytnmgg@126.com account as the mail sender, Add the following two lines to `/etc/mail.rc`
```bash
set from=ytnmgg@126.com  smtp=smtp.126.com
set smtp-auth-user=ytnmgg@126.com  smtp-auth-password=*** smtp-auth=login
```
***
