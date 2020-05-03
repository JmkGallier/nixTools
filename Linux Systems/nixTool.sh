#!/bin/bash
set -e
set -o pipefail

#### OPTION PARAMETERS
declare -A SCRIPT_STATE_OPTIONS
declare -A IS_VIRTUAL_ENV_OPTIONS
declare -A DESKTOP_ENV_OPTIONS
SCRIPT_STATE_OPTIONS=(
  ["none"]=1
  ["test"]=1
  ["dev"]=1
  ["prod"]=1
  ["sys_upgrade"]=1
  ["git_config"]=1
  ["fresh_install"]=1
)
DESKTOP_ENV_OPTIONS=(
  ["gnome"]=1
  ["xfce"]=1
)
IS_VIRTUAL_ENV_OPTIONS=(["guest"]=1 ["host"]=1)


#### USER STATE
# Some Linux OSes such as Raspbian have default users (i.e. "pi") with no
# user name set in environment variables. Create a software catch for this
# anomaly.
OS_RELEASE=$(lsb_release -cs)
SCRIPT_USER="$(logname)"
SCRIPT_OWNER="$USER"
USER_HOME="/home/${SCRIPT_USER}"


# !X! Correct SubShell Errors
#USER_CURRENT_DE=$(env | grep XDG_CURRENT_DESKTOP | cut -d ':' -f 2-)
#USER_CURRENT_DISTRO=$(env | grep XDG_CURRENT_DESKTOP | cut -d '=' -f 2- | cut -d ':' -f -1)
#ENV_IS_GNOME=$([ "$USER_CURRENT_DE" = "GNOME" ] && echo "true" || echo "false")

#### SCRIPT STATE
DEFAULT_SCRIPT_STATE="none"
CURRENT_SCRIPT_STATE="none"
USER_IS_ROOT=$([ "$SCRIPT_OWNER" = "root" ] && echo "true" || echo "false")
IS_VIRTUAL_ENV="host"

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
  -DE) DESKTOP_ENV="$2"
    if [[ ${DESKTOP_ENV_OPTIONS[$DESKTOP_ENV]} ]]; then :
    else
      echo "${DESKTOP_ENV} is not a valid option"
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
  add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian ${OS_RELEASE} contrib"
}

# Install JetBrains Toolbox App
install_JBToolbox() {
  # Update links/Stop relying on links
  wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.17.6802.tar.gz
  tar -xzf jetbrains-toolbox-*.tar.gz
  rm -rf jetbrains-toolbox-*.tar.gz
  mv -v jetbrains-toolbox-*/* "${USER_HOME}"/.local/bin/
  rm -rf jetbrains-toolbox-*
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

install_AptPackages() {
  local packages_arr=()

  # Restrict VBox packages from being install in guest installs
  if [ "${IS_VIRTUAL_ENV}" = "host" ]; then
    prep_VBox
    packages_arr=("${packages_arr[@]}" "${VBOX_PACKAGE_SET[@]}")
  fi

  # Restrict Gnome Extension packages to Gnome installations
  if [ "${DESKTOP_ENV}" = "gnome" ]; then
    packages_arr=("${packages_arr[@]}" "${GNOME_EXT_PACKAGE_SET[@]}")
  fi

  # Add all other packages (Milestone -> Dialog Window)
  packages_arr=(
  "${packages_arr[@]}"
  "${INDIVIDUAL_PACKAGES[@]}"
  "${EXFAT_PACKAGE_SET[@]}"
  "${MULTIMEDIA_PACKAGE[@]}"
  "${THEME_PACKAGES[@]}"
  "${PYTHON_IDE_PACKAGE_SET[@]}"
  )

  apt install "${packages_arr[@]}" -y
}

# Preform basic installations for Fresh Installations
config_FreshSystem() {
  #System Handlers
  system_Refresh
  prep_CreateScriptDirs

  # Requested Package Section (Prep-Req)
  install_JBToolbox

  # Mass Package Installation
  apt -qq update
  install_AptPackages

  ## Install Snap Packages
  #snap install spotify
  #snap install atom --classic

  ## Delete Sandbox directory
  prep_ClearScriptDirs

  ## Final System Check
  system_Refresh
  clear && neofetch
}

script_Main() {
  while [ "${CURRENT_SCRIPT_STATE}" != "${DEFAULT_SCRIPT_STATE}" ]; do

    ## Create System Status function
    ## includes all options and current parameters

    case $CURRENT_SCRIPT_STATE in
      test)
        echo "Script State: ${CURRENT_SCRIPT_STATE}"
        echo "${SCRIPT_OWNER}"
        echo "${USER_IS_ROOT}"
        CURRENT_SCRIPT_STATE="none"
        ;;
      dev)
        echo "Script State: ${CURRENT_SCRIPT_STATE}"
        CURRENT_SCRIPT_STATE="none"
        ;;
      sys_upgrade)
        case $USER_IS_ROOT in
        true)
          echo "Script State: ${CURRENT_SCRIPT_STATE}"
          system_Refresh
          CURRENT_SCRIPT_STATE="none"
          ;;
        false)
          echo "Please use sudo when performing sys_upgrade"
          CURRENT_SCRIPT_STATE="none"
          ;;
        esac
        ;;
      git_config)
        echo "Script State: ${CURRENT_SCRIPT_STATE}"
        config_GitIdent
        CURRENT_SCRIPT_STATE="none"
        ;;
      fresh_install)
        case $USER_IS_ROOT in
          true)
            echo "Script State: ${CURRENT_SCRIPT_STATE}"
            config_FreshSystem
            CURRENT_SCRIPT_STATE="none"
            ;;
          false)
            echo "Please use sudo when performing fresh_install"
            CURRENT_SCRIPT_STATE="none"
            ;;
        esac
        ;;
      *)
        echo "Invalid Script State: ${CURRENT_SCRIPT_STATE}"
        CURRENT_SCRIPT_STATE="none"
        ;;
    esac
  done
}

script_Main
