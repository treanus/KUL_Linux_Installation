#!/usr/bin/env bash
# 
# This script installs many NeuroImaging software for use in MRI neuroimaging...
# Stefan Sunaert - first version dd 08092020 - v0.1
#  current version dd 19102021 - v0.5

# Define the install location
install_location=/usr/local/KUL_apps
KUL_apps_config="${install_location}/KUL_apps_config"
bashpoint=".bash_profile"

# First define a function to keep installation of things tidy
function install_KUL_apps {
    cd ${install_location}
    echo -e "\n\n\n"
    read -r -p "Proceed with the installation of $1? [y/n] " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
        echo 'OK we continue'
    else
        exit
    fi
}

# Give some information & ask permission to continue 
echo 'This script will install a lot of neuro-imaging software on a OsX system'
echo '      for details see https://github.com/treanus/KUL_Linux_Installation'
echo '      it will take several hours to install (and compile, if needed) all software. '
echo '      You may have to reboot once, after which you have to restart the script.'
echo '      The script will check what has already been installed and continue installing software'
echo '      This script may ask you a several times for your password in order to install software (sudo usage)'

read -r -p "Proceed with the installation? [y/n] " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    echo 'OK we continue'
else
    exit
fi

# Now make the install directory
# Determine group id
kul_group=$(id -g)
#echo $kul_group
sudo mkdir -p ${install_location}
sudo chgrp -R ${kul_group} ${install_location}
sudo chmod -R 770 ${install_location}

# initiate the config file to be sourced by .bash_profile
if [ ! -f ${KUL_apps_config} ]; then
    echo "export KUL_apps_DIR=${install_location}" > ${KUL_apps_config}
    echo "# Welcome to KUL_Apps" >> ${KUL_apps_config}
    echo "echo \"  installation DIR is  ${install_location}\" " >> ${KUL_apps_config}
    echo "echo \"  the config file is   ${KUL_apps_config}\" " >> ${KUL_apps_config}
    echo "echo \" \" " >> ${KUL_apps_config}
    echo "" >> ${bashpoint}
    echo "# Source the KUL_apps and other neuroimaging software" >> ${bashpoint}
    echo "source ${KUL_apps_config}"  >> ${bashpoint}
    echo "export BASH_SILENCE_DEPRECATION_WARNING=1" >> ${bashpoint}
fi

# Installation of Anaconda & welcome
if ! command -v conda &> /dev/null
then
    install_KUL_apps "Anaconda3"
    anaconda_version=Anaconda3-2021.05-MacOSX-x86_64.pkg
    curl -o ${anaconda_version} https://repo.anaconda.com/archive/${anaconda_version}
    sudo installer -pkg ${anaconda_version} -target ${install_location}
    rm -fr ${anaconda_version}
    echo -e "\n\n\n"
    echo 'Now exit this terminal and run the KNT_Linux_install.sh again from a new terminal'
    exit
else
    echo 'Already installed Anaconda3'
fi


# Install command line developer tools
if xcode-select --install 2>&1 | grep installed; then
    echo "Already installed command line developer tools"
else
    echo "Installing command line developer tools"
    xcode-select --install
fi

# Installation of HD-BET
if ! command -v hd-bet &> /dev/null
then
    install_KUL_apps "HD-BET"
    git clone https://github.com/MIC-DKFZ/HD-BET
    cd HD-BET
    sudo pip install -e .
    cd
    echo "" >> ${KUL_apps_config}
    echo "# Setting up HD-BET" >> ${KUL_apps_config}
    echo "alias hd-bet='hd-bet -device cpu -mode fast -tta 0 ' " >> ${KUL_apps_config}
else
    echo 'Already installed HD-BET'
fi

# Installation of MRtrix3
if ! command -v mrconvert &> /dev/null
then
    install_KUL_apps "MRtrix3"
    sudo conda install -c mrtrix3 mrtrix3
else
    echo 'Already installed MRtrix3'
fi

# download a number of Docker containers
echo -e "\n\n\n"
echo "We are going to download a number of docker containers..."
echo "Start docker desktop and wait until it is running..."
read -p "Press any key to continue... " -n1 -s
#docker pull jenspetersen/hd-glio-auto
echo "Installing synb0"
docker pull hansencb/synb0

# Installation of FSL
if ! [ -d "/usr/local/fsl" ]
then
    install_KUL_apps "FSL"
    curl -o XQuartz-2.8.1.dmg https://github.com/XQuartz/XQuartz/releases/download/XQuartz-2.8.1/XQuartz-2.8.1.dmg
    sudo installer -pkg XQuartz-2.8.1.dmg
    curl -o fslinstaller.py https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py
    echo -e "\n\n\n"
    echo "Here we give the installation instructions for FSL..."
    echo "it is ok to install to the default /usr/local/fsl directory"
    echo "You need to have QXartz installed, see https://www.xquartz.org/"
    echo "install this first before continuing"
    read -p "Press any key to continue... " -n1 -s
    python2.7 fslinstaller.py
    rm fslinstaller.py
    exit
    cat <<EOT >> ${KUL_apps_config}
# Installing FSL
FSLDIR=/usr/local/fsl
. \${FSLDIR}/etc/fslconf/fsl.sh
PATH=\${FSLDIR}/bin:\${PATH}
export FSLDIR PATH
EOT

else
    echo 'Already installed FSL'
fi

exit

echo -e "\n\n\n"
    echo "Here we give the installation instructions for FSL..."
    echo "it is ok to install to the default /usr/local/fsl directory"
    read -p "Press any key to continue... " -n1 -s

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# setup Brew for multiple users
sudo chgrp -R admin /usr/local/*
sudo chmod -R g+w /usr/local/*

# allow admins to homebrew's local cache of formulae and source files
sudo chgrp -R admin /Library/Caches/Homebrew
sudo chmod -R g+w /Library/Caches/Homebrew

# if you are using cask then allow admins to manager cask install too
sudo chgrp -R admin /opt/homebrew-cask
sudo chmod -R g+w /opt/homebrew-cask


# Update homebrew recipes
brew update

PACKAGES=(
    git
    hub
    jq
    wget
    parallel
    eigen
    qt5
    pkg-config
    libtiff
    fftw
    mmv
    cmake
    netpbm
)
echo "Installing packages..."
brew install ${PACKAGES[@]}


# Installing casks & fonts
# brew install caskroom/cask/brew-cask

CASKS=(
        cyberduck
        docker
        firefox
        google-chrome
        slack
        yujitach-menumeters
        osirix-quicklook
        quicklook-json
        quicklook-csv
    dropbox
)

echo "Installing cask apps..."
brew cask install ${CASKS[@]}

echo "Installing fonts..."
brew tap caskroom/fonts
FONTS=(
    caskroom/fonts/font-montserrat
)
brew cask install ${FONTS[@]}


# Create bash_profile
touch ~/.bash_profile

# Modify git to work from behind the firewall
git config --global url."https://".insteadOf git://


# This adds qt binaries to your path
echo 'export PATH=`brew --prefix`/opt/qt5/bin:$PATH' >> ~/.bash_profile


# Install XQuartz 2.7.11
wget https://dl.bintray.com/xquartz/downloads/XQuartz-2.7.11.dmg -P ~/Downloads/
hdiutil attach ~/Downloads/XQuartz-2.7.11.dmg
cp -rf /Volumes/XQuartz-2.7.11/XQuartz.pkg /Applications/
sudo installer -pkg /Applications/XQuartz.pkg -target /
rm /Applications/XQuartz.pkg
diskutil unmount /Volumes/XQuartz-2.7.11/


# Add your Mac distro Python 2.7 to path
#echo '# add python 2.7 to path' >> ~/.bash_profile
#echo 'export PATH="/usr/bin:$PATH"' >> ~/.bash_profile


# Create the KUL_apps folder
sudo mkdir /KUL_apps
sudo chgrp -R admin /KUL_apps
sudo chmod -R g+w /KUL_apps


# Install FSL
echo "Checking whether FSL is already installed"
source ~/.bash_profile
if test ! $(which fsleyes); then
   echo "FSL isn't installed so we will download FSL installer and run it, you will need to enter your admin password"
   curl -o ~/Downloads/fslinstaller.py https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py
   sudo python2.7 ~/Downloads/fslinstaller.py -d /KUL_apps/fsl
fi

# Install ANTs
sudo chown `whoami` .bash_profile
echo "Copying ANTs from the Linux server and adding it to your path"
sudo scp -r administrator@thibo:/KUL_sources/ants /KUL_apps
echo ' ' >> ~/.bash_profile
echo '# adding ANTS to your path' >> ~/.bash_profile
echo 'ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4' >> ~/.bash_profile
echo 'export ANTSPATH=/KUL_apps/ants/bin' >> ~/.bash_profile
echo 'export PATH=${ANTSPATH}:$PATH' >> ~/.bash_profile


# Install MRTRIX3
echo "Installing/Checking MRtrix3..."
if test ! $(which mrview); then
    git clone https://github.com/MRtrix3/mrtrix3.git /KUL_apps/mrtrix3
    cd /KUL_apps/mrtrix3
    ./configure
    ./build
    ./set_path
fi

echo "Cleaning up..."
brew cleanup

# Install freesurfer
mkdir /KUL_apps/freesurfer
mkdir /KUL_apps/freesurfer_install
wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/6.0.0/freesurfer-Darwin-OSX-stable-pub-v6.0.0.dmg -P /KUL_apps/freesurfer_install
hdiutil attach /KUL_apps/freesurfer_install/freesurfer-Darwin-OSX-stable-pub-v6.0.0.dmg
# mounting the dmg and installing, fixed path typos
sudo installer -pkg /Volumes/freesurfer-Darwin-full/freesurfer-Darwin-full.pkg -target /
sudo mv /Applications/freesurfer /KUL_apps/
echo "get your freesurfer license from here https://surfer.nmr.mgh.harvard.edu/registration.html"
echo "use this command to get the license in the freesurfer folder"
echo "cp ~/Downloads/license.txt /KUL_apps/freesurfer"
echo '# Adding freesurfer to your path' >> ~/.bash_profile
echo 'export FREESURFER_HOME=/KUL_apps/freesurfer' >> ~/.bash_profile
echo 'source $FREESURFER_HOME/SetUpFreeSurfer.sh' >> ~/.bash_profile

# Rename your .bash_profile to .bashrc and source .bashrc from .bash_profile
mv ~/.bash_profile ~/.bashrc
touch ~/.bash_profile
echo '[ -r ~/.bashrc ] && . ~/.bashrc' >> ~/.bash_profile
echo 'export DYLD_LIBRARY_PATH=/opt/X11/lib/flat_namespace' >> ~/.bashrc

# Install AFNI
# Following the instructions on https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/steps_mac.html#what-to-do
defaults write org.macosforge.xquartz.X11 wm_ffm -bool true
defaults write org.x.X11 wm_ffm -bool true
defaults write com.apple.Terminal FocusFollowsMouse -string YES
touch ~/.cshrc
echo 'setenv DYLD_LIBRARY_PATH /opt/X11/lib/flat_namespace' >> ~/.cshrc
mkdir /KUL_apps/AFNI_source
curl -o /KUL_apps/AFNI_source/@update.afni.binaries -O https://afni.nimh.nih.gov/pub/dist/bin/macosx_10.7_local/@update.afni.binaries
tcsh /KUL_apps/AFNI_source/@update.afni.binaries -bindir /KUL_apps/AFNI -package macos_10.12_local
# We're instructed to reboot after this line then continue with the rest
# need to move install directory to KUL_apps
#touch $reboot_marker # to create a file to look for upon reboot and continue with the rest of the script
#sudo reboot
echo 'export PATH=$PATH:/KUL_apps/AFNI' >> ~/.bashrc
echo 'export DYLD_FALLBACK_LIBRARY_PATH=/KUL_apps/AFNI' >> ~/.bashrc
wget https://cran.r-project.org/bin/macosx/el-capitan/base/R-3.4.1.pkg -P ~/Downloads/
sudo installer -pkg ~/Downloads/R-3.4.1.pkg -target /
sudo rPkgsInstall -pkgs ALL
cp /KUL_apps/AFNI/FNI.afnirc $HOME/.afnirc
suma -update_env


#echo "Installing global npm packages..."
#npm install particle-cli -g

# Install Horos
wget https://horosproject.org/horos-content/Horos3.2.1.dmg -P ~/Downloads/
hdiutil attach ~/Downloads/Horos3.2.1.dmg
cp -rf /Volumes/Horos/Horos.app /Applications/

# Install dcm2niix
sudo scp -r administrator@thibo:/KUL_sources/MRIcroGL /KUL_apps/
echo '# Add MRIcroGL to path' >> ~/.bashrc
echo 'export PATH=$PATH:/KUL_apps/MRIcroGL' >> ~/.bashrc

# Install dcm2bids
git clone https://github.com/jooh/Dcm2Bids.git /KUL_apps/Dcm2Bids
echo 'export PATH=$PATH:/KUL_apps/Dcm2Bids/scripts' >> ~/.bashrc
pip install msgpack --user
pip install future --user
pip install dcm2bids /KUL_apps/Dcm2Bids/ --user

source ~/.bash_profile
dcm2niix -u

# Installing adobe reader
VERSION="1501020056"
FILE="AcroRdrDC_${VERSION}_MUI.dmg"
URL="http://ardownload.adobe.com/pub/adobe/reader/mac/AcrobatDC/${VERSION}/${FILE}"

curl -O "$URL";

MOUNT_POINT=$(hdiutil attach $FILE | tail -1 | awk '{print $3;}');
PKG_FILE=$(ls -1 $MOUNT_POINT | tail -1)
PKG_PATH=$(printf "%s/%s" $MOUNT_POINT $PKG_FILE)

sudo installer -allowUntrusted -pkg $PKG_PATH -target /

hdiutil detach $MOUNT_POINT
rm $FILE

echo "Bootstrapping complete"

echo "Keeping up to date"
echo "You're all set, don't forget to install Matlab and any other programs you might need :) "

