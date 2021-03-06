# TP2 : Déploiement automatisé

## 1. Déploiement simple

* **Créer un "Vagrantfile"**
    * Une VM avec un 1Go RAM
    * Ajout d'une IP statique "192.168.2.11/24"
    * définition d'un nom (interne à vagrant)
    * définition d'un hostname
```
$ vagrant status
Current machine states:

TP2_Vagrant               running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
```
```
[vagrant@tp2 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 86040sec preferred_lft 86040sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:51:62:45 brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.11/24 brd 192.168.2.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe51:6245/64 scope link
       valid_lft forever preferred_lft forever
```
```
[vagrant@tp2 ~]$ free -m
              total        used        free      shared  buff/cache   available
Mem:            990          87         790           6         113         774
Swap:          2047           0        2047
```
* Le script qui permet de faire tout ça
```
Vagrant.configure("2")do|config|
  config.vm.box="centos/7"

  # Ajoutez cette ligne afin d'accélérer le démarrage de la VM (si une erreur 'vbguest' est levée, voir la note un peu plus bas)
  config.vbguest.auto_update = false

  # Désactive les updates auto qui peuvent ralentir le lancement de la machine
  config.vm.box_check_update = false 

  # La ligne suivante permet de désactiver le montage d'un dossier partagé (ne marche pas tout le temps directement suivant vos OS, versions d'OS, etc.)
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.network "public_network", ip:"192.168.2.11"

  config.vm.hostname = "tp2.vagrant"

  config.vm.define "TP2_Vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "TP2_Vagrant"
    vb.memory = "1024"
  end

end
```
* **Modifier le "Vagrantfile"**
    * La machine exécute un script shell au démarrage qui install le paquet vim
    * ajout d'un deuxième disque de 5Go à la VM

* ceci est le script pour installer vim au démarrage de la VM à l'aide de cette ligne en plus **"config.vm.provision "shell", path: "script.sh""**
```
#!/bin/bash

sudo yum install -y vim
```
* ensuite la confirmation que celui-ci c'est bien exécuter et est terminer
```
==> TP2_Vagrant: Running provisioner: shell...
    TP2_Vagrant: Running: C:/Users/hugof/AppData/Local/Temp/vagrant-shell20200929-3728-8wazsl.sh
[...]
TP2_Vagrant: Complete!
```
* Le resultat du rajout du disque de 5GB
```
[vagrant@tp2 ~]$ lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda      8:0    0  40G  0 disk
└─sda1   8:1    0  40G  0 part /
sdb      8:16   0   5G  0 disk
[vagrant@tp2 ~]$
```
* le script modifier qui permet de rajouter le disque plus d'exécuter le script au démarrage
```
CONTROL_NODE_DISK = './tmp/large_disk.vdi'

Vagrant.configure("2")do|config|
  config.vm.box="b2-tp2-centos"

  # Ajoutez cette ligne afin d'accélérer le démarrage de la VM (si une erreur 'vbguest' est levée, voir la note un peu plus bas)
  config.vbguest.auto_update = false

  # Désactive les updates auto qui peuvent ralentir le lancement de la machine
  config.vm.box_check_update = false 

  # La ligne suivante permet de désactiver le montage d'un dossier partagé (ne marche pas tout le temps directement suivant vos OS, versions d'OS, etc.)
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.network "public_network", ip:"192.168.2.11"

  config.vm.hostname = "tp2.vagrant"

  config.vm.define "TP2_Vagrant"
  
  config.vm.provision "shell", path: "script.sh"

  config.vm.disk :disk, name: "disk2", size: "5GB"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "TP2_Vagrant"
    vb.memory = "1024"
    unless File.exist?(CONTROL_NODE_DISK)
      vb.customize ['createhd', '--filename', CONTROL_NODE_DISK, '--variant', 'Fixed', '--size', 5 * 1024]
    end

    # Attache le disque à la VM
    vb.customize ['storageattach', :id,  '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', CONTROL_NODE_DISK]
  end

end
```
## 2. Re-package
```
[vagrant@tp2 ~]$ sudo setenforce 0
```
```
hugof@LAPTOP-TFP4BO8F MINGW64 ~/Desktop/Vagrant
$ vagrant package --output centos7-custom.box
==> TP2_Vagrant: Attempting graceful shutdown of VM...
==> TP2_Vagrant: Clearing any previously set forwarded ports...
==> TP2_Vagrant: Exporting VM...
==> TP2_Vagrant: Compressing package to: C:/Users/hugof/Desktop/Vagrant/centos7-custom.box

hugof@LAPTOP-TFP4BO8F MINGW64 ~/Desktop/Vagrant
$ vagrant box add b2-tp2-centos centos7-custom.box
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'b2-tp2-centos' (v0) for provider: 
    box: Unpacking necessary files from: file://C:/Users/hugof/Desktop/Vagrant/centos7-custom.box
    box:
==> box: Successfully added box 'b2-tp2-centos' (v0) for 'virtualbox'!

hugof@LAPTOP-TFP4BO8F MINGW64 ~/Desktop/Vagrant
$ vagrant box list
b2-tp2-centos (virtualbox, 0)
centos/7      (virtualbox, 2004.01)
```

## 3. Multi-node deployement

* **Créer un Vagrantfile qui lance deux machines virtuelles**

* la configuration pour créer les 2 VMs d'un coup 
```
Vagrant.configure("2")do|config|
  config.vm.box="b2-tp2-centos"

  # Ajoutez cette ligne afin d'accélérer le démarrage de la VM (si une erreur 'vbguest' est levée, voir la note un peu plus bas)
  config.vbguest.auto_update = false

  # Désactive les updates auto qui peuvent ralentir le lancement de la machine
  config.vm.box_check_update = false 

  # La ligne suivante permet de désactiver le montage d'un dossier partagé (ne marche pas tout le temps directement suivant vos OS, versions d'OS, etc.)
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.define "node1" do |node1|
    node1.vm.network "private_network", ip:"192.168.2.21"
    node1.vm.hostname = "node1.tp2.b2"
    node1.vm.define "node1"
    node1.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
  end

  config.vm.define"node2" do |node2|
    node2.vm.network "private_network", ip:"192.168.2.22"
    node2.vm.hostname = "node2.tp2.b2"
    node2.vm.define "node2"
    node2.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "512"]
    end
  end

end
```
* VM 1:
```
[vagrant@node1 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 85855sec preferred_lft 85855sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:ee:93:32 brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.21/24 brd 192.168.2.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feee:9332/64 scope link
       valid_lft forever preferred_lft forever
```
```
[vagrant@node1 ~]$ free -m
              total        used        free      shared  buff/cache   available
Mem:            990         113         780           6          97         756
Swap:          2047           0        2047
```
```
[vagrant@node1 ~]$ vim /etc/hostname
node1.tp2.b2
```
* VM 2:
```
[vagrant@node2 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 85765sec preferred_lft 85765sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:1b:36:9e brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.22/24 brd 192.168.2.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe1b:369e/64 scope link
       valid_lft forever preferred_lft forever
```
```
[vagrant@node2 ~]$ free -m
              total        used        free      shared  buff/cache   available
Mem:            486         104         287           4          95         365
Swap:          2047           0        2047
```
```
[vagrant@node2 ~]$ vim /etc/hostname
node2.tp2.b2
```
## 4. Automation here we (slowly) come
* **Créer un "vagrantfile" qui automatise le TP1**

* HTTPS:
```bash=
[vagrant@node2 ~]$ curl -L https://node1.tp2.b2/site1
<h1>hello1</h1>
[vagrant@node2 ~]$ curl -L https://node1.tp2.b2/site2
<h1>hello2</h1>
[vagrant@node2 ~]$
```
* HTTP
```bash=
[vagrant@node2 ~]$ curl -L node1.tp2.b2/site1
<h1>hello1</h1>
[vagrant@node2 ~]$ curl -L node1.tp2.b2/site2
<h1>hello2</h1>
[vagrant@node2 ~]$
```
* ping vers **"node1"** avec l'adresse ip puis le nom d'hôte
```bash=
[vagrant@node2 ~]$ ping 192.168.1.11
PING 192.168.1.11 (192.168.1.11) 56(84) bytes of data.
64 bytes from 192.168.1.11: icmp_seq=1 ttl=64 time=0.438 ms
64 bytes from 192.168.1.11: icmp_seq=2 ttl=64 time=0.419 ms

--- 192.168.1.11 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1010ms
rtt min/avg/max/mdev = 0.419/0.428/0.438/0.022 ms
[vagrant@node2 ~]$ ping node1.tp2.b2
PING node1.tp2.b2 (192.168.1.11) 56(84) bytes of data.
64 bytes from node1.tp2.b2 (192.168.1.11): icmp_seq=1 ttl=64 time=0.467 ms
64 bytes from node1.tp2.b2 (192.168.1.11): icmp_seq=2 ttl=64 time=0.453 ms

--- node1.tp2.b2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1024ms
rtt min/avg/max/mdev = 0.453/0.460/0.467/0.007 ms
[vagrant@node2 ~]$
```
* Vérification du second disk
```bash=
[vagrant@node2 ~]$ lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda      8:0    0  40G  0 disk
└─sda1   8:1    0  40G  0 part /
sdb      8:16   0   5G  0 disk
[vagrant@node2 ~]$
```
* La config vagrant qui m'a permis de faire tout ça
```bash=
CONTROL_NODE_DISK1 = './tmp/large_disk1.vdi'
CONTROL_NODE_DISK2 = './tmp/large_disk2.vdi'

Vagrant.configure("2")do|config|
  config.vm.box="b2-tp2-centos"

  # Ajoutez cette ligne afin d'accélérer le démarrage de la VM (si une erreur 'vbguest' est levée, voir la note un peu plus bas)
  config.vbguest.auto_update = false

  # Désactive les updates auto qui peuvent ralentir le lancement de la machine
  config.vm.box_check_update = false 

  # La ligne suivante permet de désactiver le montage d'un dossier partagé (ne marche pas tout le temps directement suivant vos OS, versions d'OS, etc.)
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.define "node1" do |node1|
    node1.vm.network "public_network", ip:"192.168.1.11", hostname: true
    node1.vm.network "private_network", type: "dhcp"
    node1.vm.hostname = "node1.tp2.b2"
    node1.vm.define "node1"
    node1.vm.provision "shell", path: "script.sh"
    node1.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
      unless File.exist?(CONTROL_NODE_DISK1)
        vb.customize ['createhd', '--filename', CONTROL_NODE_DISK1, '--variant', 'Fixed', '--size', 5 * 1024]
      end
      vb.customize ['storageattach', :id,  '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', CONTROL_NODE_DISK1]
    end
  end

  config.vm.define"node2" do |node2|
    node2.vm.network "public_network", ip:"192.168.1.12", hostname: true
    node2.vm.network "private_network", type: "dhcp"
    node2.vm.hostname = "node2.tp2.b2"
    node2.vm.provision "shell", path: "script2.sh"
    node2.vm.define "node2"
    node2.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "512"]
      unless File.exist?(CONTROL_NODE_DISK2)
        vb.customize ['createhd', '--filename', CONTROL_NODE_DISK2, '--variant', 'Fixed', '--size', 5 * 1024]
      end
      vb.customize ['storageattach', :id,  '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', CONTROL_NODE_DISK2]
    end
  end

end
```
* Les deux scripts que j'ai utilisé en plus pour ceci
```bash=
#!/bin/bash

systemctl start firewalld
setenforce 0
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --reload

useradd admin
echo 'admin' | passwd --stdin admin

useradd usern
echo 'usern' | passwd --stdin usern

echo ' 192.168.1.12 node2.tp2.b2' | tee /etc/hosts

mkdir /srv/site1
mkdir /srv/site2
touch index.html /srv/site1
touch index.html /srv/site2

echo '<h1>hello1</h1>' | tee /srv/site1/index.html
echo '<h1>hello2</h1>' | tee /srv/site2/index.html
chmod 510 /srv/site1
chmod 510 /srv/site2
chown usern:usern /srv/site1
chown usern:usern /srv/site2

echo '
worker_processes 1;
error_log nginx_error.log;
pid /run/nginx.pid;
user usern;

events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name node1.tp2.b2;
        
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
    server {
        listen 443 ssl;

        server_name node1.tp2.b2;
        ssl_certificate /etc/pki/tls/certs/server.crt;
        ssl_certificate_key /etc/pki/tls/private/server.key;
        
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
}' > /etc/nginx/nginx.conf
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt -subj "/CN=node1.tp2.b2"
mv server.key /etc/pki/tls/private
mv server.crt /etc/pki/tls/certs
systemctl start nginx
```
```bash=
#!/bin/bash

systemctl start firewalld
setenforce 0
firewall-cmd --reload

useradd admin
echo 'admin' | passwd --stdin admin

echo ' 192.168.1.11 node1.tp2.b2' | tee /etc/hosts

echo -n | openssl s_client -connect node1.tp2.b2:443 \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/pki/ca-trust/source/anchors/server.cert
update-ca-trust
```