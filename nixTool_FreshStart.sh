#!/bin/bash

#### ENVIRONMENT PARAMETERS
USER_HOME=$HOME

#### FUNCTIONS DECLARED

# Bring system up-to-date
system_Refresh () {
  apt -qq update
  apt -qq upgrade -y
  apt -qq autoremove -y
}

# Prepare directories to be used by script
prep_ScriptSetupDirectory () {
  mkdir "${USER_HOME}"/Downloads/Sandbox/
  mkdir "${USER_HOME}"/.local/bin/
  cp /etc/apt/sources.list /etc/apt/sources.list.bak
}

# Prepare Virtual Box Install
prep_VBox () {
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc
  apt-key add oracle_vbox_2016.asc
  add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
}

# Install JetBrains Toolbox App
install_JBToolbox () {
  cd "${USER_HOME}"/Downloads/Sandbox/ || { echo "Could not reach 'Sandbox' directory. Exiting Script."; exit 1; }
  wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.16.6207.tar.gz
  tar -xzf jetbrains-toolbox-1.16.6207.tar.gz
  mv jetbrains-toolbox-1.16.6207/jetbrains-toolbox "${USER_HOME}"/.local/bin/
  rm -rf jetbrains-toolbox-1.16.6207.tar.gz
}

# Apply Audio sink to fix Microphone-Speaker Echo
fix_PulseAudioEcho () {
  # Implement nessecity check before running
  echo 'load-module module-echo-cancel source_name=logitechsource' >> /etc/pulse/default.pa
  echo 'set-default-source logitechsource' >> /etc/pulse/default.pa
}

# Apply fix for screen tearing on systems with intel-gpu
fix_IntelScreenTear () {
  # Implement nessecity check before running
  # This requires a check for dir&file in question
  # This requires a check textstring echoed into file
  mkdir -p /etc/X11/xorg.conf.d/
  echo 'Section "Device"
     Identifier  "Intel Graphics"
     Driver      "intel"
     Option      "TearFree"    "true"
  EndSection' >> /etc/X11/xorg.conf.d/20-intel.conf
}

#### SCRIPT START ####
system_Refresh
prep_ScriptSetupDirectory # Check permissions on created directories

# Requested Package Section
install_JBToolbox # Update links/Stop relying on links
prep_VBox # Update links/Stop relying on links

# Mass Package Installation
apt -qq update && sleep 3
apt install wget snapd steam-installer neofetch -y
apt install chromium-browser nmap deluge htop arc-theme -y
apt install exfat-fuse exfat-utils python3-distutils python3-pip libavcodec-extra -y
apt install virtualbox-6.1 virtualbox-guest-x11 virtualbox-guest-utils virtualbox-guest-dkms -y
apt install gnome-tweak-tool gnome-shell-extensions chrome-gnome-shell

## Install Snap Packages
snap install spotify
snap install atom --classic

# Hotfixes
fix_PulseAudioEcho
fix_IntelScreenTear

# Wrap up Installation

## Delete Sandbox directory
cd ~/ || { echo "Could not reach 'home' directory. Exiting Script."; exit 1; }
rm -rf "${HOME}"/Downloads/Sandbox/

## Final System Check
system_Refresh
clear && neofetch
