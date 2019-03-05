#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Constants
currentDir=$(pwd)

dataFiles="$HOME/DataFiles"
qgc="$dataFiles/Software/QGroundControl"
ardupilot="$dataFiles/Development/ArduPilot"
eclipseDir="$dataFiles/Software/Eclipse"
eclipse="$eclipse/eclipse.tar.gz"

# Colors
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Clone Ardupilot
echo -e "${BLUE}Cloning ArduPilot repos..${NC}"
mkdir -p $ardupilot
git clone https://github.com/ArduPilot/ardupilot.git $ardupilot
cd $ardupilot
sed -i 's/git:\/\//https:\/\//g' .gitmodules
git submodule sync
git submodule update --init
sed -i 's/git:\/\//https:\/\//g' `find . -name .gitmodules`
git submodule sync --recursive
git submodule update --init --recursive

$ardupilot/Tools/scripts/install-prereqs-ubuntu.sh -y
. ~/.profile

sudo apt-get install python-dev python-opencv python-wxgtk3.0 python-pip python-matplotlib python-pygame python-lxml python-yaml python-serial python-wxtools python-scipy ccache gawk git python-pexpect
sudo pip install future pymavlink MAVProxy
echo "export PATH=$PATH:$ardupilot/Tools/autotest" >> ~/.bashrc
echo "export PATH=/usr/lib/ccache:$PATH" >> ~/.bashrc
echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.bashrc
sudo adduser $USER dialout
. ~/.bashrc

# Install QGroundControl
echo -e "${BLUE}Installing QGroundControl..${NC}"
mkdir -p $qgc
wget -P $qgc https://s3-us-west-2.amazonaws.com/qgroundcontrol/latest/QGroundControl.AppImage
chmod +x $qgc/QGroundControl.AppImage
cd $currentDir
cp qgc.png $qgc
sudo cp qgroundcontrol.desktop ~/.local/share/applications

sudo usermod -a -G dialout $USER
sudo apt-get remove -y modemmanager

# Install Eclipse CDT
echo -e "${BLUE}Installing Eclipse CDT IDE..${NC}"
sudo apt-get install -y openjdk-8-jdk curl
mkdir -p $eclipseDir
sudo curl -o $eclipse http://mirror.ufs.ac.za/eclipse/technology/epp/downloads/release/oxygen/3/eclipse-cpp-oxygen-3-linux-gtk-x86_64.tar.gz
tar -zxvf $eclipse -C $eclipseDir --strip-components=1
sudo rm -f $eclipse
cd $currentDir
cp eclipse.desktop $HOME/.local/share/applications/

echo -e "${BLUE}Done!${NC}\n"
cd $currentDir
