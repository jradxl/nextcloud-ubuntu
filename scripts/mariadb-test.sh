#!/bin/bash

test_status1() {
    mysqladmin status >/dev/null 2>/dev/null
    echo "$?"
}

test_status2() {
    mysqladmin -uroot -p"$DBROOTPW" status >/dev/null 2>/dev/null
    echo "$?"
}

install_script()
{
    echo "Testing Mariadb..."

    if [[ $(command -v mariadb) ]]; then
	echo "Mariadb is installed, proceding..."
    else
	echo "MariaDB is not installed."
        return 0
    fi

    ##This script crashes if Unix Socket Auth is OFF
    RET="$(trap test_status1 EXIT)"
    echo "TRAP RETURN1 is: <$RET>"

    RET="$(trap test_status2 EXIT)"
    echo "TRAP RETURN2 is: <$RET>"

    #echo "On dear..."
    #exit 0

    ##Test for Unix Socket
    trap RET="$(/usr/bin/mariadb -e 'FLUSH PRIVILEGES;')" EXIT
    echo "RETURN: $RET"
    echo "On dear..."

    #If password needed
    RET="$(/usr/bin/mariadb -u root -p$DBROOTPW -e 'FLUSH PRIVILEGES;')"
    echo "$RET"

    # check installed software
    type mysqld &>/dev/null && echo ">>> WARNING: existing mysqld configuration will be changed <<<"
    type mysqld &>/dev/null && mysql -e 'use nextcloud' &>/dev/null && { echo "The 'nextcloud' database already exists. Aborting"; exit 1; }

    return 0
}
