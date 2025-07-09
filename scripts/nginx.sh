#!/bin/bash

install_script()
{
  echo "Start installing NGINX..."

  echo "    Downloading Nginx's Apt Key"
  curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor  | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

  echo ""
  gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
  echo ""

  RELEASE=$(lsb_release -cs)
  echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $RELEASE nginx" | tee /etc/apt/sources.list.d/nginx.list 
 
  apt-get update
  echo "    Installing NGINX package..."
  $APTINSTALL nginx

  if (systemctl -q is-active nginx); then
    echo "    Nginx is running."
  else
    echo "    Nginx is NOT running."
  fi

  #TODO - nginx.conf, and server-location.conf
}
