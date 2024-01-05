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

function configure_mariadb()
{
 # CONFIGURE LAMP FOR NEXTCLOUD
    ##########################################

    ##install_template "mysql/90-ncp.cnf.sh" "/etc/mysql/mariadb.conf.d/90-ncp.cnf" --defaults

    ##install_template "mysql/91-ncp.cnf.sh" "/etc/mysql/mariadb.conf.d/91-ncp.cnf" --defaults

  # launch mariadb if not already running
  #if ! [[ -f /run/mysqld/mysqld.pid ]]; then
   # echo "Starting mariaDB"
  #  mysqld &
  #fi

  # wait for mariadb
  while :; do
    [[ -S /run/mysqld/mysqld.sock ]] && break
    sleep 0.5
  done

DBPASSWD1=""
DBPASSWD2="secret"

  mysql_secure_installation <<EOF
$DBPASSWD1
y
$DBPASSWD2
$DBPASSWD2
y
y
y
y
EOF
}

##configure_mariadb
ask_mysql_password
echo "$rootpasswd"

}

function install_mariadb () {
    # Instalar mysql (mariadb), reiniciar, activar y ejecutar al inicio
    # Install mysql (mariadb), restart, activate and run at startup
        apt -y install expect

        SECURE_MYSQL=$(expect -c "
        set timeout 10
        spawn mysql_secure_installation
        expect \"Enter current password for root (enter for none):\"
        send \"${rootpasswd}\r\"
        expect \"Change the root password?\"
        send \"n\r\"
        expect \"Remove anonymous users?\"
        send \"y\r\"
        expect \"Disallow root login remotely?\"
        send \"y\r\"
        expect \"Remove test database and access to it?\"
        send \"y\r\"
        expect \"Reload privilege tables now?\"
        send \"y\r\"
        expect eof
        ")

        apt -y purge expect
        apt autoremove -y
    # Creación base datos, usuario, privilegios
    # Database creation, user, privileges
        mysql -uroot -p"${rootpasswd}" -e "CREATE DATABASE nextcloud;"
        mysql -uroot -p"${rootpasswd}" -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'admin'@'localhost' IDENTIFIED BY '${rootpasswd}';"
        mysql -uroot -p"${rootpasswd}" -e "FLUSH PRIVILEGES;"
}

function ask_mysql_password() {
        # Ask for password for the root user for Mysql and the same for the admin user for Nextcloud
        echo ""
        echo "Please enter a password to configure the admin user for Nextcloud and the root user for MySQL:"
        read -r -p "Root Password: " rootpasswd
}

MARIADB="/usr/bin/mariadb --defaults-file=/etc/mysql/debian.cnf"
MYADMIN="/usr/bin/mariadb-admin --defaults-file=/etc/mysql/debian.cnf"
# Don't run full mariadb-upgrade on every server restart, use --version-check to do it only once
MYUPGRADE="/usr/bin/mariadb-upgrade --defaults-extra-file=/etc/mysql/debian.cnf --version-check --silent"
MYCHECK="/usr/bin/mariadb-check --defaults-file=/etc/mysql/debian.cnf"
MYCHECK_SUBJECT="WARNING: mariadb-check has found corrupt tables"
MYCHECK_PARAMS="--all-databases --fast --silent"
MYCHECK_RCPT="${MYCHECK_RCPT:-root}"

##See /etc/mysql/debian-start
##See /usr/share/mysql/debian-start.inc.sh

#ALTER USER root@localhost IDENTIFIED VIA mysql_native_password;
#SET PASSWORD = PASSWORD('foo');
#GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED WITH unix_socket WITH GRANT OPTION;
# /root/.my.cnf
#[client]
#password=foo
#[mariadb]
#unix_socket=OFF
#disable_unix_socket

##Info only
#CREATE USER `mariadb.sys`@`localhost` ACCOUNT LOCK PASSWORD EXPIRE
#GRANT SELECT, DELETE ON `mysql`.`global_priv` TO `mariadb.sys`@`localhost`;
#mysql user with invalid as password is correct.

function check_root_accounts() {
  set -e
  set -u

  logger -p daemon.info -i -t"$0" "Checking for insecure root accounts."

  ret=$( echo "SELECT count(*) FROM mysql.user WHERE user='root' and password='' and plugin in ('', 'mysql_native_password', 'mysql_old_password');" | $MARIADB --skip-column-names )
  if [ "$ret" -ne "0" ]; then
    logger -p daemon.warn -i -t"$0" "WARNING: mysql.user contains $ret root accounts without password!"
  fi
}

