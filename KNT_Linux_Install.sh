#!/bin/bash

# This script installs all NeuroImaging software...
# Stefan Sunaert - 08092020

# Installation of Anaconda
if ! command -v conda &> /dev/null
then
    sudo apt-get -y install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
    wget https://repo.anaconda.com/archive/Anaconda3-2020.07-Linux-x86_64.sh
    bash Anaconda3-2020.07-Linux-x86_64.sh
    rm Anaconda3-2020.07-Linux-x86_64.sh
    echo 'Now reboot and restart the KNT_Linux_install.sh'
    exit
else
    echo 'Already installed Anaconda'
fi

# Install numlockx
if ! command -v numlockx &> /dev/null
then
    sudo apt install numlockx
else
    echo 'Already installed numlockx; activate it in login-window'
fi

# Installation of htop
if ! command -v htop &> /dev/null
then
    sudo apt-get install htop
else
    echo 'Already installed htop'
fi

# Installation of Nvidia cuda toolkit
# Read https://medium.com/@stephengregory_69986/installing-cuda-10-1-on-ubuntu-20-04-e562a5e724a0
# or 
# https://linuxconfig.org/how-to-install-cuda-on-ubuntu-20-04-focal-fossa-linux
# and
# https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&target_distro=Ubuntu&target_version=2004&target_type=deblocal
# https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=FSL;9e6a81c9.2002
if ! command -v nvcc &> /dev/null
then
    # to only install basic toolkit:
    sudo apt-get -y install nvidia-cuda-toolkit
    # to install full toolkit for eddy_cuda compilation:
    # wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
    # sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
    # wget https://developer.download.nvidia.com/compute/cuda/11.0.3/local_installers/cuda-repo-ubuntu2004-11-0-local_11.0.3-450.51.06-1_amd64.deb
    # sudo dpkg -i cuda-repo-ubuntu2004-11-0-local_11.0.3-450.51.06-1_amd64.deb
    # sudo apt-key add /var/cuda-repo-ubuntu2004-11-0-local/7fa2af80.pub
    # sudo apt-get update
    # sudo apt-get -y install cuda
    # rm cuda-repo-ubuntu2004-11-0-local_11.0.3-450.51.06-1_amd64.deb 
else
    echo 'Already installed Nvidia cuda toolkit'
fi

# Installation of Visual Studio Code
if ! command -v code &> /dev/null
then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt-get -y install apt-transport-https
    sudo apt-get -y update
    sudo apt-get -y install code
    rm packages.microsoft.gpg
else
    echo 'Already installed Visual Studio Code'
fi

# Installation of MRtrix3
if ! command -v mrconvert &> /dev/null
then
    cd
    mkdir -p KUL_apps
    cd KUL_apps
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

# Installation of FSL
#if ! command -v fslmaths &> /dev/null
if ! [ -d "/usr/local/fsl" ]
then
    cd
    mkdir -p KUL_apps
    cd KUL_apps
    wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py
    sudo python2.7 fslinstaller.py
    rm fslinstaller.py
    cd
else
    echo 'Already installed FSL'
fi

# Installation of Docker
if ! command -v docker &> /dev/null
then
    sudo apt-get -y install apt-transport-https ca-certificates \
    curl gnupg-agent software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt-get -y update
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io
    #sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker 
else
    echo 'Already installed Docker'
fi


# Installation of Freesurfer
#if ! command -v freeview &> /dev/null
if ! [ -d "/usr/local/freesurfer" ]
then
    cd
    mkdir -p KUL_apps
    cd KUL_apps
    wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.1.1/freesurfer-linux-centos7_x86_64-7.1.1.tar.gz
    sudo tar -C /usr/local -zxvpf freesurfer-linux-centos7_x86_64-7.1.1.tar.gz
    echo "" >> $HOME/.bashrc
    echo "# adding freesurfer" >> $HOME/.bashrc
    echo "export FREESURFER_HOME=/usr/local/freesurfer" >> $HOME/.bashrc
    echo "export SUBJECTS_DIR=\$FREESURFER_HOME/subjects" >> $HOME/.bashrc
    echo "source \$FREESURFER_HOME/SetUpFreeSurfer.sh" >> $HOME/.bashrc
    sudo apt-get -y install tcsh
    sudo mkdir -p /KUL/apps/freesurfer
    echo "Install the license.txt into /KUL_apps/freesurfer"
    rm freesurfer-linux-centos7_x86_64-7.1.1.tar.gz
else
    echo 'Already installed Freesurfer'
fi

# Installation of Ants
if ! [ -d "$HOME/KUL_apps/ANTs_installed" ]
then
    cd
    mkdir -p KUL_apps
    cd KUL_apps
    wget https://raw.githubusercontent.com/cookpa/antsInstallExample/master/installANTs.sh
    chmod +x installANTs.sh
    ./installANTs.sh
    mv install ANTs_installed
    rm installANTs.sh
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
    cd
    mkdir -p KUL_apps
    cd KUL_apps
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
    pip install git+git://github.com/jooh/Dcm2Bids
else
    echo 'Already installed dcm2bids'
fi

# Installation of SPM12
if ! [ -d "$HOME/KUL_apps/spm12" ] 
then
    cd
    mkdir -p KUL_apps
    cd KUL_apps
    wget https://www.fil.ion.ucl.ac.uk/spm/download/restricted/eldorado/spm12.zip
    unzip spm12.zip
    #Note: Matlab needs to be installed first
    cd spm12/src
    make distclean
    make && make install
    make external-distclean
    make external && make external-install
    cd $HOME/KUL_apps
    rm spm12.zip
    cd
else
    echo 'Already installed spm12'
fi

# Installation of cat12
if ! [ -d "$HOME/KUL_apps/spm12/toolbox/cat12" ] 
then
    cd
    mkdir -p KUL_apps
    cd KUL_apps
    wget http://www.neuro.uni-jena.de/cat12/cat12_latest.zip
    unzip cat12_latest.zip -d spm12/toolbox
    rm cat12_latest.zip
    cd
else
    echo 'Already installed cat12'
fi

# Installation of CONN
if ! [ -d "$HOME/KUL_apps/conn19c" ] 
then
    cd
    mkdir -p KUL_apps
    cd KUL_apps
    wget https://www.nitrc.org/frs/download.php/11714/conn19c.zip
    unzip conn19c.zip
    mv conn conn19c
    rm conn19c.zip
    cd
else
    echo 'Already installed conn toolbox'
fi

# Installation of KNT
if ! [ -d "$HOME/KUL_apps/KUL_NeuroImaging_Tools" ] 
then
    cd
    mkdir -p KUL_apps
    cd KUL_apps
    git clone https://github.com/treanus/KUL_NeuroImaging_Tools.git
    cd
    echo "" >> $HOME/.bashrc
    echo "# adding KUL_NeuroImaging_Tools" >> $HOME/.bashrc
    echo "export PATH="$HOME/KUL_apps/KUL_NeuroImaging_Tools:\$PATH"" >> $HOME/.bashrc
    echo "export PYTHONPATH=$HOME/KUL_apps/mrtrix3/lib" >> $HOME/.bashrc
    source $HOME/.bashrc
else
    echo 'Already installed KUL_NeuroImaging_Tools'
fi

# Installation of Aliza
if ! command -v aliza &> /dev/null
then
    cd
    mkdir -p KUL_apps
    cd KUL_apps
    wget dropbox.com/s/vjdq8k2qxq5x4mo/aliza_1.98.32.2.deb
    sudo dpkg -i aliza_1.98.32.2.deb
    rm aliza_1.98.32.2.deb
else
    echo 'Already installed Aliza'
fi

echo ""
echo "All done. Please reboot."
echo "Install the Freesurfer license.txt into /KUL_apps/freesurfer"
echo "Finally don't forget to install matlab"

