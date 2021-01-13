#!/bin/bash

# This script installs many NeuroImaging software for use in MRI neuroimaging...
# Stefan Sunaert - first version dd 08092020 - v0.1
#  current version dd 29092020 - v0.2

# We first define a function to keep installation of things tidy
function install_KUL_apps {
    cd
    mkdir -p KUL_apps
    cd KUL_apps
    clear 
    read -r -p "Proceed with the installation of $1? [y/n] " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
        echo 'OK we continue'
    else
        exit
    fi
}

# Give some information & ask permission to continue
clear
echo 'This script will install a lot of neuro-imaging software on a WIN10 WSL2 system'
echo '  for details see https://github.com/treanus/KUL_Linux_Installation'
echo '      it will take several minutes/hours to install (and compile, if needed) all software. '
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
clear 

# Update an Upgrade all existing packages
echo 'The system will now ask you your password to update and upgrade all linux system software'
sudo apt update
sudo apt upgrade
clear
sleep 3

# Installation of Anaconda
if ! command -v conda &> /dev/null
then
    install_KUL_apps "Anaconda3"
    sudo apt-get -y install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
    wget https://repo.anaconda.com/archive/Anaconda3-2020.07-Linux-x86_64.sh
    bash Anaconda3-2020.07-Linux-x86_64.sh
    rm Anaconda3-2020.07-Linux-x86_64.sh
    echo 'Now reboot (restart) and run the KNT_Linux_install.sh again from terminal'
    exit
else
    echo 'Already installed Anaconda3'
fi

# Install extra needed packages
sudo apt-get -y install g++ zlib1g-dev

# Installation of FSL
if ! [ -d "/usr/local/fsl" ]
then
    install_KUL_apps "FSL"
    wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py
    sudo python2.7 fslinstaller.py
    rm fslinstaller.py
    cd
else
    echo 'Already installed FSL'
fi

# Installation of MRtrix3
if ! command -v mrconvert &> /dev/null
then
    install_KUL_apps "MRtrix3"
    sudo apt-get -y install git g++ python-is-python3 libeigen3-dev zlib1g-dev libqt5opengl5-dev libqt5svg5-dev libgl1-mesa-dev libfftw3-dev libtiff5-dev libpng-dev
    git clone https://github.com/MRtrix3/mrtrix3.git
    cd mrtrix3
    ./configure
    ./build
    ./set_path
    cd
    source .bashrc
else
    echo 'Already installed MRtrix3'
fi

# Installation of Freesurfer
#if ! command -v freeview &> /dev/null
if ! [ -d "/usr/local/freesurfer" ]
then
    install_KUL_apps "Freesurfer v 7.1.1"
    wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.1.1/freesurfer-linux-centos7_x86_64-7.1.1.tar.gz
    sudo tar -C /usr/local -zxvpf freesurfer-linux-centos7_x86_64-7.1.1.tar.gz
    echo "" >> $HOME/.bashrc
    echo "# adding freesurfer" >> $HOME/.bashrc
    echo "export FREESURFER_HOME=/usr/local/freesurfer" >> $HOME/.bashrc
    echo "export SUBJECTS_DIR=\$FREESURFER_HOME/subjects" >> $HOME/.bashrc
    echo "export FS_LICENSE=\$HOME/KUL_apps/freesurfer/license.txt" >> $HOME/.bashrc
    echo "source \$FREESURFER_HOME/SetUpFreeSurfer.sh" >> $HOME/.bashrc
    sudo apt-get -y install tcsh
    mkdir -p $HOME/KUL_apps/freesurfer
    echo "Install the license.txt into /KUL_apps/freesurfer"
    rm freesurfer-linux-centos7_x86_64-7.1.1.tar.gz
else
    echo 'Already installed Freesurfer v7.1.1'
    echo '  however do not forget to install the license.txt into /$HOME/KUL_apps/freesurfer'
fi

# Installation of Ants
if ! [ -d "$HOME/KUL_apps/ANTs_installed" ]
then
    install_KUL_apps "Ants"
    wget https://raw.githubusercontent.com/cookpa/antsInstallExample/master/installANTs.sh
    chmod +x installANTs.sh
    sudo apt-get -y install cmake pkg-config
    ./installANTs.sh
    mv install ANTs_installed
    rm installANTs.sh
    rm -rf build
    cd
    echo "" >> $HOME/.bashrc
    echo "# adding ANTs" >> $HOME/.bashrc
    echo "export ANTSPATH="$HOME/KUL_apps/ANTs_installed/bin/"" >> $HOME/.bashrc
    echo "export PATH="\${ANTSPATH}:\$PATH"" >> $HOME/.bashrc
    source $HOME/.bashrc
else
    echo 'Already installed ANTs'
fi

# Installation of dcm2niix
if ! command -v dcm2niix &> /dev/null
then
    install_KUL_apps "dcm2niix"
    sudo apt-get -y install cmake pkg-config
    git clone https://github.com/rordenlab/dcm2niix.git
    cd dcm2niix
    mkdir build && cd build
    cmake -DZLIB_IMPLEMENTATION=Cloudflare -DUSE_JPEGLS=ON -DUSE_OPENJPEG=ON ..
    make
    cd
    echo "" >> $HOME/.bashrc
    echo "# adding dcm2nixx" >> $HOME/.bashrc
    echo "export PATH="$HOME/KUL_apps/dcm2niix/build/bin:\$PATH"" >> $HOME/.bashrc
    source $HOME/.bashrc
else
    echo 'Already installed dcm2niix'
fi

# Installation of dcm2bids
if ! command -v dcm2bids &> /dev/null
then
    install_KUL_apps "dcm2bids"
    pip install dcm2bids
else
    echo 'Already installed dcm2bids'
fi

# Installation of DCMTK
if ! command -v storescu &> /dev/null
then
    install_KUL_apps "DCMTK"
    sudo apt -y install dcmtk
else
    echo 'Already installed DCMTK'
fi

# Installation of KNT
if ! [ -d "$HOME/KUL_apps/KUL_NeuroImaging_Tools" ] 
then
    install_KUL_apps "KUL_NeuroImaging_Tools"
    git clone https://github.com/treanus/KUL_NeuroImaging_Tools.git
    cd KUL_NeuroImaging_Tools
    git checkout development
    cd
    echo "" >> $HOME/.bashrc
    echo "# adding KUL_NeuroImaging_Tools" >> $HOME/.bashrc
    echo "export PATH="$HOME/KUL_apps/KUL_NeuroImaging_Tools:\$PATH"" >> $HOME/.bashrc
    echo "export PYTHONPATH=$HOME/KUL_apps/mrtrix3/lib" >> $HOME/.bashrc
    source $HOME/.bashrc
else
    echo 'Already installed KUL_NeuroImaging_Tools'
fi

# Installation of VBG
if ! [ -d "$HOME/KUL_apps/KUL_VBG" ] 
then
    install_KUL_apps "KUL_VBG"
    git clone https://github.com/KUL-Radneuron/KUL_VBG.git
    echo "" >> $HOME/.bashrc
    echo "# adding KUL_VBG" >> $HOME/.bashrc
    echo "export PATH="$HOME/KUL_apps/KUL_VBG:\$PATH"" >> $HOME/.bashrc
    source $HOME/.bashrc
else
    echo 'Already installed KUL_VBG'
fi

# Installation of htop
if ! command -v htop &> /dev/null
then
    sudo apt-get install htop
else
    echo 'Already installed htop'
fi

# Installation of HD-BET
if ! command -v hd-bet &> /dev/null
then
    install_KUL_apps "HD-BET"
    git clone https://github.com/MIC-DKFZ/HD-BET
    cd HD-BET
    pip install -e .
    cd
else
    echo 'Already installed HD-BET'
fi

# Installation of Mevislab 3.4
if ! [ -d "$HOME/KUL_apps/MevislabSDK3.4/" ] 
then
    install_KUL_apps "Mevislab 3.4"
    wget https://mevislabdownloads.mevis.de/Download/MeVisLab3.4/Linux/GCC7-64/MeVisLabSDK3.4_gcc7-64.bin
    chmod u+x MeVisLabSDK3.4_gcc7-64.bin
    #mkdir MeVisLabSDK3.4 
    ./MeVisLabSDK3.4_gcc7-64.bin --prefix $HOME/KUL_apps/MevislabSDK3.4 --mode silent
    rm MeVisLabSDK3.4_gcc7-64.bin
else
    echo 'Already installed MevislabSDK3.4'
fi


echo ""
echo "All done. Please reboot."
echo "Install the Freesurfer license.txt into $HOME/KUL_apps/freesurfer/"
echo "Finally don't forget to install matlab, if not yet done so"


