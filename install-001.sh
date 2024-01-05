#!/bin/bash

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
  #exit 1
}

##Temp Dir and contents must exist thru multiple invocations to aid development and debugging.
TEMPDIR="/tmp/nc-ubuntu"
mkdir -p "$TEMPDIR" || { echo "Failure to create temp dir." ; exit 1 ; }
echo "Temp Created: $TEMPDIR"
CODE_DIR_TMP="${TEMPDIR}"/nextcloud-ubuntu

##trap 'rm -rf \"${TEMPDIR}\"' 0 1 2 3 15

export PATH="/usr/local/sbin:/usr/sbin:/sbin:${PATH}"

# check installed software
type mysqld &>/dev/null && echo ">>> WARNING: existing mysqld configuration will be changed <<<"
type mysqld &>/dev/null && mysql -e 'use nextcloud' &>/dev/null && { echo "The 'nextcloud' database already exists. Aborting"; exit 1; }

# get dependencies
apt-get update
apt-get install --no-install-recommends -y git ca-certificates sudo lsb-release wget curl

# get install code for first time...
if [[ ! -f "$CODE_DIR_TMP/install.sh" ]]; then
  echo "Getting build code for first time..."
  #git clone -b "${BRANCH}" https://github.com/jradxl/nextcloud-ubuntu.git "${CODE_DIR_TMP}"
  git clone https://github.com/jradxl/nextcloud-ubuntu.git "${CODE_DIR_TMP}"
else
  echo "Code already downloaded, so checking for updates..."
  git pull
fi

cd "$CODE_DIR_TMP"

# install NCP
echo -e "\nInstalling NextCloud-Ubuntu..."
# shellcheck source=etc/library.sh
# shellcheck source=/dev/null
source etc/library.sh

# check distro
check_distro etc/ncp.cfg || {
  echo "ERROR: distro not supported:";
  cat /etc/issue
  exit 1;
}

exit 0

# indicate that this will be an image build
touch /.ncp-image

mkdir -p /usr/local/etc/ncp-config.d/
cp etc/ncp-config.d/nc-nextcloud.cfg /usr/local/etc/ncp-config.d/
cp etc/library.sh /usr/local/etc/
cp etc/ncp.cfg /usr/local/etc/

cp -r etc/ncp-templates /usr/local/etc/

##install_app    lamp.sh
#Linux. Nginx, MariaDB, PHP
install_app    lnmp.sh

##Check Nginx, PHP-FPM and MariaDB are running
install_app    bin/ncp/CONFIG/nc-nextcloud.sh
run_app_unsafe bin/ncp/CONFIG/nc-nextcloud.sh

rm /usr/local/etc/ncp-config.d/nc-nextcloud.cfg    # armbian overlay is ro

systemctl restart mysqld # TODO this shouldn't be necessary, but somehow it's needed in Debian 9.6. Fixme
install_app    ncp.sh
run_app_unsafe bin/ncp/CONFIG/nc-init.sh
echo 'Moving data directory to a more sensible location'
df -h
mkdir -p /opt/ncdata
[[ -f "/usr/local/etc/ncp-config.d/nc-datadir.cfg" ]] || {
  should_rm_datadir_cfg=true
  cp etc/ncp-config.d/nc-datadir.cfg /usr/local/etc/ncp-config.d/nc-datadir.cfg
}
DISABLE_FS_CHECK=1 NCPCFG="/usr/local/etc/ncp.cfg" run_app_unsafe bin/ncp/CONFIG/nc-datadir.sh
[[ -z "$should_rm_datadir_cfg" ]] || rm /usr/local/etc/ncp-config.d/nc-datadir.cfg
rm /.ncp-image

# skip on Armbian / Vagrant / LXD ...
[[ "${CODE_DIR}" != "" ]] || bash /usr/local/bin/ncp-provisioning.sh

cd -
rm -rf "${TEMPDIR}"

IP="$(get_ip)"

echo "Done.

First: Visit https://$IP/  https://nextcloudpi.local/ (also https://nextcloudpi.lan/ or https://nextcloudpi/ on windows and mac)
to activate your instance of NC, and save the auto generated passwords. You may review or reset them
anytime by using nc-admin and nc-passwd.
Second: Type 'sudo ncp-config' to further configure NCP, or access ncp-web on https://$IP:4443/
Note: You will have to add an exception, to bypass your browser warning when you
first load the activation and :4443 pages. You can run letsencrypt to get rid of
the warning if you have a (sub)domain available.
"

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