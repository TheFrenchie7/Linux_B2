#!/bin/bash

systemctl start firewalld
setenforce 0
firewall-cmd --reload

echo ' 192.168.1.11 stack.gitea' | tee /etc/hosts
echo ' 192.168.1.13 stack.nginx' | tee /etc/hosts
echo ' 192.168.1.14 stack.nfs' | tee /etc/hosts
echo ' 192.168.1.15 stack.save' | tee /etc/hosts

