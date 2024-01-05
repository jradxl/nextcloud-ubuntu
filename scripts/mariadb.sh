#!/bin/bash

APTINSTALL="apt-get install -y --no-install-recommends"
APTREPOSITORY="add-apt-repository -y"
export DEBIAN_FRONTEND=noninteractive

install_script()
{
  echo "Installing MariaDB..."
  #curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --help
  
  echo "    Adding Repositories and Keys for Mariadb..."
  curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=10.6
  echo "    Installing Mariadb..."
  rm -f /etc/apt/sources.list.d/mariadb.list.old*

  $APTINSTALL mariadb-server mariadb-backup mariadb-tools
  
  systemctl restart mariadb

  rm -f /etc/apt/sources.list.d/mariadb.list.old*

  if ( systemctl -q is-active mariadb ); then
    echo "Mariadb is running."
  else
    echo "Mariadb is NOT running."
  fi

}
