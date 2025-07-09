#!/bin/bash

## On PLUCKY, install ubuntu repo version

install_script()
{
  echo "    Installing PHP-FPM..."

  PHPVER=$(jq -r .php_version "$NCPCFG")
  UBUNTUVERSION=$(lsb_release -cs)

  case "$UBUNTUVERSION" in
  "noble")
    add-apt-repository ppa:ondrej/php
    apt-get update
    $APTINSTALL \
    php${PHPVER} php${PHPVER}-curl php${PHPVER}-gd php${PHPVER}-fpm php${PHPVER}-cli php${PHPVER}-opcache \
    php${PHPVER}-mbstring php${PHPVER}-xml php${PHPVER}-zip php${PHPVER}-fileinfo php${PHPVER}-ldap \
    php${PHPVER}-intl php${PHPVER}-bz2 php${PHPVER}-mysql    
    ;;
  "plucky")
    echo "NOTICE: Installing PHP-FPM from the Ubuntu Repo"
    $APTINSTALL \
    php${PHPVER} php${PHPVER}-curl php${PHPVER}-gd php${PHPVER}-fpm php${PHPVER}-cli php${PHPVER}-opcache \
    php${PHPVER}-mbstring php${PHPVER}-xml php${PHPVER}-zip php${PHPVER}-fileinfo php${PHPVER}-ldap \
    php${PHPVER}-intl php${PHPVER}-bz2 php${PHPVER}-mysql    
    ;;
  *)
    echo "Unsupported Ubuntu Version."
    return 0
    ;;
  esac

  systemctl restart php"$PHPVER"-fpm

  if ( systemctl -q is-active php"$PHPVER"-fpm ); then
    echo "    PHP-FPM is running."
  else
    echo "    PHP-FPM is NOT running."
  fi
}
