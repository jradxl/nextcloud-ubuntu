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

[[ ${EUID} -ne 0 ]] && {
  printf "Must be run as root. Try 'sudo %s'\n", "$0"
  exit 1
}

# shellcheck source=/dev/null
source scripts/library.sh

install_app mariadb-test.sh
exit 0

export PATH="/usr/local/sbin:/usr/sbin:/sbin:${PATH}"
APTINSTALL="apt-get install -y --no-install-recommends"

# check installed software
type mysqld &>/dev/null && echo ">>> WARNING: existing mysqld configuration will be changed <<<"
type mysqld &>/dev/null && mysql -e 'use nextcloud' &>/dev/null && { echo "The 'nextcloud' database already exists. Aborting"; exit 1; }

rm -f /etc/apt/sources.list.d/mariadb.list.old*

# get dependencies
apt-get update

##Only EN, US and GB language-pack
$APTINSTALL language-pack-en locales git ca-certificates sudo lsb-release wget curl gnupg2 ubuntu-keyring apt-transport-https needrestart jq ssl-cert

##Inconvenient
apt-get -y purge needrestart
apt-get -y autoremove 

locale-gen en_GB.utf8 en_US.utf8

echo -e "\nInstalling NextCloud-Ubuntu..."


# check distro
check_distro etc/ncp.cfg || {
  echo "ERROR: distro not supported:";
  cat /etc/issue
  exit 1;
}

install_app    nginx.sh
install_app    php-fpm.sh
install_app    mariadb.sh

echo "UPGRADING..."
apt-get -y upgrade

echo "NEEDRESTART..."
#needrestart -ra
needrestart -b

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
