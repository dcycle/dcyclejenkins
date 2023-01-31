#!/bin/bash
#
# Fix secure site (cert problems, bad gateway).
#
set -e

docker pull jwilder/nginx-proxy
docker pull jrcs/letsencrypt-nginx-proxy-companion
docker pull jenkins/jenkins:latest
docker network prune -f
docker container prune -f
docker image prune -f
docker network disconnect dcyclejenkins_default nginx-proxy || true
(docker stop $(docker ps -a -q) &
docker update --restart=no $(docker ps -a -q) &
docker stop $(docker ps -a -q) &
docker update --restart=no $(docker ps -a -q) &
systemctl restart docker)
docker ps
docker-compose -f docker-compose.yml -f docker-compose.ssl.yml up -d
docker rm nginx-proxy || true
docker run --rm -d -p 80:80 -p 443:443 \
  --name nginx-proxy \
  -v "$HOME"/certs:/etc/nginx/certs:ro \
  -v /etc/nginx/vhost.d \
  -v /usr/share/nginx/html \
  -v /var/run/docker.sock:/tmp/docker.sock:ro \
  --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
  --restart=always \
  jwilder/nginx-proxy
docker rm nginx-letsencrypt || true
docker run --rm -d \
  --name nginx-letsencrypt \
  -v "$HOME"/certs:/etc/nginx/certs:rw \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --volumes-from nginx-proxy \
  --restart=always \
  jrcs/letsencrypt-nginx-proxy-companion
docker ps
docker network connect dcyclejenkins_default nginx-proxy
docker restart nginx-letsencrypt
