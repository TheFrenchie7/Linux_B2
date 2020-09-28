# TP1 : Déploiment classique

## 0.Prérequis

### Setup de deux machines CentOS7 configurée de façon basique

* **Partionnement**
```
[user@localhost ~]$ sudo pvcreate /dev/sdb
[sudo] password for user:
  Physical volume "/dev/sdb" successfully created.
[user@localhost ~]$ sudo pvs
  PV         VG     Fmt  Attr PSize  PFree
  /dev/sda2  centos lvm2 a--  <7.00g    0
  /dev/sdb          lvm2 ---   5.00g 5.00g
[user@localhost ~]$ sudo pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               centos
  PV Size               <7.00 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              1791
  Free PE               0
  Allocated PE          1791
  PV UUID               WjE3zT-dG9O-l7Zt-ffMX-W7cJ-B9lO-nsnTsu

  "/dev/sdb" is a new physical volume of "5.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size               5.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               FcOxzo-tKPM-4iWo-kgGa-WFmL-SxdP-YnEc0K
```
```
[user@localhost ~]$ sudo vgcreate data /dev/sdb
  Volume group "data" successfully created
[user@localhost ~]$ sudo vgs
  VG     #PV #LV #SN Attr   VSize  VFree
  centos   1   2   0 wz--n- <7.00g     0
  data     1   0   0 wz--n- <5.00g <5.00g
[user@localhost ~]$ sudo vgdisplay
  --- Volume group ---
  VG Name               data
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <5.00 GiB
  PE Size               4.00 MiB
  Total PE              1279
  Alloc PE / Size       0 / 0
  Free  PE / Size       1279 / <5.00 GiB
  VG UUID               YduROa-IBIM-WzUe-QxWV-DWio-2NKM-xUaEsK
```
```
[user@localhost ~]$ sudo lvcreate -L 2G data -n data1
  Logical volume "data1" created.
[user@localhost ~]$ sudo lvcreate -l 100%FREE data -n data2
  Logical volume "data2" created.
[user@localhost ~]$ sudo lvs
  LV    VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root  centos -wi-ao----  <6.20g
  swap  centos -wi-ao---- 820.00m
  data1 data   -wi-a-----   2.00g
  data2 data   -wi-a-----  <3.00g
[user@localhost ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/data/data1
  LV Name                data1
  VG Name                data
  LV UUID                FO6DVL-IC9i-McZS-drds-Jv3H-2Ps1-1LdUFZ
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2020-09-23 12:50:36 +0200
  LV Status              available
  # open                 0
  LV Size                2.00 GiB
  Current LE             512
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2

  --- Logical volume ---
  LV Path                /dev/data/data2
  LV Name                data2
  VG Name                data
  LV UUID                txA3PW-KsBi-gxFS-qdce-dL0b-6tcz-zMxezp
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2020-09-23 12:51:09 +0200
  LV Status              available
  # open                 0
  LV Size                <3.00 GiB
  Current LE             767
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:3
```
```
[user@localhost ~]$ mkfs -t ext4 /dev/data/data1
mke2fs 1.42.9 (28-Dec-2013)
mkfs.ext4: Permission denied while trying to determine filesystem size
[user@localhost ~]$ sudo !!
sudo mkfs -t ext4 /dev/data/data1
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
131072 inodes, 524288 blocks
26214 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=536870912
16 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```
```
[user@localhost ~]$ sudo mkdir /srv/site1
[user@localhost ~]$ sudo mount /dev/data/data1 /srv/site1
[user@localhost ~]$ mount
/dev/mapper/data-data1 on /srv/site1 type ext4 (rw,relatime,seclabel,data=ordered)
[user@localhost ~]$ df -h
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 908M     0  908M   0% /dev
tmpfs                    920M     0  920M   0% /dev/shm
tmpfs                    920M  8.7M  911M   1% /run
tmpfs                    920M     0  920M   0% /sys/fs/cgroup
/dev/mapper/centos-root  6.2G  1.4G  4.9G  22% /
/dev/sda1               1014M  192M  823M  19% /boot
tmpfs                    184M     0  184M   0% /run/user/1000
tmpfs                    184M     0  184M   0% /run/user/0
/dev/mapper/data-data1   2.0G  6.0M  1.8G   1% /srv/site1
[user@localhost ~]$ df -h
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 908M     0  908M   0% /dev
tmpfs                    920M     0  920M   0% /dev/shm
tmpfs                    920M  8.6M  911M   1% /run
tmpfs                    920M     0  920M   0% /sys/fs/cgroup
/dev/mapper/centos-root  6.2G  1.4G  4.9G  22% /
/dev/sda1               1014M  192M  823M  19% /boot
tmpfs                    184M     0  184M   0% /run/user/1000
tmpfs                    184M     0  184M   0% /run/user/0
/dev/mapper/data-data1   2.0G  6.0M  1.8G   1% /srv/site1
/dev/mapper/data-data2   2.9G  9.0M  2.8G   1% /srv/site2
```
```
#
# /etc/fstab
# Created by anaconda on Fri Feb 21 15:38:04 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/centos-root /                       xfs     defaults        0 0
UUID=860bbaa2-9b0d-43ba-9aae-635fcb67ef50 /boot                   xfs     defaults        0 0
/dev/mapper/centos-swap swap                    swap    defaults        0 0
/dev/data/data1 /srv/site1 ext4 defaults 0 0                                                                            /dev/data/data2 /srv/site2 ext4 defaults 0 0 
```
```
[user@localhost ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
swap                     : ignored
mount: /srv/site1 does not contain SELinux labels.
       You just mounted an file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/srv/site1               : successfully mounted
mount: /srv/site2 does not contain SELinux labels.
       You just mounted an file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/srv/site2               : successfully mounted
```

* **accès internet**
```
[user@localhost ~]$ curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```

* **un accès à un réseau local (les deux machines peuvent se ping)**
```
[user@localhost ~]$ ping 192.168.1.12
PING 192.168.1.12 (192.168.1.12) 56(84) bytes of data.
64 bytes from 192.168.1.12: icmp_seq=1 ttl=64 time=0.460 ms
64 bytes from 192.168.1.12: icmp_seq=2 ttl=64 time=0.337 ms
^C
--- 192.168.1.12 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.337/0.398/0.460/0.064 ms
```

* **les machines doivent avoir un nom**
```
[user@node1 ~]$ echo 'node2.tp1.b2' | sudo tee /etc/hostname
[sudo] password for user:
node2.tp1.b2
```

* **les machines doivent pouvoir se joindre par leurs noms respectifs**
```
[user@node1 ~]$ ping node2.tp1.b2
PING node2.tp1.b2 (192.168.1.12) 56(84) bytes of data.
64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=1 ttl=64 time=1.32 ms
64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=2 ttl=64 time=0.757 ms
^C
--- node2.tp1.b2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1003ms
rtt min/avg/max/mdev = 0.757/1.040/1.324/0.285 ms
[user@node1 ~]$
```

* **un utilisateur administrateur est créé sur les deux machines (il peut exécuter des commandes sudo en tant que root)**
```
[user@node2 ~]$ sudo useradd admin
[sudo] password for user:
[user@node2 ~]$ groupadd administrateur
groupadd: Permission denied.
groupadd: cannot lock /etc/group; try again later.
[user@node2 ~]$ sudo !!
[user@node2 ~]$ sudo visudo
## Allow root to run any commands anywhere
root    ALL=(ALL)       ALL
admin   ALL=(ALL)       ALL
```

* **vous n'utilisez que ssh pour administrer vos machines** 
```
PS C:\Users\hugof> ssh user@192.168.1.12
user@192.168.1.12's password:
Last login: Thu Sep 24 09:50:53 2020
Last login: Thu Sep 24 09:50:53 2020
[user@node1 ~]$
```

## 1. Setup serveur Web.

* **Installer le serveur web NGNIX sur node1.tp1.b2**

Pour installer **"NGNIX"** il a fallu d'abord que j'installe **"epel-release"**.
```
[user@node1 ~]$ sudo yum install -y epel-release
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: centos.quelquesmots.fr
 * extras: centos.quelquesmots.fr
 * updates: centos.mirror.ate.info
Resolving Dependencies
--> Running transaction check
---> Package epel-release.noarch 0:7-11 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=======================================================================================================================
 Package                          Arch                       Version                  Repository                  Size
=======================================================================================================================
Installing:
 epel-release                     noarch                     7-11                     extras                      15 k

Transaction Summary
=======================================================================================================================
Install  1 Package

Total download size: 15 k
Installed size: 24 k
Downloading packages:
epel-release-7-11.noarch.rpm                                                                    |  15 kB  00:00:00
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : epel-release-7-11.noarch                                                                            1/1
  Verifying  : epel-release-7-11.noarch                                                                            1/1

Installed:
  epel-release.noarch 0:7-11

Complete!
```
```
[user@node1 ~]$ sudo yum -y install nginx
[...]
Installed:
  nginx.x86_64 1:1.16.1-1.el7

Dependency Installed:
  centos-indexhtml.noarch 0:7-9.el7.centos                       dejavu-fonts-common.noarch 0:2.33-6.el7
  dejavu-sans-fonts.noarch 0:2.33-6.el7                          fontconfig.x86_64 0:2.13.0-4.3.el7
  fontpackages-filesystem.noarch 0:1.44-8.el7                    gd.x86_64 0:2.0.35-26.el7
  gperftools-libs.x86_64 0:2.6.1-1.el7                           libX11.x86_64 0:1.6.7-2.el7
  libX11-common.noarch 0:1.6.7-2.el7                             libXau.x86_64 0:1.0.8-2.1.el7
  libXpm.x86_64 0:3.5.12-1.el7                                   libjpeg-turbo.x86_64 0:1.2.90-8.el7
  libxcb.x86_64 0:1.13-1.el7                                     libxslt.x86_64 0:1.1.28-5.el7
  nginx-all-modules.noarch 1:1.16.1-1.el7                        nginx-filesystem.noarch 1:1.16.1-1.el7
  nginx-mod-http-image-filter.x86_64 1:1.16.1-1.el7              nginx-mod-http-perl.x86_64 1:1.16.1-1.el7
  nginx-mod-http-xslt-filter.x86_64 1:1.16.1-1.el7               nginx-mod-mail.x86_64 1:1.16.1-1.el7
  nginx-mod-stream.x86_64 1:1.16.1-1.el7

Complete!
```
* **"NGNIX" servent deux sites web, chacun qui possède un fichier unique "index.html", les sites web doit se trouver dans "/srv/site1" et "/srv/site2". Les permissions sur ces dossiers doivent être le plus restrictif possible ces dossiers doivent appartenir à un utilisateur et un groupe spécifique**
```
[user@node1 site1]$ touch index.html
touch: cannot touch ‘index.html’: Permission denied
[user@node1 site1]$ sudo touch index.html
[sudo] password for user:
[user@node1 site1]$ ls
index.html  lost+found
[user@node1 site1]$ cd -
/home/user
[user@node1 ~]$ cd /srv/site2
[user@node1 site2]$ touch index.html
touch: cannot touch ‘index.html’: Permission denied
[user@node1 site2]$ sudo !!
sudo touch index.html
[user@node1 site2]$ ls
index.html  lost+found
[[user@node1 srv]$ sudo chmod 510 site1
[user@node1 srv]$ sudo chmod 510 site2
[user@node1 srv]$ sudo chown usern:usern site1
[user@node1 srv]$ sudo chown usern:usern site2
[user@node1 srv]$ ls -al
total 8
drwxr-xr-x.  4 root  root    32 Sep 23 13:03 .
dr-xr-xr-x. 17 root  root   224 Feb 21  2020 ..
dr-x--x---.  3 usern usern 4096 Sep 24 11:06 site1
dr-x--x---.  3 usern usern 4096 Sep 24 10:45 site2
[user@node1 ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[user@node1 ~]$ sudo firewall-cmd --add-port=443/tcp --permanent
[user@node1 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: dhcpv6-client ssh
  ports: 80/tcp 443/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

[user@node1 ~]$
```
```
user usern;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    server {
        listen       80;
        server_name  node1.tp1.b2;

        location / {
                return 301 /site1;
        }
            location /site1 {
                alias /srv/site1;
        }
            location /site2 {
                alias /srv/site2;
        }
        }
}
```
* **Prouver que la machine node2 peut joindre les deux sites web**
Pour le **"HTTP"**
```
[user@node2 ~]$ curl -L node1.tp1.b2/site1
<h1>Hello 1</h1>
[user@node2 ~]$ curl -L node1.tp1.b2/site2
<h1>Hello 2</h1>
[user@node2 ~]$
```
Pour le **"HTTPS"**
```
[user@node2 ~]$ curl -L -k https://node1.tp1.b2/site1
<h1>Hello 1</h1>
[user@node2 ~]$ curl -L -k https://node1.tp1.b2/site2
<h1>Hello 2</h1>
[user@node2 ~]$
```
## 2.Script de sauvegarde.
* **Ecrire un script**
```
#!/bin/bash

backupdate=$(date +%Y-%m-%d-%H-%M)

dirbackup=backup

tar -cf $dirbackup/site1-$backupdate.tar.gzip /etc /srv /site1

find $log -type f -mtime +1 -exec /etc/script/backup -f {} \;
```
```
[backup@node1 srv]$ ls -al
total 8
dr-xrwx---.  4 usern backup   32 Sep 23 13:03 .
dr-xr-xr-x. 17 root  root    224 Sep 24 11:59 ..
dr-xrwx---.  3 usern backup 4096 Sep 24 11:55 site1
dr-xrwx---.  3 usern backup 4096 Sep 24 11:55 site2
[backup@node1 srv]$ cd /site1
-bash: cd: /site1: No such file or directory
[backup@node1 srv]$ cd site1
[backup@node1 site1]$ ls -al
total 24
dr-xrwx---. 3 usern backup  4096 Sep 24 11:55 .
dr-xrwx---. 4 usern backup    32 Sep 23 13:03 ..
-r-xrwx---. 1 usern backup    17 Sep 24 11:55 index.html
dr-xrwx---. 2 usern backup 16384 Sep 23 12:53 lost+found
```

* **Utiliser la "crontab" pour que le script s'exécute automatiquement toutes les heures.**
```
[backup@node1 ~]$ crontab -l
0 * * * * ./tp1_backup.sh
```
* **Prouver que vous êtes capables de restaurer un des sites dans une version antérieure, et fournir une marche à suivre pour restaurer une sauvegarde donnée.**


## 3.Monitoring, alerting.

* **Mettre en place l'outil Netdata en suivant les instructions officielles et s'assurer de son bon fonctionnement.**
![](https://i.imgur.com/UPVECPl.png)


* **Configurer Netdata pour qu'ils vous envoient des alertes dans un salon Discord dédié**
![](https://i.imgur.com/dotpsXZ.png)