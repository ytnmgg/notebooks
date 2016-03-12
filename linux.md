# Contents

1. [httpd](#httpd)
1. [bind](#bind)
2. [ftp](#ftp)
3. [centos mail](#centos-mail)
4. [ssh](#ssh)
---
# httpd

* disable firewall
```bash
iptables -F
```
* disable SELinux
```bash
sestatus -v
```
if this line is not:
```bash
Current mode:                   permissive
```
use this command:
```bash
setenforce 0
```
then disable it permanently by editing `/etc/selinux/config`
```bash
SELINUX=disabled
```
* export the log folder `/opt/cft_execution_logs/mrqe/`
```bash
cd /var/www
mkdir logs
cd logs
ln -s /opt/cft_execution_logs/mrqe/ mrqe
```
* install httpd
```bash
yum -y install httpd
rm -f /etc/httpd/conf.d/welcome.conf
```
* revise config file of httpd `/etc/httpd/conf/httpd.conf` to output `/var/www/logs`
```bash
DocumentRoot "/var/www/logs"
<Directory "/var/www/logs">
    Options All Indexes FollowSymLinks
    AllowOverride None
    # Allow open access:
    Require all granted
</Directory>
```

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

# ssh
ssh login from Host A to Host B without password
* First log in on A as user a and generate a pair of authentication keys. Do not enter a passphrase:
```bash
a@A:~> ssh-keygen -t rsa
```
Generating public/private rsa key pair.
* Enter file in which to save the key (`/home/a/.ssh/id_rsa`):
Created directory `/home/a/.ssh`.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in `/home/a/.ssh/id_rsa`.
Your public key has been saved in `/home/a/.ssh/id_rsa.pub`.
The key fingerprint is:
3e:4f:05:79:3a:9f:96:7c:3b:ad:e9:58:37:bc:37:e4 a@A
* Now use ssh to create a directory `~/.ssh` as user b on B. (The directory may already exist, which is fine):
```bash
a@A:~> ssh b@B mkdir -p .ssh
b@B's password:
```
Finally append a's new public key to b@B:`.ssh/authorized_keys` and enter b's password one last time:
```bash
a@A:~> cat .ssh/id_rsa.pub | ssh b@B 'cat >> .ssh/authorized_keys'
b@B's password:
```
From now on you can log into B as b from A as a without password:
```bash
a@A:~> ssh b@B
```
A note from one of our readers: Depending on your version of SSH you might also have to do the following changes:
>* Put the public key in .ssh/authorized_keys2
>* Change the permissions of .ssh to 700
>* Change the permissions of .ssh/authorized_keys2 to 640

Automatos login to SPs:
