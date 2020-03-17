#!/bin/bash
set -e
set -u
set -o pipefail

#### SCRIPT PARAMETERS

declare -A SCRIPT_STATE_OPTIONS
SCRIPT_STATE_OPTIONS=([none]=0 [test]=1 [dev]=1 [prod]=1)
DEFAULT_SCRIPT_STATE="none"
CURRENT_SCRIPT_STATE="${DEFAULT_SCRIPT_STATE}"
IS_VIRTUAL_ENV=false

#USER_HOME=$HOME
#USER_CURRENT_DISTRO=#env | grep XDG_CURRENT_DESKTOP | cut -d '=' -f 2-
#USER_CURRENT_DE=#env | grep XDG_CURRENT_DESKTOP | cut -d '=' -f 2-
#LOCAL_KERN_VERSION=#uname -v


#### Option Input
while [ -n "${1-}" ]; do

  case "$1" in
  -s) CURRENT_SCRIPT_STATE="$2" ;; # Options are dev/prod/none
  -v) IS_VIRTUAL_ENV="$2" ;; # Options are true/false
  --) shift ; break ;;

  esac
  shift

done

#### Option Checks USE CASE
if [[ ${SCRIPT_STATE_OPTIONS[$CURRENT_SCRIPT_STATE]} ]]; then
  echo "${CURRENT_SCRIPT_STATE} in array"
else
  echo
    echo "${CURRENT_SCRIPT_STATE} not in ${SCRIPT_STATE_OPTIONS[*]}"
fi

# Install Targets/List !#
# User Input/Variables !#

#### Future Improvements:
## Docker, PIA(include installer w/script), wine + winetricks +
## arduino + Xsane + Bethesda Launcher + Rockstar Games + Arduino IDE
## Antivirus/Rootkit, Linux Security Fixes
## Split Install options into categories WebBrowsing/Gaming/SoftDev/VPN/Media-Entertainment
## Make Python helper Class to handle GNU->BSD compatibility issues

### Experimental implementations

## - Prepare BalenaEtcher Installation -
#echo "deb https://deb.etcher.io stable etcher" | tee /etc/apt/sources.list.d/balena-etcher.list
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
#apt -qq update
#apt install balena-etcher-electron
# - -

## - Install Temp/Package/Compatibility software -
#apt install lm-sensors hddtemp -y
#sensors-detect
#sensors
#apt install psensor
# - -
