#!/bin/bash
#
# NextCloud TEST installation script
#
# Usage: ./test-install.sh
#

BRANCH="${BRANCH:-main}"
#DBG=x

set -e"$DBG"

CWDDIR=$(pwd)

[[ ${EUID} -ne 0 ]] && {
  printf "Must be run as root. Try 'sudo %s'\n", "$0"
  exit 1
}

if [[ ! -f ./.env ]]; then
	echo "File .env does not exist. Exiting."
	exit 1
fi
source ./.env

if [[ ! -f ./scripts/library.sh ]]; then
	echo "Missing library.sh. Exiting"
	exit 1
fi
# shellcheck source=/dev/null
source ./scripts/library.sh

echo "CWDDIR: $CWDDIR"
echo "NCPCFG: $NCPCFG"
PHPVER=$(jq -r .php_version "$NCPCFG")

### PLACE YOUR INSTALL SCRIPT YOU ARE TESTING HERE
#scripts/nginx-conf.sh

install_app nginx-conf.sh

echo ""
echo "TEST FINISHED."
exit 0
