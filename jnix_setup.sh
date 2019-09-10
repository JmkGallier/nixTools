#!/bin/bash

## Future Improvements:
## Docker, PIA(include installer w/script), steam + wine + winetricks + Bethesda Launcer
## Antivirus/Rootkit, Linux Security Fixes
## Add Bash expects for Y/n and keep maintainer pkg
##
## INST362:
##
##
## INST346:
## Wireshark
## Packettracer
##
##
## INST377:
## LAMP Server
## Docker
## Git
## HCIL Research:
## Arduino IDE
## SSH
##


# Bring system up-to-date
apt -qq update
apt upgrade -y
apt dist-upgrade -y
apt autoremove -y

## Create Sandbox and AppImage Directories and backup Repo list
mkdir Downloads/Ashpile/
mkdir ${HOME}/.local/bin/
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cd Downloads/Ashpile/

## Install Jetbrains Toolbox
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.15.5796.tar.gz
tar -xzf jetbrains-toolbox-1.15.5796.tar.gz
rm -rf jetbrains-toolbox-1.15.5796.tar.gz
mv jetbrains-toolbox-1.15.5796/jetbrains-toolbox ${HOME}/.local/bin/
${HOME}/.local/bin/jetbrains-toolbox
pkill jetbrains-toolb

## Prepare VBox Installation
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
apt -qq update && sleep 3
add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
apt -qq update && sleep 3

## Prepare Spotify Installation
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
apt -qq update && sleep 3
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
apt -qq update && sleep 3

## Prepare BalenaEtcher Installation
echo "deb https://deb.etcher.io stable etcher" | tee /etc/apt/sources.list.d/balena-etcher.list
apt -qq update && sleep 3
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
apt -qq update && sleep 3

## Prepare Steam Installation
add-apt-repository multiverse

## Mass Package Installation
apt install spotify-client chromium-browser balena-etcher-electron nmap deluge htop gnome-tweak-tool arc-theme -y
apt install python3-distutils python3-pip exfat-fuse exfat-utils libavcodec-extra gnome-shell-extensions chrome-gnome-shell -y
apt install virtualbox-6.0 virtualbox-guest-x11 virtualbox-guest-utils virtualbox-guest-dkms steam-installer winetricks -y

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

## Check for Uninstalled Upgrade
apt -qq update && sleep 3
apt upgrade -y
apt dist-upgrade -y
apt autoremove -y
shutdown -r now
