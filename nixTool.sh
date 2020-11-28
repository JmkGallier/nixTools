#!/bin/bash
set -e
set -o pipefail

### OPTION PARAMETERS
# Declare Script State options
# shellcheck disable=SC2034
declare -A SCRIPT_STATE_OPTIONS=(
  ["none"]=1
  ["dev"]=1
  ["System"]=1
  ["Patch"]=1
  ["Config"]=1
)

# Declare System options
# shellcheck disable=SC2034
declare -A SCRIPT_SYSTEM_OPTIONS=(
  ["Fresh"]=1
  ["Upgrade"]=1
  ["DeskEnv"]=1
  ["test"]=1
)

# Declare Path options
# shellcheck disable=SC2034
declare -A SCRIPT_PATCH_OPTIONS=(
  ["intel-screen-tearing"]=1
  ["pulseaudio-echo"]=1
  ["test"]=1
)

# Declare Config options
# shellcheck disable=SC2034
declare -A SCRIPT_CONFIG_OPTIONS=(
  ["git_config"]=1
  ["nixconf"]=1
  ["test"]=1
)

# Declare Desktop Environment options
# shellcheck disable=SC2034
declare -A DESKTOP_ENV_OPTIONS=(
  ["gnome"]=1
  ["xfce"]=1
)

error_invalidOptions() {
  echo "[ERROR] $1 Not a valid argument for ${SCRIPT_CURRENT_STATE}"
  printf "[INFO] Exiting Script...\n"
  exit 1
}

# Script Exit for invalid options
error_InvalidDriver() {
  echo "[ERROR] Script State ' ${SCRIPT_CURRENT_STATE} ' does not have option ' ${SCRIPT_DRIVER_STATE} ' Try ./nixTools.sh --help"
  printf "[INFO] Exiting Script...\n"
  exit 1
}

check_ScriptDriver() {
  local -n CHECK_ARRAY=$1
  if [[ ${CHECK_ARRAY[$SCRIPT_DRIVER_STATE]} ]]; then
    return 0
  else
    error_invalidOptions CHECK_ARRAY
  fi
}


#### SYSTEM/USER/SCRIPT STATE # Basis for .conf
SYSTEM_DISTRIBUTION="${DESKTOP_SESSION}" || echo "Use 'sudo -E <command>'." # Can be deprecated after .conf file
OS_RELEASE=$(lsb_release -cs)
SYSTEM_DESKTOP=$(echo "$XDG_CURRENT_DESKTOP" | cut -d ":" -f 2-)
SYSTEM_IS_VIRTUAL="false"

SCRIPT_USER=$(printf '%s\n' "${SUDO_USER:-$USER}")
SCRIPT_CALLER="$USER"
USER_HOME="/home/${SCRIPT_USER}"
SCRIPT_CURRENT_STATE="none"
USER_IS_ROOT="$([ "$(id -u)" -eq 0 ] && echo "true" || echo "false")"
SANDBOX_DIR="${USER_HOME}/Downloads/Sandbox/" # Change Sandbox prefix /opt/nixtools/ # Requires all downloads explicitly pointed to /opt/nixtools
NIXTOOL_CONF="../etc/nixTool_sys.conf"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SCRIPT_ROOT="$(cd "$(dirname "${SCRIPT_DIR}")" && pwd)"
SCRIPT_FILE="${SCRIPT_DIR}/$(basename "${BASH_SOURCE[0]}")"
SCRIPT_BASE="$(basename "${SCRIPT_FILE}")"
SCRIPT_DRIVER_STATE="none"
SCRIPT_DEFAULT_STATE="none"
SCRIPT_EXIT_STATE="exit"
SCRIPT_TMP_DIR="${SCRIPT_DIR}/tmp"
SCRIPT_ETC_DIR="${SCRIPT_DIR}/etc"
SCRIPT_VAR_DIR="${SCRIPT_DIR}/var"
SCRIPT_USR_DIR="${SCRIPT_DIR}/usr"
SCRIPT_BAK_DIR="${SCRIPT_DIR}/bak"

#### INSTALLATION PACKAGES
### PACKAGE LIBRARIES
## These are loaded in every use of this script, consider reading in from separate file
INDIVIDUAL_PACKAGES=(wget snapd steam-installer neofetch nmap deluge htop)
EXFAT_PACKAGE_SET=(exfat-fuse exfat-utils)
MULTIMEDIA_PACKAGE=(libavcodec-extra)
THEME_PACKAGES=(arc-theme)
PYTHON_IDE_PACKAGE_SET=(python3-distutils python3-pip)
VBOX_PACKAGE_SET=(virtualbox-6.1 virtualbox-guest-x11 virtualbox-guest-utils virtualbox-guest-dkms)
GNOME_EXT_PACKAGE_SET=(gnome-tweak-tool gnome-shell-extensions chrome-gnome-shell)

#### Option Input
while [ "${SCRIPT_CURRENT_STATE}" == "none" ]; do
  case "$1" in
  System)
    SCRIPT_CURRENT_STATE="$1"
    SCRIPT_DRIVER_STATE="${2:-"None"}"
    shift

    check_ScriptDriver SCRIPT_SYSTEM_OPTIONS && shift

    while [ -n "${1-}" ]; do
      case "$1" in
      -v) # Virtual Flag
        SYSTEM_IS_VIRTUAL="true"
        shift
        ;;
      --DE-install)
        # This enables the installation of a desktop environment
        # Must Accept parameter (supported DE)
        # Include test for $2 in supported DE and assign var || exit script
        echo "Feature not available"
        ;;
      --de)
        DESKTOP_ENV="$2"
        # This Param option is for explicitly stating the desktop environment when necessary
        check_ScriptDriver DESKTOP_ENV_OPTIONS && shift
        shift
        ;;
      *)
        error_invalidOptions "${1}"
        ;;
      esac
    done
    ;;
  Patch)
    printf "Patch is not supported in nixTool-main and has not implemented any patches."
    SCRIPT_CURRENT_STATE="$1"
    SCRIPT_DRIVER_STATE="${2:-"None"}"
    shift
    check_ScriptDriver SCRIPT_PATCH_OPTIONS && shift

    while [ -n "${1-}" ]; do
      case "$1" in
      -q) # check if system is compatible for this patch
        shift
        ;;
      -rb) # Rollback this patch if installed
        shift
        ;;
      --check) # Check if patch was applied
        shift
        ;;
      --manual) # Provide text file with instructions to apply this fix
        shift
        ;;
      *)
        error_invalidOptions "${1}"
        ;;
      esac
    done
    ;;
  Config) # Config nixTools option that creates .conf file with system state etc
    SCRIPT_CURRENT_STATE="$1"
    SCRIPT_DRIVER_STATE="${2:-"None"}"
    shift
    check_ScriptDriver SCRIPT_CONFIG_OPTIONS && shift

    while [ -n "${1-}" ]; do
      case "$1" in
      --clear) # Check if patch was applied
        shift
        ;;
      --manual) # Provide text file with instructions to apply this fix
        shift
        ;;
      *)
        error_invalidOptions "${1}"
        ;;
      esac
    done
    ;;
  dev)
    SCRIPT_CURRENT_STATE="$1"
    shift
    ;;
  *)
    echo "$1 Not a valid option"
    echo "Exiting Script..."
    exit 1
    ;;
  esac
done

#### FUNCTIONS DECLARED

# Print all User/Script parameters loaded at runtime
script_PARAMETERS() {
  printf "# SYSTEM PARAMETERS:\n"
  echo "SYSTEM_DISTRIBUTION=$SYSTEM_DISTRIBUTION"
  echo "OS_RELEASE=$OS_RELEASE"
  echo "SYSTEM_DESKTOP=$SYSTEM_DESKTOP"

  printf "\n# USER PARAMETERS:\n"
  echo "USER_IS_ROOT=$USER_IS_ROOT"
  echo "USER_HOME=$USER_HOME"
  echo "SYSTEM_IS_VIRTUAL=$SYSTEM_IS_VIRTUAL"

  printf "\n# SCRIPT PARAMETERS:\n"
  echo "SCRIPT_USER=$SCRIPT_USER"
  echo "SCRIPT_CALLER=$SCRIPT_CALLER"
  echo "SCRIPT_FILE=$SCRIPT_FILE"
  echo "SCRIPT_DIR=$SCRIPT_DIR"
  echo "SCRIPT_ROOT=$SCRIPT_ROOT"
  echo "SCRIPT_BASE=$SCRIPT_BASE"
}

# Create contents to be stored in System configuration file
config_nixTool_conf_contents() {
  echo "SYSTEM_DISTRIBUTION=$SYSTEM_DISTRIBUTION
OS_RELEASE=$OS_RELEASE
SYSTEM_DESKTOP=$SYSTEM_DESKTOP
SYSTEM_IS_VIRTUAL=$SYSTEM_IS_VIRTUAL"
}

# Create/re-create system configuration file
config_nixTool_conf() {
  local NIXTOOL_CONF="../etc/nixTool_sys.conf"
  if [ -f "${NIXTOOL_CONF}" ]; then
    mv "${NIXTOOL_CONF}" "${NIXTOOL_CONF}.bak"
  fi
  touch "${NIXTOOL_CONF}" && config_nixTool_conf_contents >>"${NIXTOOL_CONF}"
}

# Bring system up-to-date
system_Refresh() {
  apt -qq update
  apt -qq upgrade -y
  apt -qq autoremove -y
}

#Prepare directories to be used by script
# Check permissions on created directories
prep_CreateScriptDirs() {
  mkdir -p "${SANDBOX_DIR}"           # Include test for dir
  mkdir -p "${USER_HOME}/.local/bin/" # Include test for dir
  cp /etc/apt/sources.list /etc/apt/sources.list.bak
  cd "${SANDBOX_DIR}" || {
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
  rm -rf "${SANDBOX_DIR}"
}

# Prepare Virtual Box Install
prep_VBox() {
  # Update links/Stop relying on links
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc # Output prefix -p to sandbox
  apt-key add oracle_vbox_2016.asc
  add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian ${OS_RELEASE} contrib"
}

# Prepare a Guest installation for VBox_Guest_Additions packages
prep_VBox_GuestAdditions() {
  echo "[ERROR]: Contact system admin for help with this feature => prep_VBox_GuestAdditions"
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

# Install Packages to system
install_AptPackages() {
  local packages_arr=()

  # Restrict VBox packages from being installed in guest VBox
  if [ "${SYSTEM_IS_VIRTUAL}" = "false" ]; then
    prep_VBox && packages_arr=("${packages_arr[@]}" "${VBOX_PACKAGE_SET[@]}")
  else
    prep_VBox_GuestAdditions
  fi

  # Restrict Gnome Extension packages to Gnome installations
  if [ "${SYSTEM_DE}" = "GNOME" ] || [ "${DESKTOP_ENV}" = "gnome" ]; then
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
  #install_JBToolbox

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

# Test script driver path
test_Script_States() {
  echo "Main => ${SCRIPT_CURRENT_STATE}"
  echo "Driver => ${SCRIPT_DRIVER_STATE}"
  echo "Options => "
  echo "User => ${SCRIPT_USER}"
}

## Core Functions ##

# System driver function
script_Main_System() {
  case $USER_IS_ROOT in
  true)
    case $SCRIPT_DRIVER_STATE in
    Fresh)
      config_FreshSystem
      ;;
    Upgrade)
      system_Refresh
      ;;
    DeskEnv)
      echo "Not Supported"
      ;;
    test)
      test_Script_States
      ;;
    *)
      error_InvalidDriver
      ;;
    esac
    ;;
  false)
    case $SCRIPT_DRIVER_STATE in
    test)
      test_Script_States
      ;;
    *)
      error_InvalidDriver
      ;;
    esac
  esac
  exit 0
}

# Config driver function
script_Main_Config() {
  case $USER_IS_ROOT in
  true)
    case $SCRIPT_DRIVER_STATE in
    test)
      test_Script_States
      ;;
    nixconf)
      echo "[INFO] Do not use ' sudo ' while creating nixTool Conf file."
      printf "[INFO] Exiting script...\n"
      ;;
    *)
      error_InvalidDriver
      ;;
    esac
    ;;
  false)
    case $SCRIPT_DRIVER_STATE in
    git_config)
      config_GitIdent
      ;;
    test)
      test_Script_States
      ;;
    nixconf)
      config_nixTool_conf
      ;;
    *)
      error_InvalidDriver
      ;;
    esac
    ;;
  esac
  exit 0
}

# Patch driver function
script_Main_Patch() {
  . nix_Patch.sh
  case $USER_IS_ROOT in
  true)
    case $SCRIPT_DRIVER_STATE in
    *)
      echo "Patch not yet supported"
      ;;
    esac
    ;;
  false)
    case $SCRIPT_DRIVER_STATE in
    *)
      echo "Patch not yet supported"
      ;;
    esac
    ;;
  esac
}

script_NonProd_Dev() {
  case $USER_IS_ROOT in
  true)
    echo "[INFO] Script Option ' dev ' cannot be run as root"
    exit 1
    ;;
  false)
    # Functions to test go here
    script_PARAMETERS
    ;;
  esac
  exit 0
}

# Main Script Driver
script_Main() {
  echo "Script State: ${SCRIPT_CURRENT_STATE}"
  case $SCRIPT_CURRENT_STATE in
  System)
    script_Main_System
    ;;
  Config)
    script_Main_Config
    ;;
  Patch)
    script_Main_Patch
    ;;
  dev)
    script_NonProd_Dev
    ;;
  *)
    echo "Unrecognized State, How did you get here?"
    exit 1
    ;;
  esac
}

script_Main
exit 0
