#!/bin/bash

##mysqladmin -u root -p ping 

test_status1() {
    mysqladmin status >/dev/null 2>/dev/null
    echo "$?"
}

test_status2() {
    mysqladmin -uroot -psecret status >/dev/null 2>/dev/null
    echo "$?"
}

test_status3() {
    mysqladmin -uroot -pwrong status >/dev/null 2>/dev/null
    echo "$?"
}

echo "Testing Mariadb for Unix Socket Auth off ..."

##Without TRAP this script crashes if Unix Socket Auth is OFF
RET="$(trap test_status1 EXIT)"
echo "TRAP RETURN1 is: <$RET>"

if [[ "$RET" == "127" ]]; then
    echo "Mariadb is not installed."
fi

if [[ "$RET" == "1" ]]; then
    echo "Mariadb's Unix Socket Auth is not installed or turned off."
fi

###

RET="$(trap test_status2 EXIT)"
echo "TRAP RETURN2 is: <$RET>"

if [[ "$RET" == "127" ]]; then
    echo "Mariadb is not installed."
fi

if [[ "$RET" == "1" ]]; then
    echo "Mariadb wrong password."
fi
###

RET="$(trap test_status3 EXIT)"
echo "TRAP RETURN3 is: <$RET>"

if [[ "$RET" == "1" ]]; then
    echo "Mariadb wrong password."
fi

if [[ "$RET" == "127" ]]; then
    echo "Mariadb is not installed."
fi
####

exit 0
