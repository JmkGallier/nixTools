#!/bin/bash

# Environment Variables
#USER_HOME=$HOME
#USER_CURRENT_DISTRO=#env | grep XDG_CURRENT_DESKTOP | cut -d '=' -f 2-
#USER_CURRENT_DE=#env | grep XDG_CURRENT_DESKTOP | cut -d '=' -f 2-
#LOCAL_KERN_VERSION=#uname -v

# Install Targets
# User Variables

# "Is correct?"
input_checkResp () {
  # $1 is initial conditional statement to be answered by this function.
  local conditional_resp
  read -rp "${1}" conditional_resp
  if [ "${conditional_resp,}" == "n" ]; then
    echo 0
  elif [ "${conditional_resp,}" == "y" ]; then
    echo 1
  else
    input_checkResp "$1"
  fi
}

# Git Config function
gitConfig () {
  user_confirm=0
  user_condit="Is the above Git Config Correct? [Y/n]"

  printf "Hello, %s\nPlease enter a username and email address to document your Git commits.\n" "${USER}"
  read -rp "Username: " var1
  read -rp "Email Address: " var2
  printf "\n"
  git config --global user.name "${var1}"
  git config --global user.email "${var2}"
  git config --list | grep user

  while [ "${user_confirm}" == 0 ]; do
    user_resp=$(input_checkResp "${user_condit}") ##figure out assigning value of func
    user_confirm=$user_resp

    if [ "${user_confirm}" == 0 ]; then
      gitConfig
    elif [ "${user_confirm}" == 1 ]; then
      echo "Git Identity Saved (Globally)"
    else
      echo "Failure at gitConfig()>input_checkResp()"
      exit 1;
    fi
  done
}

## Future Improvements:
## Docker, PIA(include installer w/script), wine + winetricks + arduino + Xsane + Bethesda Launcher + Rockstar Games + Arduino IDE
## Antivirus/Rootkit, Linux Security Fixes
## Add Bash expects for Y/n and keep maintainer pkg

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
