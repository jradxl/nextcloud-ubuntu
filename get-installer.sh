#!/bin/bash

# NextCloud For Ubuntu installation script
#
# Based on: NextcloudPi
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Must be run as root user.
# Usage:
#    sudo -i
#    mkdir -p /root/somewhere 
#    curl -sSL https://raw.githubusercontent.com/jradxl/nextcloud-ubuntu/main/get-installer.sh | sudo bash
#    cd ./nextcloud-ubuntu
#    ./install.sh
#

BRANCH="${BRANCH:-main}"
#DBG=x

set -e"$DBG"

[[ ${EUID} -ne 0 ]] && {
  printf "Must be run as root. Try 'sudo %s'\n", "$0"
  exit 1
}

if [[ -f "./install.sh"  ]]; then
  echo "Do not run get-installer.sh from within the project directory."
  exit 1
fi

APTINSTALL="apt-get install -y --no-install-recommends"

apt-get -y update
$APTINSTALL git
apt-get -y upgrade

git clone -b "${BRANCH}" https://github.com/jradxl/nextcloud-ubuntu.git 
RET="$?"
if [[ $RET = "0" ]]; then
  echo "SUCCESS: Now change to the project directory created, <nextcloud-ubuntu> and run ./install.sh"
  exit 0
else
  echo "FAILED, sorry!"
  exit 1
fi

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
