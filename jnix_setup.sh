#!/bin/bash

## Future Improvements:
## Docker, PIA(include installer w/script), wine + winetricks + arduino + Xsane + Bethesda Launcher + Rockstar Games + Arduino IDE
## Antivirus/Rootkit, Linux Security Fixes
## Add Bash expects for Y/n and keep maintainer pkg

# Bring system up-to-date
apt -qq update
apt -qq upgrade -y
apt -qq full-upgrade -y
apt -qq autoremove -y

## Create Sandbox and AppImage Directories and backup Repo list
mkdir Downloads/Ashpile/
mkdir "${HOME}"/.local/bin/
cp /etc/apt/sources.list /etc/apt/sources.list.bak

## Install Temp/Package/Compatibility software
apt install lm-sensors hddtemp snapd wget -y
sensors-detect
sensors

## Install Jetbrains Toolbox
cd Downloads/Ashpile/ || { echo "Could not reach 'Ashpile' directory. Exiting Script."; exit 1; }
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.16.6207.tar.gz
tar -xzf jetbrains-toolbox-1.16.6207.tar.gz
mv jetbrains-toolbox-1.16.6207/jetbrains-toolbox "${HOME}"/.local/bin/
rm -rf jetbrains-toolbox-1.16.6207.tar.gz

## Prepare VBox Installation
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"

## {DEPRECATED}Prepare Spotify Installation{DEPRECATED}
#curl -sS https://download.spotify.com/debian/pubkey.gpg | apt-key add -
#echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

## Prepare BalenaEtcher Installation
#echo "deb https://deb.etcher.io stable etcher" | tee /etc/apt/sources.list.d/balena-etcher.list
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
#apt -q update && sleep 3
#apt install balena-etcher-electron

## Mass Package Installation
apt -qq update && sleep 3
apt install steam-installer neofetch gnome-tweak-tool gnome-shell-extensions chrome-gnome-shell -y
apt install chromium-browser nmap deluge htop arc-theme -y
apt install exfat-fuse exfat-utils python3-distutils python3-pip libavcodec-extra psensor  -y
apt install virtualbox-6.0 virtualbox-guest-x11 virtualbox-guest-utils virtualbox-guest-dkms -y

## Install Snap Packages
snap install spotify

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

### Wrap up Installation
cd ~/ || { echo "Could not reach 'home' directory. Exiting Script."; exit 1; }
rm -rf "${HOME}"/Downloads/Ashpile/

## Final System Check
apt -qq update && sleep 3
apt -qq upgrade -y
apt -qq full-upgrade -y
apt -qq autoremove -y
clear
neofetch
