#!/bin/bash
set -e
set -o pipefail

#### OPTION PARAMETERS
OUT_OPT=()
declare -A SCRIPT_STATE_OPTIONS=(
  ["none"]=1
  ["test"]=1
  ["dev"]=1
  ["prod"]=1
  ["System"]=1
  ["Patch"]=1
  ["Config"]=1
)
declare -A DESKTOP_ENV_OPTIONS=(
  ["gnome"]=1
  ["xfce"]=1
)
declare -A SCRIPT_SYSTEM_OPTIONS=(
  ["Fresh"]=1
  ["Upgrade"]=1
  ["DeskEnv"]=1
)
declare -A SCRIPT_PATCH_OPTIONS=(
  ["intel-screen-tearing"]=1
  ["pulseaudio-echo"]=1
)

declare -A SCRIPT_CONFIG_OPTIONS=(
  ["git_config"]=1
)

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

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SCRIPT_ROOT="$(cd "$(dirname "${SCRIPT_DIR}")" && pwd)"
SCRIPT_FILE="${SCRIPT_DIR}/$(basename "${BASH_SOURCE[0]}")"
SCRIPT_BASE="$(basename "${SCRIPT_FILE}")"
SCRIPT_DRIVER_STATE="none"
SCRIPT_DEFAULT_STATE="none"
SCRIPT_EXIT_STATE="exit"


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
while [ "${SCRIPT_CURRENT_STATE}" == "none" ]; do
  case "$1" in
  System)
    SCRIPT_CURRENT_STATE="$1"
    SCRIPT_DRIVER_STATE="${2:-"None"}"
    shift

    if [[ ${SCRIPT_SYSTEM_OPTIONS[$SCRIPT_DRIVER_STATE]} ]]; then
      OUT_OPT=("${OUT_OPT[@]}" "$SCRIPT_DRIVER_STATE")
      shift
    else
      printf "[ERROR] Incorrect Driver Argument: %s\n" "$SCRIPT_DRIVER_STATE"
      printf "[INFO]Please enter ONE of the following:\nFresh\nDeskEnv\n\n"
      printf "[INFO]Exiting nixTools...\n"
      exit 1
    fi

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
        # This Param option is for explicitly stating the desktop environment due to issues with using sudo with env-vars
        if [[ ${DESKTOP_ENV_OPTIONS[$DESKTOP_ENV]} ]]; then :
        else
          echo "${DESKTOP_ENV} is not a valid option"
          SCRIPT_CURRENT_STATE="none"
        fi
        shift
        shift
        ;;
      *)
        echo "$1 Not a valid argument for System"
        echo "Exiting Script"
        exit 1
        ;;
      esac
    done
    ;;
  Patch)
    SCRIPT_CURRENT_STATE="$1"
    SCRIPT_DRIVER_STATE="${2:-"None"}"
    shift

    if [[ ${SCRIPT_PATCH_OPTIONS[$SCRIPT_DRIVER_STATE]} ]]; then
      OUT_OPT=("${OUT_OPT[@]}" "$SCRIPT_DRIVER_STATE")
      echo "$SCRIPT_DRIVER_STATE in SCRIPT_SYSTEM_OPTIONS"
      shift
    else
      echo "Incorrect Driver Argument: $SCRIPT_DRIVER_STATE"
      printf "Please enter ONE of the following:\nFresh\nDeskEnv\n\n"
      echo "Exiting nixTools..."
      exit 1
    fi

    while [ -n "${1-}" ]; do
      case "$1" in
      -q) # check if system is compatible for this patch
        OUT_OPT=("${OUT_OPT[@]}" "$1")
        shift
        ;;
      -rb) # Rollback this patch if installed
        OUT_OPT=("${OUT_OPT[@]}" "$1")
        shift
        ;;
      --check) # Check if patch was applied
        OUT_OPT=("${OUT_OPT[@]}" "$1")
        shift
        ;;
      --manual) # Provide text file with instructions to apply this fix
        OUT_OPT=("${OUT_OPT[@]}" "$1")
        shift
        ;;
      *)
        echo "$1 Not a valid argument for Patch"
        echo "Exiting Script"
        exit 1
        ;;
      esac
    done
    echo "${OUT_OPT[@]}"
    printf "Patch is not supported in nixTool-master and has not implemented any patches."
    ;;
  Config) # Config nixTools option that creates .conf file with system state etc
    SCRIPT_CURRENT_STATE="$1"
    echo "${OUT_OPT[@]}"
    printf "Config is not supported in nixTool-master and has not implemented any Configuration changes."
    ;;
  *)
    echo "$1 Not a valid option"
    echo "Exiting Script"
    exit 1
    ;;
  esac
done

#### FUNCTIONS DECLARED

# Print all User/Script parameters loaded at runtime
script_PARAMETERS() {
  printf "\nSYSTEM PARAMETERS:\n"
  echo "SYSTEM_DISTRIBUTION=$SYSTEM_DISTRIBUTION"
  echo "OS_RELEASE=$OS_RELEASE"
  echo "SYSTEM_DESKTOP=$SYSTEM_DESKTOP"

  printf "\nUSER PARAMETERS:\n"
  echo "USER_IS_ROOT=$USER_IS_ROOT"
  echo "USER_HOME=$USER_HOME"
  echo "SYSTEM_IS_VIRTUAL=$SYSTEM_IS_VIRTUAL"

  printf "\nSCRIPT PARAMETERS:\n"
  echo "SCRIPT_USER=$SCRIPT_USER"
  echo "SCRIPT_CALLER=$SCRIPT_CALLER"
  echo "SCRIPT_FILE=$SCRIPT_FILE"
  echo "SCRIPT_DIR=$SCRIPT_DIR"
  echo "SCRIPT_ROOT=$SCRIPT_ROOT"
  echo "SCRIPT_BASE=$SCRIPT_BASE"
}

# Bring system up-to-date
system_Refresh() {
  apt -qq update
  apt -qq upgrade -y
  apt -qq autoremove -y
}

# Prepare directories to be used by script
# Check permissions on created directories
prep_CreateScriptDirs() {
  mkdir -p "${SANDBOX_DIR}" # Include test for dir
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
patch_PulseAudioEcho() {
  # Implement necessity check before running
  echo 'load-module module-echo-cancel source_name=logitechsource' >>/etc/pulse/default.pa
  echo 'set-default-source logitechsource' >>/etc/pulse/default.pa
}

# Apply fix for screen tearing on systems with intel-gpu
patch_IntelScreenTear() {
  # Implement necessity check before running
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

# Prepare a Guest installation for VBox_Guest_Additions packages
prep_VBox_GuestAdditions() {
  echo "[ERROR]: Contact system admin for help with this feature => prep_VBox_GuestAdditions"
}

# Install Packages to system
# Requires sudo
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
  echo "Script State: ${SCRIPT_CURRENT_STATE}"
  case $USER_IS_ROOT in
  true)
    case $SCRIPT_CURRENT_STATE in
    System)
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
      esac
      ;;
    Patch)
      echo "Not Supported"
      ;;
    Config)
      case $SCRIPT_DRIVER_STATE in
      git_config)
        echo "Do not run with sudo"
        ;;
      esac
      ;;
    test)
      ;;
    dev)
      script_PARAMETERS
      ;;
    *)
      echo "Unrecognized State, How did you get here?"
      exit 1
    esac
    ;;
  false)
    case $SCRIPT_CURRENT_STATE in
    System)
      echo "[INFO] Commands ' nixtool System <*argument*> ' require sudo"
      ;;
    Patch)
      echo "Not Supported"
      ;;
    Config)
      case $SCRIPT_DRIVER_STATE in
      git_config)
        config_GitIdent
        ;;
      esac
      ;;
    test)
      echo "[INFO] No operations selected"
      ;;
    dev)
      script_PARAMETERS
      ;;
    *)
      echo "Unrecognized State, How did you get here?"
      exit 1
      ;;
    esac
    ;;
  esac
}

script_Main
exit 0
