#!/bin/bash

#### SCRIPT PARAMETERS
#DEFAULT_SCRIPT_STATE="none"
#CURRENT_SCRIPT_STATE=${1:-$DEFAULT_SCRIPT_STATE}
#USER_HOME=$HOME
#USER_CURRENT_DISTRO=#env | grep XDG_CURRENT_DESKTOP | cut -d '=' -f 2-
#USER_CURRENT_DE=#env | grep XDG_CURRENT_DESKTOP | cut -d '=' -f 2-
#LOCAL_KERN_VERSION=#uname -v

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

while [ -n "$1" ]; do # while loop starts

  case "$1" in
  -a) echo "-a option passed" ;; # Message for -a option
  -b) echo "-b option passed" ;; # Message for -b optio
  -c) echo "-c option passed" ;; # Message for -c option
  *) echo "Option $1 not recognized" ;; # In case you typed a different option other than a,b,c

  esac
  shift

done
