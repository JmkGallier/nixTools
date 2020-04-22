#!/bin/bash
set -e
set -o pipefail

#### SCRIPT PARAMETERS
declare -A SCRIPT_STATE_OPTIONS
declare -A IS_VIRTUAL_ENV_OPTIONS
SCRIPT_STATE_OPTIONS=(
  ["none"]=1
  ["test"]=1
  ["dev"]=1
  ["prod"]=1
  ["sys_upgrade"]=1
  ["git_config"]=1
  ["fresh_install"]=1
)

IS_VIRTUAL_ENV_OPTIONS=(["guest"]=1 ["host"]=1)

#### SCRIPT STATE
DEFAULT_SCRIPT_STATE="none"
CURRENT_SCRIPT_STATE="none"
IS_VIRTUAL_ENV="host"

#### USER PARAMETERS
SCRIPT_USER="$(logname)"
USER_HOME="/home/${SCRIPT_USER}"

#### INSTALLATION PACKAGES
### PACKAGE LIBRARIES
INDIVIDUAL_PACKAGES=(wget snapd steam-installer neofetch nmap deluge htop)
EXFAT_PACKAGE_SET=(exfat-fuse exfat-utils)
MULTIMEDIA_PACKAGE=(libavcodec-extra)
THEME_PACKAGES=(arc-theme)
PYTHON_IDE_PACKAGE_SET=(python3-distutils python3-pip)
VBOX_PACKAGE_SET=(virtualbox-6.1 virtualbox-guest-x11 virtualbox-guest-utils virtualbox-guest-dkms)
GNOME_EXT_PACKAGE_SET=(gnome-tweak-tool gnome-shell-extensions chrome-gnome-shell)

#### Option Input
while [ -n "${1-}" ]; do
  case "$1" in
  -s) CURRENT_SCRIPT_STATE="$2"
    if [[ ${SCRIPT_STATE_OPTIONS[$CURRENT_SCRIPT_STATE]} ]]; then :
    else
      echo "${CURRENT_SCRIPT_STATE} is not a valid option"
      CURRENT_SCRIPT_STATE="none"
    fi
      ;;
  -v) IS_VIRTUAL_ENV="$2"
    if [[ ${IS_VIRTUAL_ENV_OPTIONS[$IS_VIRTUAL_ENV]} ]]; then :
    else
      echo "${IS_VIRTUAL_ENV} is not a valid option"
      CURRENT_SCRIPT_STATE="none"
    fi
    ;;
  --) shift ; break ;;
  esac
  shift
done

#### FUNCTIONS DECLARED

# Bring system up-to-date
system_Refresh() {
  apt -qq update
  apt -qq upgrade -y
  apt -qq autoremove -y
}

# Prepare directories to be used by script
# Check permissions on created directories
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
  # Update links/Stop relying on links
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc
  apt-key add oracle_vbox_2016.asc
  add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
}

# Install JetBrains Toolbox App
install_JBToolbox() {
  # Update links/Stop relying on links
  wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.16.6207.tar.gz
  tar -xzf jetbrains-toolbox-1.16.6207.tar.gz
  mv jetbrains-toolbox-1.16.6207/jetbrains-toolbox "${USER_HOME}"/.local/bin/
  rm -rf jetbrains-toolbox-1.16.6207.tar.gz
}

# Apply Audio sink to fix Microphone-Speaker Echo
fix_PulseAudioEcho() {
  # Implement necessity check before running
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

    printf "Are the details above correct?\n"
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

# Preform basic installations for Fresh System
config_FreshSystem() {
  #System Handlers
  system_Refresh
  prep_CreateScriptDirs

  # Requested Package Section (Prep-Req)
  install_JBToolbox
  prep_VBox

  # Mass Package Installation
  # use Dialog to handle package selection
  # Use IS_VIRTUAL_ENV to exclude/include virtualbox packages
  apt -qq update && sleep 3
  apt install wget snapd steam-installer neofetch exfat-fuse exfat-utils -y
  apt install nmap deluge htop arc-theme -y
  apt install python3-distutils python3-pip libavcodec-extra -y
  apt install virtualbox-6.1 virtualbox-guest-x11 virtualbox-guest-utils virtualbox-guest-dkms -y
  apt install gnome-tweak-tool gnome-shell-extensions chrome-gnome-shell -y

  ## Install Snap Packages
  #snap install spotify
  #snap install atom --classic

  ## Hotfixes
  fix_PulseAudioEcho
  fix_IntelScreenTear

  ## Delete Sandbox directory
  prep_ClearScriptDirs

  ## Final System Check
  system_Refresh
  clear && neofetch
}

script_Main() {
  while [ "${CURRENT_SCRIPT_STATE}" != "${DEFAULT_SCRIPT_STATE}" ]; do
    case $CURRENT_SCRIPT_STATE in
      test)
        echo "Script State: ${CURRENT_SCRIPT_STATE}"
        echo "${SCRIPT_USER}"
        echo "${USER_HOME}"
        CURRENT_SCRIPT_STATE="none"
        ;;
      dev)
        echo "Script State: ${CURRENT_SCRIPT_STATE}"
        CURRENT_SCRIPT_STATE="none"
        ;;
      sys_upgrade)
        echo "Script State: ${CURRENT_SCRIPT_STATE}"
        system_Refresh
        CURRENT_SCRIPT_STATE="none"
        ;;
      git_config)
        echo "Script State: ${CURRENT_SCRIPT_STATE}"
        config_GitIdent
        CURRENT_SCRIPT_STATE="none"
        ;;
      fresh_install)
        echo "Script State: ${CURRENT_SCRIPT_STATE}"
        config_FreshSystem
        CURRENT_SCRIPT_STATE="none"
        ;;
      *)
        echo "Invalid Script State: ${CURRENT_SCRIPT_STATE}"
        CURRENT_SCRIPT_STATE="none"
        ;;
    esac
  done
}

script_Main