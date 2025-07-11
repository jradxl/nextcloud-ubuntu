#!/bin/bash

APTREPOSITORY="add-apt-repository -y"
export DEBIAN_FRONTEND=noninteractive

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
    sleep 1
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

function mariadb_create_account() {

    ## Secure Mariadb

    ##Test for Unix Socket
    RET="$(/usr/bin/mariadb -e 'FLUSH PRIVILEGES;')"
    echo "$RET"

    DBROOTPW="secret"
    #If password needed
    RET="$(/usr/bin/mariadb -u root -p$DBROOTPW -e 'FLUSH PRIVILEGES;')"
    echo "$RET"

    exit 0

    #1. Set password

    #2. Remove anonymous users

    #3. Disallow remote root login users

    #4. Remove Test DB and access

    #5. Reload Privilege table


    # Nextcloud Database creation, user, and privileges
    # No password needed with Socket Auth
    mariadb -e "CREATE DATABASE nextcloud;"
    mariadb -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'admin'@'localhost' IDENTIFIED BY '${rootpasswd}';"
    mariadb -e "FLUSH PRIVILEGES;"

}

function check_root_accounts() {
  #Check for Unix Socket Auth so this script can access MariaDB without root password.
  #If not Unix Socket Auth and there is no password, do all config before creating one.
  #If already Root password and is not given to this script, do no config.
  #Check for No password root account, and 

  CMD0="SELECT * FROM blah WHERE foo='bar';"
  CMD1="SELECT count(*) FROM mysql.user WHERE user='root' and password='';"
  CMD2="SELECT count(*) FROM mysql.user WHERE user='root' and password='' and plugin in ('', 'mysql_native_password', 'mysql_old_password') ;"

  echo "    Test for any root accounts..."
  RET=$(/usr/bin/mariadb -sse  "$CMD1")
  if [[ "$RET" -ne "0" ]]; then
    printf "    MariaDB has %s Root accounts with ", "$RET"
  else
    printf "    MariaDB has no Root accounts at all"
  fi
  echo ""
  echo "    Test for any root accounts with plugins..."
  RET=$(/usr/bin/mariadb -sse  "$CMD2")
  if [[ "$RET" -ne "0" ]]; then
    printf "    MariaDB has %s Root accounts with ", "$RET"
  else
    printf "    MariaDB has no Root accounts at all"
  fi
  echo ""
}

install_script()
{
  echo "Installing MariaDB..."

  MARIADBVERSION=$(jq -r .mariadbversion "$NCPCFG")
  UBUNTUVERSION=$(lsb_release -cs)

  rm -f $(compgen -G "/etc/apt/sources.list.d/mariadb.list.old*")

  case "$UBUNTUVERSION" in
  "noble")
    curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="$MARIADBVERSION"
    ## $APTINSTALL mariadb-server galera-4 mariadb-client libmariadb3 mariadb-backup mariadb-common
    $APTINSTALL mariadb-server mariadb-backup
    ;;
  "plucky")
    echo "NOTICE: Installing MariaDB from the Ubuntu Repo"
    $APTINSTALL mariadb-server mariadb-backup
    ;;
  *)
    echo "Unsupported Ubuntu Version."
    return 0
    ;;
  esac

  systemctl restart mariadb

  if ( systemctl -q is-active mariadb ); then
    echo "    Mariadb is running."
  else
    echo "    Mariadb is NOT running."
  fi

  echo "    Checking ROOT accounts..."
  check_root_accounts
}
