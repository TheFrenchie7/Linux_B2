# TP4 : Déploiement multi-noeud

## 0. Prerequisites

> Pour la box repackger j'ai installer **"Netdata"** manuellement.
```
hugof@LAPTOP-TFP4BO8F MINGW64 ~/Desktop/Vagrant
$ vagrant package --output b2.tp4-centos.box
==> tp4: Attempting graceful shutdown of VM...
==> tp4: Clearing any previously set forwarded ports...
==> tp4: Exporting VM...
==> tp4: Compressing package to: C:/Users/hugof/Desktop/Vagrant/b2.tp4-centos.box

hugof@LAPTOP-TFP4BO8F MINGW64 ~/Desktop/Vagrant
$ vagrant box add b2.tp4-centos b2.tp4-centos.box
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'b2.tp4-centos' (v0) for provider: 
    box: Unpacking necessary files from: file://C:/Users/hugof/Desktop/Vagrant/b2.tp4-centos.box
    box:
==> box: Successfully added box 'b2.tp4-centos' (v0) for 'virtualbox'!

hugof@LAPTOP-TFP4BO8F MINGW64 ~/Desktop/Vagrant
```

## 1. Listes des hotes

| Name | IP | Rôle |
| -------- | -------- | -------- |
| stack.gitea     | 192.168.1.11     | Gitea    |
| stack.mariadb   | 192.168.1.12     | MariaDB  |
| stack.nginx     | 192.168.1.13     | NGINX    |
| stack.nfs       | 192.168.1.14     | NFS      |
| stack.save      | 192.168.1.15     | sauvegarde|
