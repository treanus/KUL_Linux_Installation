#!/bin/bash

# This script installs many NeuroImaging software for use in MRI neuroimaging...
# Stefan Sunaert - first version dd 08092020 - v0.1
#  current version dd 29092020 - v0.2

# We first define a function to keep installation of things tidy
function install_KUL_apps {
    cd
    mkdir -p KUL_apps
    cd KUL_apps
    #clear 
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
echo 'This script will install a lot of neuro-imaging software on a Linux Mint system'
echo '  for details see https://github.com/treanus/KUL_Linux_Installation'
echo '      it will take several minutes/hours to install (and compile, if needed) all software. '
echo '      You may have to reboot once, after which you have to restart the script.'
echo '      The script will check what has already been installed and continue installing software'
echo '      Note: the scripts depends on a full linux installation of Linux Mint 20'
echo '      This script may ask you a several times for your password in order to install software (sudo usage)'

read -r -p "Proceed with the installation? [y/n] " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    echo 'OK we continue'
else
    exit
fi
clear 

# all the following works on a full install of Linux Mint 20, however,
# we should add code to check dependencies on a minimal install of Mint 20, or Ubuntu, etc...


# Update an Upgrade all existing packages
echo 'The system will now ask you your password to update and upgrade all linux system software'
sudo apt update
sudo apt upgrade
sudo apt -y install git
clear
sleep 1

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

# Install needed packages
sudo apt-get -y install g++ zlib1g-dev

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

# Installation of FSL
if ! [ -d "/usr/local/fsl" ]
then
    install_KUL_apps "FSL"
    wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py
    sudo apt-get -y install python2.7
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

# Installation of Docker
if ! command -v docker &> /dev/null
then
    install_KUL_apps "Docker"
    # switching back to normal install, mainly because rootless does not have gpu support
    sudo apt-get -y update
    sudo apt-get -y remove docker docker-engine docker.io
    sudo apt-get -y install docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo groupadd docker
    sudo usermod -aG docker $USER
    
else
    echo 'Already installed Docker'
fi

# Installation of Freesurfer
#if ! command -v freeview &> /dev/null
if ! [ -d "/usr/local/freesurfer" ]
then
    install_KUL_apps "Freesurfer v 7.1.1"
    wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.1.1/freesurfer-linux-centos7_x86_64-7.1.1.tar.gz
    sudo tar -C /usr/local -zxvpf freesurfer-linux-centos7_x86_64-7.1.1.tar.gz
    sudo chown -R $(id -u):$(id -g) /usr/local/freesurfer
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
    git clone https://github.com/UNFmontreal/Dcm2Bids.git
    cd Dcm2Bids/
    pip install -e .
else
    echo 'Already installed dcm2bids'
fi

# Installation of DCMTK
if ! command -v storescu &> /dev/null
then
    install_KUL_apps "DCMTK"
    sudo apt-get -y install dcmtk
else
    echo 'Already installed DCMTK'
fi


# Installation of GDCM (other dicom tools)
if ! command -v gdcmtar &> /dev/null
then
    install_KUL_apps "GDCM"
    sudo apt-get -y install libgdcm-tools
else
    echo 'Already installed GDCM'
fi

# Installation of SPM12
if ! [ -d "$HOME/KUL_apps/spm12" ] 
then
    install_KUL_apps "spm12"
    wget https://www.fil.ion.ucl.ac.uk/spm/download/restricted/eldorado/spm12.zip
    unzip spm12.zip
    #Note: Matlab needs to be installed first to compile the mex files
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
    install_KUL_apps "cat12"
    wget http://www.neuro.uni-jena.de/cat12/cat12_latest.zip
    unzip cat12_latest.zip -d spm12/toolbox
    rm cat12_latest.zip
    cd
else
    echo 'Already installed cat12'
fi
# Installation of Lead-DBS
if ! [ -d "$HOME/KUL_apps/leaddbs" ] 
then
    install_KUL_apps "Lead-BDS"
    git clone https://github.com/netstim/leaddbs.git
    wget -O leaddbs_data.zip http://www.lead-dbs.org/release/download.php?id=data_pcloud
    unzip leaddbs_data.zip -d leaddbs/
    rm leaddbs_data.zip
    cd
else
    echo 'Already installed Lead-DBS'
fi

# Installation of CONN
if ! [ -d "$HOME/KUL_apps/conn20b" ] 
then
    install_KUL_apps "conn-toolbox version 20b"
    wget https://www.nitrc.org/frs/download.php/11714/conn20b.zip
    unzip conn20b.zip
    mv conn conn20b
    rm conn20b.zip
    cd
else
    echo 'Already installed conn-toolbox version 20b'
fi

# Installation of KNT
if ! [ -d "$HOME/KUL_apps/KUL_NeuroImaging_Tools" ] 
then
    install_KUL_apps "KUL_NeuroImaging_Tools"
    git clone https://github.com/treanus/KUL_NeuroImaging_Tools.git
    cd KUL_NeuroImaging_Tools
    git checkout development
    cd ..
    sudo apt-get install libopenblas0
    cp KUL_NeuroImaging_Tools/share/eddy_cuda11.2_linux.tar.gz .
    tar -xzvf eddy_cuda11.2_linux.tar.gz
    rm eddy_cuda11.2_linux.tar.gz
    sudo ln -s $HOME/KUL_apps/eddy_cuda/eddy_cuda11.2 /usr/local/fsl/bin/eddy_cuda
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

# Installation of FWT
if ! [ -d "$HOME/KUL_apps/KUL_FWT" ] 
then
    install_KUL_apps "KUL_FWT"
    git clone https://github.com/Rad-dude/KUL_FWT.git
    echo "" >> $HOME/.bashrc
    echo "# adding KUL_VBG" >> $HOME/.bashrc
    echo "export PATH="$HOME/KUL_apps/KUL_FWT:\$PATH"" >> $HOME/.bashrc
    source $HOME/.bashrc
else
    echo 'Already installed KUL_FWT'
fi

# Installation of Scilpy
if ! command -v scil_filter_tractogram.py &> /dev/null
then
    install_KUL_apps "Scilpy"
    sudo apt-get -y install libblas-dev liblapack-dev
    git clone https://github.com/scilus/scilpy.git
    cd scilpy
    pip install -e .
else
    echo 'Already installed Scilpy'
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
#
# we suppose it is not a problem to install the nvidia toolkit on a system without an nvidea graphics card
if ! command -v nvcc &> /dev/null
then
    # we install basic toolkit:
    sudo apt-get -y install nvidia-cuda-toolkit

    # install full toolkit for eddy_cuda compilation:
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
    sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
    wget https://developer.download.nvidia.com/compute/cuda/11.2.1/local_installers/cuda-repo-ubuntu2004-11-2-local_11.2.1-460.32.03-1_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu2004-11-2-local_11.2.1-460.32.03-1_amd64.deb
    sudo apt-key add /var/cuda-repo-ubuntu2004-11-2-local/7fa2af80.pub
    sudo apt-get update
    sudo apt-get -y install cuda
    rm cuda-repo-ubuntu2004-11-2-local_11.2.1-460.32.03-1_amd64.deb

    # CudNN 
    # Doesn't work since you need to log-in to developer account of Nvidia
    cd KUL_apps
    #wget https://developer.nvidia.com/compute/machine-learning/cudnn/secure/8.0.5/10.1_20201106/cudnn-10.1-linux-x64-v8.0.5.39.tgz
    #tar -xvzf cudnn-10.1-linux-x64-v8.0.5.39.tgz
    #sudo cp cuda/include/cudnn*.h /usr/lib/cuda/include
    #sudo cp cuda/lib64/libcudnn* /usr/lib/cuda/lib64
    #sudo chmod a+r /usr/lib/cuda/include/cudnn*.h /usr/lib/cuda/lib64/libcudnn*

    wget https://developer.nvidia.com/compute/machine-learning/cudnn/secure/8.1.0.77/11.2_20210127/Ubuntu20_04-x64/libcudnn8_8.1.0.77-1+cuda11.2_amd64.deb
    sudo dpkg -i libcudnn8_8.1.0.77-1+cuda11.2_amd64.deb

    cd
    echo "# adding CudNN" >> $HOME/.bashrc
    echo "export LD_LIBRARY_PATH="/usr/lib/cuda/lib64:\$LD_LIBRARY_PATH"" >> $HOME/.bashrc
 
    # Tensorflow
    pip install --upgrade TensorFlow
    
    # also install nvidia cuda support for docker
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu20.04/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt-get update
    sudo apt-get -y install nvidia-container-runtime

else
    echo 'Already installed Nvidia cuda toolkit'
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

# Installation of FastSurfer
if ! [ -d "$HOME/KUL_apps/FastSurfer/" ] 
then
    install_KUL_apps "FastSurfer"
    git clone https://github.com/Deep-MI/FastSurfer.git
    echo "" >> $HOME/.bashrc
    echo "# adding FastSurfer" >> $HOME/.bashrc
    echo "export FASTSURFER_HOME="$HOME/KUL_apps/FastSurfer"" >> $HOME/.bashrc
    source $HOME/.bashrc
    # install Pytorch
    conda install pytorch torchvision torchaudio cudatoolkit=10.2 -c pytorch
else
    echo 'Already installed MevislabSDK3.4'
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

# Installation of Pulse Secure
#if ! [ -d "/usr/local/pulse" ] 
#then
#    install_KUL_apps "Pulse Secure VPN client (only useful in UZLeuven environment)"
#    wget https://support.plymouth.edu/kb_images/Junos_Pulse/vpn_installers/ps-pulse-linux-9.1r8.0-b165-ubuntu-debian-64-bit-installer.deb
#    sudo dpkg -i ps-pulse-linux-9.1r8.0-b165-ubuntu-debian-64-bit-installer.deb
#    sudo add-apt-repository 'deb http://archive.ubuntu.com/ubuntu bionic main universe'
#    sudo apt update
#    sudo apt install -t bionic libwebkitgtk-1.0-0
#    rm ps-pulse-linux-9.1r8.0-b165-ubuntu-debian-64-bit-installer.deb
#fi

# Installation of Robex
if ! [ -d "$HOME/KUL_apps/ROBEX/" ] 
then
    echo "Installing ROBEX"
    wget -qO- "https://www.nitrc.org/frs/download.php/5994/ROBEXv12.linux64.tar.gz//?i_agree=1&download_now=1" | \
        tar zx -C $HOME/KUL_apps/
else
    echo 'Already installed ROBEX'
fi

echo ""
echo "All done. Please reboot."
echo "Install the Freesurfer license.txt into $HOME/KUL_apps/freesurfer/"
echo "Finally don't forget to install matlab, if not yet done so"


