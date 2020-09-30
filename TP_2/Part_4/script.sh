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