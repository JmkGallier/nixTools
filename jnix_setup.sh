#!/bin/bash

## Future Improvements:
## Docker, PIA(include installer w/script), wine + winetricks + arduino + Xsane + Bethesda Launcher + Rockstar Games + Arduino IDE
## Antivirus/Rootkit, Linux Security Fixes
## Add Bash expects for Y/n and keep maintainer pkg
## Add bash variables for github accounts creation

## Bring system up-to-date
apt -qq update
apt -qq upgrade -y
apt -qq autoremove -y

## Create Sandbox and AppImage Directories and backup Repo list
mkdir Downloads/Sandbox/
mkdir "${HOME}"/.local/bin/
cp /etc/apt/sources.list /etc/apt/sources.list.bak

## Install Temp/Package/Compatibility software
#apt install lm-sensors hddtemp snapd wget -y
#sensors-detect
#sensors

## Install Jetbrains Toolbox
cd Downloads/Sandbox/ || { echo "Could not reach 'Sandbox' directory. Exiting Script."; exit 1; }
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.16.6207.tar.gz
tar -xzf jetbrains-toolbox-1.16.6207.tar.gz
mv jetbrains-toolbox-1.16.6207/jetbrains-toolbox "${HOME}"/.local/bin/
rm -rf jetbrains-toolbox-1.16.6207.tar.gz

## Prepare VBox Installation
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc
apt-key add oracle_vbox_2016.asc
add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"

## Mass Package Installation
apt -qq update && sleep 3
apt install steam-installer neofetch -y
apt install chromium-browser nmap deluge htop arc-theme -y
apt install exfat-fuse exfat-utils python3-distutils python3-pip libavcodec-extra -y
apt install virtualbox-6.1 virtualbox-guest-x11 virtualbox-guest-utils virtualbox-guest-dkms -y
#apt install psensor
#apt install gnome-tweak-tool gnome-shell-extensions chrome-gnome-shell

## Install Snap Packages
snap install spotify
snap install atom --classic

### Hotfixes ###

## Fix PulseAudio echo
echo 'load-module module-echo-cancel source_name=logitechsource' >> /etc/pulse/default.pa
echo 'set-default-source logitechsource' >> /etc/pulse/default.pa

## Fix for Intel screen tearing
mkdir -p /etc/X11/xorg.conf.d/
echo 'Section "Device"
   Identifier  "Intel Graphics"
   Driver      "intel"
   Option      "TearFree"    "true"
EndSection' >> /etc/X11/xorg.conf.d/20-intel.conf

### Wrap up Installation ###

## Delete Sandbox directory
cd ~/ || { echo "Could not reach 'home' directory. Exiting Script."; exit 1; }
rm -rf "${HOME}"/Downloads/Sandbox/

## Final System Check
apt -qq update && sleep 3
apt -qq upgrade -y
apt -qq full-upgrade -y
apt -qq autoremove -y
clear
neofetch

### Experimental implementations
## Prepare BalenaEtcher Installation
#echo "deb https://deb.etcher.io stable etcher" | tee /etc/apt/sources.list.d/balena-etcher.list
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
#apt -q update && sleep 3
#apt install balena-etcher-electron
