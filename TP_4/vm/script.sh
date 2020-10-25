#!/bin/bash

systemctl start firewalld
setenforce 0
firewall-cmd --reload

echo ' 192.168.1.12 stack.mariadb' | tee /etc/hosts
echo ' 192.168.1.13 stack.nginx' | tee /etc/hosts
echo ' 192.168.1.14 stack.nfs' | tee /etc/hosts
echo ' 192.168.1.15 stack.save' | tee /etc/hosts

yum install -y git

useradd git
echo 'git' | passwd --stdin git

mkdir -p /var/lib/gitea/{custom,data,log}
chown -R git:git /var/lib/gitea/
chmod -R 750 /var/lib/gitea/
mkdir /etc/gitea
chown root:git /etc/gitea
chmod 770 /etc/gitea
