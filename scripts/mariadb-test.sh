#!/bin/bash


test_status1() {
    mysqladmin status >/dev/null 2>/dev/null
    echo "$?"
}

test_status2() {
    mysqladmin -uroot -psecret status >/dev/null 2>/dev/null
    echo "$?"
}

install_script()
{
    echo "Testing Mariadb..."

    ##This script crashes if Unix Socket Auth is OFF
    RET="$(trap test_status1 EXIT)"
    echo "TRAP RETURN1 is: <$RET>"

    RET="$(trap test_status2 EXIT)"
    echo "TRAP RETURN2 is: <$RET>"

    echo "On dear..."

    exit 0

    ##Test for Unix Socket
    trap RET="$(/usr/bin/mariadb -e 'FLUSH PRIVILEGES;')" EXIT
    echo "RETURN: $RET"
    echo "On dear..."
  

    DBROOTPW="secret"
    #If password needed
    RET="$(/usr/bin/mariadb -u root -p$DBROOTPW -e 'FLUSH PRIVILEGES;')"
    echo "$RET"

    return 0
}
