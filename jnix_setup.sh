#!/bin/bash

## Future Improvements:
## Docker, PIA(include installer w/script), wine + winetricks + arduino + Xsane + Bethesda Launcher + Rockstar Games + Arduino IDE
## Antivirus/Rootkit, Linux Security Fixes
## Add Bash expects for Y/n and keep maintainer pkg

# Bring system up-to-date
apt -qq update
apt upgrade -y
apt dist-upgrade -y
apt autoremove -y

## Create Sandbox and AppImage Directories and backup Repo list
mkdir Downloads/Ashpile/
mkdir "${HOME}"/.local/bin/
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cd Downloads/Ashpile/ || exit

## Install Temp/Package/Compatibility software
apt install lm-sensors hddtemp snapd wget exfat-fuse exfat-utils -y
sensors-detect
sensors

## Install Jetbrains Toolbox
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.15.5796.tar.gz
tar -xzf jetbrains-toolbox-1.15.5796.tar.gz
rm -rf jetbrains-toolbox-1.15.5796.tar.gz
mv jetbrains-toolbox-1.15.5796/jetbrains-toolbox "${HOME}"/.local/bin/

## Prepare VBox Installation
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"

## Prepare Spotify Installation
curl -sS https://download.spotify.com/debian/pubkey.gpg | apt-key add -
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

## Mass Package Installation
apt -qq update && sleep 3
apt install steam-installer neofetch gnome-tweak-tool gnome-shell-extensions chrome-gnome-shell -y
apt install spotify-client chromium-browser nmap deluge htop arc-theme -y
apt install python3-distutils python3-pip libavcodec-extra psensor  -y
apt install virtualbox-6.0 virtualbox-guest-x11 virtualbox-guest-utils virtualbox-guest-dkms -y

### Hotfixes

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
rm -rf "${HOME}"/Downloads/Ashpile/

## Final System Check
apt -qq update && sleep 3
apt upgrade -y
apt full-upgrade -y
apt autoremove -y
clear
neofetch
