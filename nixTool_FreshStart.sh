#!/bin/bash

#### SCRIPT PARAMETERS
DEFAULT_SCRIPT_STATE="none"
CURRENT_SCRIPT_STATE=${1:-$DEFAULT_SCRIPT_STATE}
USER_HOME=$HOME

if [ "${CURRENT_SCRIPT_STATE}" == dev ]; then
  set -e
fi

#### FUNCTIONS DECLARED

# Bring system up-to-date
system_Refresh() {
  apt -qq update
  apt -qq upgrade -y
  apt -qq autoremove -y
}

# Prepare directories to be used by script
prep_CreateScriptDirs() {
  mkdir -p "${USER_HOME}"/Downloads/Sandbox/
  mkdir -p "${USER_HOME}"/.local/bin/
  cp /etc/apt/sources.list /etc/apt/sources.list.bak
  cd "${USER_HOME}"/Downloads/Sandbox/ || {
    echo "Could not reach 'Sandbox' directory. Exiting Script."
    exit 1
  }
}

# Remove temp directory created in prep_CreateScripDirs
prep_ClearScriptDirs() {
  cd ~/ || {
    echo "Could not reach 'home' directory. Exiting Script."
    exit 1
  }
  rm -rf "${USER_HOME}"/Downloads/Sandbox/
}

# Prepare Virtual Box Install
prep_VBox() {
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc
  apt-key add oracle_vbox_2016.asc
  add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
}

# Install JetBrains Toolbox App
install_JBToolbox() {
  wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.16.6207.tar.gz
  tar -xzf jetbrains-toolbox-1.16.6207.tar.gz
  mv jetbrains-toolbox-1.16.6207/jetbrains-toolbox "${USER_HOME}"/.local/bin/
  rm -rf jetbrains-toolbox-1.16.6207.tar.gz
}

# Apply Audio sink to fix Microphone-Speaker Echo
fix_PulseAudioEcho() {
  # Implement nessecity check before running
  echo 'load-module module-echo-cancel source_name=logitechsource' >>/etc/pulse/default.pa
  echo 'set-default-source logitechsource' >>/etc/pulse/default.pa
}

# Apply fix for screen tearing on systems with intel-gpu
fix_IntelScreenTear() {
  # Implement nessecity check before running
  # This requires a check for dir&file in question
  # This requires a check textstring echoed into file
  mkdir -p /etc/X11/xorg.conf.d/
  echo 'Section "Device"
     Identifier  "Intel Graphics"
     Driver      "intel"
     Option      "TearFree"    "true"
  EndSection' >>/etc/X11/xorg.conf.d/20-intel.conf
}

# Set Git VCS global username and email
config_GitIdent() {
  local gitUser gitEmail
  local CONFIRM_STATE=0

  while [ "${CONFIRM_STATE}" == 0 ]; do

    printf "\nPlease enter a username and email address to document your Git commits.\n"
    read -rp "Username: " gitUser && read -rp "Email Address: " gitEmail
    printf "\n"
    git config --global user.name "${gitUser}"
    git config --global user.email "${gitEmail}"
    git config --list | grep user

    echo "Is this the correct Username and Email?"
    select yn in "Yes" "No"; do
      case $yn in
      Yes)
        CONFIRM_STATE=1
        break
        ;;
      No) break ;;
      esac
    done

  done
}

config_FreshSystem() {
  #### SCRIPT START ####
  system_Refresh

  # Preperation Functions
  prep_CreateScriptDirs # Check permissions on created directories
  prep_VBox             # Update links/Stop relying on links

  # Requested Package Section
  install_JBToolbox # Update links/Stop relying on links

  # Mass Package Installation
  apt -qq update && sleep 3
  apt install wget snapd steam-installer neofetch exfat-fuse exfat-utils -y
  apt install nmap deluge htop arc-theme -y
  apt install python3-distutils python3-pip libavcodec-extra -y
  apt install virtualbox-6.1 virtualbox-guest-x11 virtualbox-guest-utils virtualbox-guest-dkms -y
  apt install gnome-tweak-tool gnome-shell-extensions chrome-gnome-shell -y

  ## Install Snap Packages
  #snap install spotify
  #snap install atom --classic

  # Hotfixes
  fix_PulseAudioEcho
  fix_IntelScreenTear

  # Wrap up Installation

  ## Delete Sandbox directory
  prep_ClearScriptDirs

  ## Required User Interaction
  #
  #

  ## Final System Check
  system_Refresh
  clear && neofetch
}

# UGLY: Experiment with test/switch/case to streamline this
script_Main() {
  if [ "${CURRENT_SCRIPT_STATE}" != "${DEFAULT_SCRIPT_STATE}" ]; then
    while [ "${CURRENT_SCRIPT_STATE}" != "${DEFAULT_SCRIPT_STATE}" ]; do

      while [ "${CURRENT_SCRIPT_STATE}" == dev ]; do
        echo "CURRENT_SCRIPT_STATE = '${CURRENT_SCRIPT_STATE}'"
        config_GitIdent
        CURRENT_SCRIPT_STATE=none
        echo "CURRENT_SCRIPT_STATE = '${CURRENT_SCRIPT_STATE}'"
      done

      while [ "${CURRENT_SCRIPT_STATE}" == prod ]; do
        config_FreshSystem
        CURRENT_SCRIPT_STATE="${DEFAULT_SCRIPT_STATE}"
      done

    done
  else
    echo "Invalid SCRIPT_STATE '${CURRENT_SCRIPT_STATE}'"
    echo " Exiting Script"
  fi
}

script_Main