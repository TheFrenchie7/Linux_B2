#!/bin/bash

setenforce 0

yum update -y
yum install -y vim
yum install -y epel-release

