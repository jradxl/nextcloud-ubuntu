#!/bin/bash

APTINSTALL="apt-get install -y --no-install-recommends"
APTREPOSITORY="add-apt-repository -y"
export DEBIAN_FRONTEND=noninteractive

install_script()
{
  echo "Start installing NGINX..."
  ##DONE "$APTINSTALL curl gnupg2 ca-certificates lsb-release ubuntu-keyring"
  #echo "Downloading Nginx's Apt Key"
  #curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor  | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
  ##echo "deb https://packages.sury.org/php/ ${RELEASE} main" > /etc/apt/sources.list.d/nginx.list
  #echo "Updating /etc/apt/sources.list.d"
  #echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
  
  #Adding Ondrej Nginx as we're using Ondrej's PHP
  DEBIAN_FRONTEND=noninteractive LC_ALL=en_US.UTF-8 $APTREPOSITORY ppa:ondrej/nginx
  apt-get update
  echo "Installing NGINX package..."
  $APTINSTALL nginx

  if (systemctl -q is-active nginx); then
    echo "Nginx is running."
  else
    echo "Nginx is NOT running."
  fi

  #TODO - nginx.conf, and server-location.conf
}
