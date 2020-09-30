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