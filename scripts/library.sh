#!/bin/bash

## FUNCTION LIBRARY ##
# Parts Originally From: NextCloudPi function library
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#

CURDIR="$(pwd)"
#NCPCFG="$CURDIR/etc/ncp.cfg"
NCPCFG="$CURDIR/.ncp.cfg"
APTINSTALL="apt-get install -y --no-install-recommends"

function check_distro()
{
  local cfg="${1:-$NCPCFG}"
  local supported=$(jq -r .release "$cfg")
  #TODO check value in case of pasing error
  grep -q "$supported" <(lsb_release -sc) && return 0
  return 1
}

function install_app()
{
  local ncp_app=$1
  ##Prepare absolute path
  script="$CURDIR/scripts/$ncp_app"
  # do it
  unset install_script
# shellcheck source=/dev/null
  . "${script}"
  (install_script)
}

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
