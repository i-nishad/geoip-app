#!/bin/bash

yum install docker -y
systemctl restart docker.service
systemctl enable docker.service

curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

yum install git -y
git clone https://github.com/i-nishad/geoip-app.git
cd geoip-app


[ -f ./nginx-conf/nginx.conf-default ] && cat ./nginx-conf/nginx.conf-default | sed "s/ROOT_DOMAIN/$1/" > ./nginx-conf/nginx.conf

docker-compose up -d

sleep 3

# Request a certificate with Certbot 

docker-compose run --rm --entrypoint "certbot certonly --webroot --webroot-path=/var/www/html --email $2 --agree-tos --eff-email --force-renewal -d $1" certbot

# Generate an NGINX config with the given domain
rm -rf ./nginx-conf/nginx.conf

[ -f ./nginx-conf/nginx.conf-sample ] && cat ./nginx-conf/nginx.conf-sample | sed "s/ROOT_DOMAIN/$1/" > ./nginx-conf/nginx.conf

docker container exec nginx1  nginx -s reload
