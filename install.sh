#!/bin/bash
#
# NextCloudPi installation script
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./install.sh
#
# more details at https://ownyourbits.com

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

echo "Installing Dependancies..."

# get dependencies
apt-get update
#echo "UPGRADING..."
apt-get -y upgrade
# #Only EN, US and GB language-pack
$APTINSTALL language-pack-en locales git ca-certificates sudo lsb-release wget curl gnupg2 ubuntu-keyring apt-transport-https jq ssl-cert software-properties-common

##Inconvenient
apt-get -y purge needrestart
apt-get -y autoremove 

# calling check distro in scripts/library.sh
check_distro  || {
  echo "ERROR: distro not supported:";
  cat /etc/issue
  exit 1;
}

# calling  scripts/mariadb-test.sh
######  install_app mariadb-test.sh

#export PATH="/usr/local/sbin:/usr/sbin:/sbin:${PATH}"

#rm -f /etc/apt/sources.list.d/mariadb.list.old*
rm -f $(compgen -G "/etc/apt/sources.list.d/mariadb.list.old*")

locale-gen en_GB.utf8 en_US.utf8
echo -e "\nInstalling NextCloud-Ubuntu..."

install_app    nginx.sh
install_app    php-fpm.sh

# calling  scripts/mariadb-test.sh
#install_app    mariadb-test.sh
install_app    mariadb.sh

#echo "NEEDRESTART..."
#needrestart -ra
#needrestart -b

echo ""
echo "FINISHED."
exit 0

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA
