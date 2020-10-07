#!/bin/bash

yum update 
yum install -y vim
yum install -y epel-release
yum install -y nginx

systemctl start firewalld
setenforce 0
firewall-cmd --reload