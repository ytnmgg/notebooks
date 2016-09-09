# Contents

1. [httpd](#httpd)
1. [bind](#bind)
2. [ftp](#ftp)
3. [centos mail](#centos-mail)
4. [ssh](#ssh)
5. [vim](#vim)
6. [cmder](#cmder)
7. [hd](#hd)
---
# httpd <a name="httpd"></a>
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
# BIND <a name="bind"></a>

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

# FTP <a name="ftp"></a>

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
# Centos Mail <a name="centos-mail"></a>
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

# ssh <a name="ssh"></a>
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

### Automatos login to SPs:

Add following to  `/etc/ssh/ssh_config`:

```bash
# Used for password-less access to DEBUG builds
IdentityFile /c4shares/Public/ssh/id_rsa.root
# IdentityFile /sobo-c4shares/c4shares/Public/ssh/id_rsa.root

# For anything that looks like an SP, default to root and don't
# complain about the host key changing
Host sim64-* sentry* BC* khsim* *-spa *-spb *-cpa *-cpb
    User root
    StrictHostKeyChecking no

# If we use an IP address, it might not be an SP, so don't default to root,
# but at least don't complain about the host key changing
Host 10.*
    StrictHostKeyChecking no

```
# VIM <a name="vim"></a>
put the following code in `~/.vimrc`
```bash
set nocompatible            " 关闭 vi 兼容模式
syntax on                   " 自动语法高亮
set number                  " 显示行号
set ruler                   " 打开状态栏标尺
set shiftwidth=4            " 设定 << 和 >> 命令移动时的宽度为 4
set softtabstop=4           " 使得按退格键时可以一次删掉 4 个空格
set tabstop=4               " 设定 tab 长度为 4
set expandtab               " 设置用空格替换tab
set smartindent             " 开启新行时使用智能自动缩进"
```

# cmder <a name="cmder"></a>
To create a new task for opening table and ssh to a host,
open 'settings', goto 'Startup', goto 'Tasks', create a new task and add following:
```bash
-new_console:t:10.141.32.223"%CMDER_ROOT%\vendor\git-for-windows\usr\bin\ssh" root@10.141.32.223
```

To create default Cmder, goto 'Startup', goto 'Tasks', create a new task of:
```bash
cmd /k "%ConEmuDir%\..\init.bat"  -new_console:d:"C:\WL_Ducuments":t:Cmder
```
and in Task parameters form, input:
```bash
/icon "C:\WL_Tools\cmder\icons\cmder.ico"
```

# hd <a name="hd"></a>
hardware related commands:
```bash
lsblk
lscpu
lspci
lshw
df
du
free
zfs
targetcli
dmesg
sq_inq

```

source filename 与 sh filename 及./filename执行脚本的区别在那里呢？
1.当shell脚本具有可执行权限时，用sh filename与./filename执行脚本是没有区别得。./filename是因为当前目录没有在PATH中，所有"."是用来表示当前目录的。
2.sh filename 重新建立一个子shell，在子shell中执行脚本里面的语句，该子shell继承父shell的环境变量，但子shell新建的、改变的变量不会被带回父shell，除非使用export。
3.source filename：这个命令其实只是简单地读取脚本里面的语句依次在当前shell里面执行，没有建立新的子shell。那么脚本里面所有新建、改变变量的语句都会保存在当前shell里面。

Linux变量 分 shell变量(set)，用户变量(env)， shell变量包含用户变量，export是一种命令工具，显示当前导出成用户变量的shell变量.可以使用unset命令来清除变量

/etc/profile: 用来设置系统环境参数，如$PATH. 对系统内所有用户生效。当第一个用户登录时,该文件被执行
/etc/bashrc:  这个文件设置系统bash shell相关的东西，对系统内所有用户生效。为每一个运行bash shell的用户执行此文件.当bash shell被打开时,该文件被读取。
~/.bash_profile: 用户登录时被读取，用来设置一些环境变量，功能和/etc/profile 类似，但是这个是针对当前用户来设定的
~/.bashrc: 启动新的shell时被读取，作用类似于/etc/bashrc, 只是针对用户自己而言，不对其他用户生效。
另外/etc/profile中设定的变量(全局)的可以作用于任何用户,而~/.bashrc等中设定的变量(局部)只能继承/etc/profile中的变量,他们是"父子"关系.
~/.bash_profile 是交互式、login 方式进入 bash 运行的，意思是只有用户登录时才会生效。

~/.bashrc 是交互式 non-login 方式进入 bash 运行的，用户不一定登录，只要以该用户身份运行命令行就会读取该文件。


how to find host name from IP with out login to the host
use one of the following command:
```bash
nslookup 10.35.83.49
host 10.35.83.49
dig -x 10.35.83.49
```
