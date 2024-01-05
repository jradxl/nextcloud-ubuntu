#!/bin/bash

APTINSTALL="apt-get install -y --no-install-recommends"
APTREPOSITORY="add-apt-repository -y"
export DEBIAN_FRONTEND=noninteractive

install_script()
{
  echo "Installing PHP-FPM..."
  ##8.2
  DEBIAN_FRONTEND=noninteractive LC_ALL=en_US.UTF-8 $APTREPOSITORY ppa:ondrej/php
  
  apt-get update
  DEBIAN_FRONTEND=noninteractive LC_ALL=en_US.UTF-8  $APTINSTALL php8.2-fpm

  PHPVER=8.2
  $APTINSTALL \
  php${PHPVER} php${PHPVER}-curl php${PHPVER}-gd php${PHPVER}-fpm php${PHPVER}-cli php${PHPVER}-opcache \
  php${PHPVER}-mbstring php${PHPVER}-xml php${PHPVER}-zip php${PHPVER}-fileinfo php${PHPVER}-ldap \
  php${PHPVER}-intl php${PHPVER}-bz2 php${PHPVER}-mysql

  if ( systemctl -q is-active php8.2-fpm ); then
    echo "PHP-FPM is running."
  else
    echo "PHP-FPM is NOT running."
  fi
}
