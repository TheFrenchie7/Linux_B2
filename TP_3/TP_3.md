# TP3 : systemd

## 1. Services systemd
### 1.1. Intro
* **Utiliser les lignes de commandes pour sortir les infos suivantes :**
* afficher le nombre de services systemd dispos sur la machine.
```bash=
[vagrant@tp3 ~]$ systemctl list-unit-files --type=service |  grep -c systemd
51
```
*  afficher le nombre de services systemd actifs ("running") sur la machine
```bash=
[vagrant@tp3 ~]$ systemctl -t service |  grep -c systemd
13
```
*  afficher le nombre de services systemd qui ont échoué ("failed") ou qui sont inactifs ("exited") sur la machine
```bash=
[vagrant@tp3 ~]$ systemctl list-units |  grep systemd | egrep "exited|failed" -c
10
```
*  afficher la liste des services systemd qui démarrent automatiquement au boot ("enabled")
```bash=
[vagrant@tp3 ~]$ systemctl list-unit-files |  grep systemd | grep "enable" 
systemd-readahead-collect.service             enabled
systemd-readahead-drop.service                enabled
systemd-readahead-replay.service              enabled
[vagrant@tp3 ~]$
```
### 1.2 Analyse d'un service
* **Etudiez le service "nginx.service"**
* déterminer le path de l'unité nginx.service
```bash=
[vagrant@tp3 ~]$ systemctl cat nginx.service
# /usr/lib/systemd/system/nginx.service
```
* afficher son contenu et expliquer les lignes qui comportent:
    * **"ExecStart"** 
    * **"ExecStartPre"**
    * **"PIDFile"**
    * **"Type"**
    * **"ExecReload"**
    * **"Description"**
    * **"After"**
* **"ExecStart"** définit en faite les commandes qui sont exécuter quand le service démarre.
* **"ExecStartPre"** définit les commandes additionnel qui sont exécuter avant ou après les commandes dans le **"ExecStart"**.
* **"ExecReload"** définit les commandes qui est font en sorte de stopper le service démarrer grâce à **"ExecStart"**.
* **"After"** est une dépendance qui s'assure qu'un service démarre normalement.
* **"Description"** donne une description de qu'est-ce que c'est ce service.
* **"PIDFile"** où se situe le premier process du service
* **"Type"** définit de quel type est le service, si c'est un mount par exemple
```bash=
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```
* **Listez tous les services qui contiennent la ligne "WantedBy=multi-user.target".**
```bash=
[vagrant@tp3 ~]$ cd /usr/lib/systemd/system
[vagrant@tp3 system]$ grep -lr "WantedBy=multi-user.target" | grep service
rpcbind.service
rdisc.service
tcsd.service
sshd.service
rhel-configure.service
rsyslog.service
irqbalance.service
cpupower.service
crond.service
rpc-rquotad.service
wpa_supplicant.service
chrony-wait.service
chronyd.service
NetworkManager.service
ebtables.service
gssproxy.service
tuned.service
firewalld.service
nfs-server.service
rsyncd.service
nginx.service
vmtoolsd.service
postfix.service
auditd.service
[vagrant@tp3 system]$
```
### 1.3 Création d'un service
#### A.Serveur web

* **Créez une unité de service qui lance un serveur web**
```bash=
[Unit]
Description=lance le serveur web

[Service]
Type=simple
RemainAfterExit=yes
Environnement="PORT=8080"
User=web
group=web
ExecStartPre=sudo /usr/bin/firewall-cmd --add-port=$PORT/tcp --permanent
ExecStart=/usr/bin/python2 -m SimpleHTTPServer $PORT
ExecStartPre=sudo /usr/bin/firewall-cmd --remove-port=$PORT/tcp --permanent


[Install]
WantedBy=multi-user.target
```
* **Lancer le service**
* **prouver qu'il est en cours de fonctionnement pour systemd**
```bash=
[vagrant@tp3 ~]$ systemctl status serv.service
● serv.service - lance le serveur web
   Loaded: loaded (/etc/systemd/system/serv.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-10-07 08:24:19 UTC; 12s ago
 Main PID: 3206 (python2)
   CGroup: /system.slice/serv.service
           └─3206 /usr/bin/python2 -m SimpleHTTPServer 8080
```
* **prouver que le serveur web est bien fonctionnel**
```bash=
[vagrant@tp3 system]$ curl 172.28.128.3:8080
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"><html>
<title>Directory listing for /</title>
<body>
<h2>Directory listing for /</h2>
<hr>
<ul>
<li><a href="bin/">bin@</a>
<li><a href="boot/">boot/</a>
<li><a href="dev/">dev/</a>
<li><a href="etc/">etc/</a>
<li><a href="home/">home/</a>
<li><a href="lib/">lib@</a>
<li><a href="lib64/">lib64@</a>
<li><a href="media/">media/</a>
<li><a href="mnt/">mnt/</a>
<li><a href="opt/">opt/</a>
<li><a href="proc/">proc/</a>
<li><a href="root/">root/</a>
<li><a href="run/">run/</a>
<li><a href="sbin/">sbin@</a>
<li><a href="srv/">srv/</a>
<li><a href="swapfile">swapfile</a>
<li><a href="sys/">sys/</a>
<li><a href="tmp/">tmp/</a>
<li><a href="usr/">usr/</a>
<li><a href="var/">var/</a>
</ul>
<hr>
</body>
</html>
```
#### B. Sauvegarde
* **Créez une unité de service qui déclenche une sauvegarde avec votre script**

## 2.Autres features
### 2.1 Gestion de boot
* **Utilisez "systemd-analyze plot" pour récupérer une diagramme du boot, au format SVG**
* déterminer les 3 services les plus lents à démarrer
Le premier service le plus lent à démarrer est **"dnf-makecache.service"** avec une durée de **"8.158s"** ensuite **"tuned.service"** avec une durée de **"3.784s"** et pour finir **"sshd-keygen@rsa.service"** avec une durée de **"2.253s"**

### 2.2 Gestion de l'heure
* **Utilisez la commande "timedatectl"**
* déterminer votre fuseau horaire
Nous pouvons voir que le fuseau horaire est définit dans le **"Time zone"** et nous pouvons voir aussi que oui nous sommes synchronisés avec un serveur NTP grâce à **"NTP service: active"**
* déterminer si vous êtes synchronisés avec un serveur NTP
```bash=
[vagrant@tp33 ~]$ timedatectl
               Local time: Wed 2020-10-07 09:56:58 UTC
           Universal time: Wed 2020-10-07 09:56:58 UTC
                 RTC time: Wed 2020-10-07 09:56:56
                Time zone: UTC (UTC, +0000)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
[vagrant@tp33 ~]$
```
* changer le fuseau horaire
```bash=
[vagrant@tp33 ~]$ timedatectl set-timezone Europe/Paris
[vagrant@tp33 ~]$ timedatectl
               Local time: Wed 2020-10-07 12:00:06 CEST
           Universal time: Wed 2020-10-07 10:00:06 UTC
                 RTC time: Wed 2020-10-07 10:00:04
                Time zone: Europe/Paris (CEST, +0200)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
[vagrant@tp33 ~]$
```
### 2.3 Gestion des noms et de la résolutions de nom
* **Utilisez "hostnamectl"**
* déterminer votre hostname actuel
```bash=
[vagrant@tp33 ~]$ hostnamectl status
   Static hostname: tp33.vagrant
         Icon name: computer-vm
           Chassis: vm
        Machine ID: b2daad500609458095e120c3e0dc972e
           Boot ID: 3e9f6f250e4b405c80b35728a6d5c4f1
    Virtualization: oracle
  Operating System: CentOS Linux 8 (Core)
       CPE OS Name: cpe:/o:centos:centos:8
            Kernel: Linux 4.18.0-80.el8.x86_64
      Architecture: x86-64
[vagrant@tp33 ~]$
```
* changer votre hostname
```bash=
[vagrant@tp33 ~]$ hostnamectl set-hostname tp333
[vagrant@tp33 ~]$ hostnamectl status
   Static hostname: tp333
         Icon name: computer-vm
           Chassis: vm
        Machine ID: b2daad500609458095e120c3e0dc972e
           Boot ID: 3e9f6f250e4b405c80b35728a6d5c4f1
    Virtualization: oracle
  Operating System: CentOS Linux 8 (Core)
       CPE OS Name: cpe:/o:centos:centos:8
            Kernel: Linux 4.18.0-80.el8.x86_64
      Architecture: x86-64
[vagrant@tp33 ~]$
```