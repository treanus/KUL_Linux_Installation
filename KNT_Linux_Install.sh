#!/bin/bash

# This script installs many NeuroImaging software for use in MRI neuroimaging...
# Stefan Sunaert - first version dd 08092020 - v0.1
#  current version dd 19102021 - v0.5

# ask each time to install a program
auto=0


# Define the install location
install_location=/usr/local/KUL_apps
KUL_apps_config="${install_location}/KUL_apps_config"
KUL_app_versions="${install_location}/KUL_apps_versions"

# First define a function to keep installation of things tidy
function install_KUL_apps {
    cd ${install_location}
    source $HOME/.bashrc
    echo -e "\n"
    read -r -p "Proceed with the installation of $1? [y/n] " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
        echo 'OK we continue'
    else
        exit
    fi
}


# Check if we are on WSL2
wsl=0
if [[ $(grep microsoft /proc/version) ]]; then
    wsl=1
fi


# Give some information & ask permission to continue (if not yet done so)
if [ $wsl -eq 1 ]; then
    echo 'This script will install a lot of neuro-imaging software on WSL2'
else  
    echo 'This script will install a lot of neuro-imaging software on a Linux system'
fi
if [ ! -f $HOME/.KUL_apps_install_yes ]; then
echo '      for details see https://github.com/treanus/KUL_Linux_Installation'
echo '      it will take several hours to install (and compile, if needed) all software. '
echo '      You may have to exit the shell several times, after which you have to restart the script.'
echo '      The script will check what has already been installed and continue installing software'
echo '      This script may ask you a several times for your password in order to install software (sudo usage)'

read -r -p "Proceed with the installation? [y/n] " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    echo 'OK we continue'
    touch $HOME/.KUL_apps_install_yes
else
    exit
fi
fi


# Check if users have installed dependancies for WSL2
if [ $wsl -eq 1 ] && [ ! -f $HOME/.KUL_apps_install_wsl2_yes ]; then
    echo -e "\n"
    echo "You are running WSL"
    echo "  this script only works well on WSL2 in win11 (or latest preview win10)"
    echo "  be sure to INSTALL FIRST ON WIN11: "
    echo "      1/ enable nvidia cuda in WSL following https://docs.microsoft.com/en-us/windows/ai/directml/gpu-cuda-in-wsl "
    echo "      2/ install docker in win11 and setup wsl2 - ubuntu integration"
    echo "      otherwise, exit the script (answer "no" below) and do this first"
    read -r -p "Proceed with the installation? [y/n] " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
        echo 'OK we continue'
        touch $HOME/.KUL_apps_install_wsl2_yes
    else
        exit
    fi
fi


# ---- MAIN ----

# Now make the install directory
echo "Making the install directory, readable and executable for all users"
echo "  you might have to give your password (if needed)"
sleep 3
# Determine group id
kul_group=$(id -g)
#echo $kul_group
sudo mkdir -p ${install_location}
sudo chgrp -R ${kul_group} ${install_location}
sudo chmod -R 770 ${install_location}


# Install requirements - TODO: check what is needed!
if [ ! -f ${install_location}/.KUL_apps_install_required_yes ]; then
    echo -e "\n"
    echo "We first install a number of needed packages"
    echo 'The system will now ask for your password (if needed) to update and upgrade all linux system software'
    sleep 4
    sudo apt update
    sudo apt upgrade
    sudo apt -y install git \
        libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 \
        g++ zlib1g-dev \
        python-is-python3 libeigen3-dev zlib1g-dev libqt5opengl5-dev libqt5svg5-dev libgl1-mesa-dev libfftw3-dev libtiff5-dev libpng-dev \
        tcsh \
        cmake pkg-config
    if [ $wsl -eq 1 ];then
        sudo apt -y install nautilus
    fi
    touch ${install_location}/.KUL_apps_install_required_yes
fi


# initiate the config file to be sourced by .bashrc
if [ ! -f ${KUL_apps_config} ]; then
    # the KUL_apps_config
    echo "export KUL_apps_DIR=${install_location}" > ${KUL_apps_config}
    # the KUL_apps_version
    cat <<EOT > $KUL_app_versions
#!/bin/bash
EOT
    # update .bashrc
    echo "" >> .bashrc
    echo "# Source the KUL_apps and other neuroimaging software" >> .bashrc
    echo "source ${KUL_apps_config}"  >> .bashrc
    source .bashrc
    sleep 4
fi


# Installation of Anaconda --- BEGIN
if ! command -v conda &> /dev/null
then
    install_KUL_apps "Anaconda3"
    anaconda_version=Anaconda3-2021.05-Linux-x86_64
    #sudo apt-get -y install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
    wget https://repo.anaconda.com/archive/${anaconda_version}.sh
    echo -e "\n\n"
    echo "Here we give the installation instructions for anaconda..."
    echo "ACCEPT THE LICENSE"
    echo "CHANGE THE INSTALL DIRECTORY to /usr/local/KUL_apps/anaconda3"
    echo "Say no NO initialize Anaconda3"
    read -p "Press any key to continue... " -n1 -s
    bash ${anaconda_version}.sh
    rm ${anaconda_version}.sh
    echo "" >> ${KUL_apps_config}
    echo "# load Anaconda3"

# begin cat command - see below
    cat <<EOT >> ${KUL_apps_config}
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="\$('/usr/local/KUL_apps/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "\$__conda_setup"
else
    if [ -f "/usr/local/KUL_apps/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/usr/local/KUL_apps/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/usr/local/KUL_apps/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

EOT
# end cat command - see above
    echo "echo -e \"\t Anaconda3\t-\t$anaconda_version" \" >> $KUL_app_versions
    echo -e "\n\n\n"
    if [ $wsl -eq 1 ];then
        echo 'Now exit WSL2-Ubuntu and run the KNT_Linux_install.sh again from new terminal'
    else
        echo 'Now exit this terminal and run the KNT_Linux_install.sh again from a new terminal'
    fi
    exit
else
    echo 'Already installed Anaconda3'
fi
# Installation of Anaconda --- END


# Setup some useful stuff
if ! [ -f "${install_location}/.KUL_apps_useful_installed" ]
then
    echo "Setting up useful aliases "

# begin cat command - see below
    cat <<EOT >> ${KUL_apps_config}
# KUL_apps - Setting up some useful stuff
alias ll='ls -alhF'
alias code='code &'

EOT
# end cat command - see above

    touch ${install_location}/.KUL_apps_useful_installed
else
    echo 'Already set up useful aliases'
fi


# install cuda toolkit
install_cuda=1
if [ $wsl -eq 1 ]; then
    echo "Already installed cuda in win11"
else
    if [ $install_cuda -eq 1 ]; then
        if ! command -v nvcc &> /dev/null
        then
            wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
            sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
            sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
            sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
            sudo apt-get update
            sudo apt-get -y install cuda
        fi
    fi
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


# Installation of HD-BET
if ! command -v hd-bet &> /dev/null
then
    install_KUL_apps "HD-BET"
    git clone https://github.com/MIC-DKFZ/HD-BET
    cd HD-BET
    pip install -e .
    cd
    echo "echo -e \"\t HD-BET\t\t-\t\$(cd $KUL_apps_DIR/HD-BET; git status | head -2 | tail -1)\"" >> $KUL_app_versions
else
    echo 'Already installed HD-BET'
fi


# Installation of MRtrix3
if ! command -v mrconvert &> /dev/null
then
    install_KUL_apps "MRtrix3"
    git clone https://github.com/MRtrix3/mrtrix3.git
    cd mrtrix3
    ./configure
    ./build
# begin cat command - see below
    cat <<EOT >> ${KUL_apps_config}
# adding MRTRIX3
export PATH="${install_location}/mrtrix3/bin:\$PATH"

EOT
# end cat command - see above
    echo "echo -e \"\t mrtrix3\t-\t\$(mrconvert -version | head -1 | awk '{ print \$3 }') \"" >> $KUL_app_versions
    ${install_location}/KUL_apps/mrtrix/install_mime_types.sh
    
else
    echo 'Already installed MRtrix3'
fi


# Installation of Docker
if ! command -v docker &> /dev/null
then
    install_KUL_apps "Docker"
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


# lets's make install current
source $HOME/.bashrc


# download a number of Docker containers
if [ ! -f ${install_location}/.KUL_apps_install_containers_yes ]; then
    echo "Now installing some useful docker containers"
    sleep 4
    docker pull jenspetersen/hd-glio-auto
    docker pull hansencb/synb0
    echo "echo -e \"\t hd-glio-auto\t-\tcannot be checked (but latest docker) \"" >> $KUL_app_versions
    echo "echo -e \"\t synb0\t\t-\tcannot be checked (but latest docker) \"" >> $KUL_app_versions
    touch ${install_location}/.KUL_apps_install_containers_yes
else
    echo "Already installed required docker containers"
fi


# Installation of FSL
if ! [ -d "/usr/local/fsl" ]
then
    install_KUL_apps "FSL"
    if [ $wsl -eq 1 ]; then
        sudo apt-get -y install dc python mesa-utils gedit pulseaudio libquadmath0 libgtk2.0-0 firefox
    fi
    wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py
    sudo apt-get -y install python2.7
    echo -e "\n\n\n"
    echo "Here we give the installation instructions for FSL..."
    echo "it is ok to install to the default /usr/local/fsl directory"
    read -p "Press any key to continue... " -n1 -s
    sudo python2.7 fslinstaller.py
    rm fslinstaller.py
    cat <<EOT >> ${KUL_apps_config}
# Installing FSL
FSLDIR=/usr/local/fsl
. \${FSLDIR}/etc/fslconf/fsl.sh
PATH=\${FSLDIR}/bin:\${PATH}
export FSLDIR PATH

EOT
    echo "echo -e \"\t FSL\t\t-\t\$(cat \$FSLDIR/etc/fslversion)\"" >> $KUL_app_versions
else
    echo 'Already installed FSL'
fi


# Installation of Freesurfer
#if ! command -v freeview &> /dev/null
if ! [ -d "${install_location}/freesurfer" ]
then
    freesurfer_version1="freesurfer-linux-ubuntu18_amd64-7.2.0"
    freesurfer_version2="7.2.0"
    install_KUL_apps "Freesurfer v ${freesurfer_version2}"
    wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${freesurfer_version2}/${freesurfer_version1}.tar.gz
    tar -zxvpf ${freesurfer_version1}.tar.gz
    cat <<EOT >> ${KUL_apps_config}
# adding freesurfer
export FREESURFER_HOME=${install_location}/freesurfer
export SUBJECTS_DIR=\$FREESURFER_HOME/subjects
export FS_LICENSE=${install_location}/freesurfer_license/license.txt
source \$FREESURFER_HOME/SetUpFreeSurfer.sh

EOT

    #sudo apt-get -y install tcsh
    echo "echo -e \"\t freesurfer\t-\t\$(recon-all -version) \"" >> $KUL_app_versions
    mkdir -p ${install_location}/freesurfer_license
    echo "Install the license.txt into ${install_location}/reesurfer_license"
    rm ${freesurfer_version1}.tar.gz
else
    echo 'Already installed Freesurfer ${freesurfer_version2}'
    echo '  however do not forget to install the license.txt into ${install_location}/freesurfer_license'
fi


# Installation of Ants
if ! [ -d "${install_location}/ANTs_installed" ]
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
    cat <<EOT >> ${KUL_apps_config}
# adding ANTs
export ANTSPATH=${install_location}/ANTs_installed/bin/
export PATH=\${ANTSPATH}:\$PATH

EOT
    echo "echo -e \"\t ants\t\t-\t\$(antsRegistration --version | head -1 | awk '{ print \$3 }') \"" >> $KUL_app_versions
else
    echo 'Already installed ANTs'
fi


# Installation of dcm2niix
if ! command -v dcm2niix &> /dev/null
then
    install_KUL_apps "dcm2niix"
    #sudo apt-get -y install cmake pkg-config
    git clone https://github.com/rordenlab/dcm2niix.git
    cd dcm2niix
    mkdir build && cd build
    cmake -DZLIB_IMPLEMENTATION=Cloudflare -DUSE_JPEGLS=ON -DUSE_OPENJPEG=ON ..
    make
    cat <<EOT >> ${KUL_apps_config}
# adding dcm2nixx
export PATH="${install_location}/dcm2niix/build/bin:\$PATH"

EOT
    echo "echo -e \"\t dcm2nixx\t-\t\$(dcm2niix --version | head -1 | awk '{ print \$5 }') \"" >> $KUL_app_versions 
else
    echo 'Already installed dcm2niix'
fi


# Installation of dcm2bids
if ! command -v dcm2bids &> /dev/null
then
    install_KUL_apps "dcm2bids"
    pip install dcm2bids
    echo "echo -e \"\t dcm2bids\t-\t\$(dcm2bids -h | grep dcm2bids | tail -1 | awk '{ print \$2 }') \"" >> $KUL_app_versions 
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



# Setup of Matlab
#if ! command -v matlab &> /dev/null
#then
#    echo "" >> $HOME/.bashrc
#    echo "# adding matlab" >> $HOME/.bashrc
#    echo "export PATH=/usr/local/MATLAB/R2018a/bin:\$PATH" >> $HOME/.bashrc
#    echo "alias matlab='xrandr --dpi 144; matlab &'" >> $HOME/.bashrc
#fi


# Installation of SPM12
if ! [ -d "${install_location}/spm12" ] 
then
    install_KUL_apps "spm12"
    wget https://www.fil.ion.ucl.ac.uk/spm/download/restricted/eldorado/spm12.zip
    unzip spm12.zip
    #Note: Matlab needs to be installed first to compile the mex files
    read -r -p "Do you want to recompile to SPM binaries (if so, you need yo have matlab installed) [y/n] " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
        echo 'OK we continue'
        cd spm12/src
        make distclean
        make && make install
        make external-distclean
        make external && make external-install
        cd ${install_location}
    fi
    rm spm12.zip
    echo "echo -e \"\t spm12\t\t-\tcheck from within matlab please \"" >> $KUL_app_versions
else
    echo 'Already installed spm12'
fi


# Installation of cat12
if ! [ -d "${install_location}/spm12/toolbox/cat12" ] 
then
    install_KUL_apps "cat12"
    wget http://www.neuro.uni-jena.de/cat12/cat12_latest.zip
    unzip cat12_latest.zip -d spm12/toolbox
    rm cat12_latest.zip
    echo "echo -e \"\t cat12\t\t-\tcheck from within matlab please \"" >> $KUL_app_versions
else
    echo 'Already installed cat12'
fi


# Installation of Lead-DBS
if ! [ -d "${install_location}/leaddbs" ] 
then
    install_KUL_apps "Lead-DBS"
    git clone https://github.com/netstim/leaddbs.git
    wget -O leaddbs_data.zip http://www.lead-dbs.org/release/download.php?id=data_pcloud
    echo -e "\n\n\n"
    echo "Here we give the installation instructions for Lead-dbs..."
    echo "answer yes when asked to replace templates"
    read -p "Press any key to continue... " -n1 -s
    unzip leaddbs_data.zip -d leaddbs/
    rm leaddbs_data.zip
    echo "echo -e \"\t Lead-DBS\t\t-\tcheck from within matlab please \"" >> $KUL_app_versions
else
    echo 'Already installed Lead-DBS'
fi


# Installation of CONN
conn_version="con20b"
if ! [ -d "${install_location}/${conn_version}" ] 
then
    
    install_KUL_apps "conn-toolbox version ${conn_version}"
    wget https://www.nitrc.org/frs/download.php/11714/${conn_version}.zip
    unzip${conn_version}.zip
    mv conn ${conn_version}
    rm ${conn_version}.zip
    echo "echo -e \"\t conn\t\t-\t${conn_version} \"" >> $KUL_app_versions
else
    echo 'Already installed conn-toolbox version 20b'
fi

exit

# Installation of KNT
if ! [ -d "${install_location}/KUL_NeuroImaging_Tools" ] 
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
    sudo ln -s ${install_location}/eddy_cuda/eddy_cuda11.2 /usr/local/fsl/bin/eddy_cuda
    cat <<EOT >> ${KUL_apps_config}
# adding KUL_NeuroImaging_Tools
export PATH="${install_location}/KUL_NeuroImaging_Tools:\$PATH"
export PYTHONPATH=${install_location}/mrtrix3/lib

EOT

else
    echo 'Already installed KUL_NeuroImaging_Tools'
fi


# Installation of VBG
if ! [ -d "${install_location}/KUL_VBG" ] 
then
    install_KUL_apps "KUL_VBG"
    git clone https://github.com/treanus/KUL_VBG.git
    cat <<EOT >> ${KUL_apps_config}
# adding KUL_VBG
export PATH="${install_location}/KUL_VBG:\$PATH"

EOT
else
    echo 'Already installed KUL_VBG'
fi


# Installation of FWT
if ! [ -d "${install_location}/KUL_FWT" ] 
then
    install_KUL_apps "KUL_FWT"
    git clone https://github.com/treanus/KUL_FWT.git
    cd KUL_FWT
    git checkout dev_cshdp
    cd ..
    cat <<EOT >> ${KUL_apps_config}
# adding KUL_VBG
export PATH="${install_location}/KUL_FWT:\$PATH"

EOT

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


install_cuda=0
if [ $install_cuda -eq 1 ]; then
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
fi


# Installation of FastSurfer
if ! [ -d "${install_location}/FastSurfer/" ] 
then
    install_KUL_apps "FastSurfer"
    git clone https://github.com/Deep-MI/FastSurfer.git
    cat <<EOT >> ${KUL_apps_config}
# adding FastSurfer
export FASTSURFER_HOME="${install_location}/FastSurfer"

EOT
    source ${install_location}/KUL_apps_config
    # install Pytorch
    conda install pytorch torchvision torchaudio cudatoolkit=10.2 -c pytorch
else
    echo 'Already installed FastSurfer'
fi


# Installation of Mevislab 3.4
if ! [ -d "${install_location}/MevislabSDK3.4/" ] 
then
    install_KUL_apps "Mevislab 3.4"
    wget https://mevislabdownloads.mevis.de/Download/MeVisLab3.4/Linux/GCC7-64/MeVisLabSDK3.4_gcc7-64.bin
    chmod u+x MeVisLabSDK3.4_gcc7-64.bin
    #mkdir MeVisLabSDK3.4 
    ./MeVisLabSDK3.4_gcc7-64.bin --prefix ${install_location}/MevislabSDK3.4 --mode silent
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
if ! [ -d "${install_location}/ROBEX/" ] 
then
    install_KUL_apps "ROBEX"
    wget -qO- "https://www.nitrc.org/frs/download.php/5994/ROBEXv12.linux64.tar.gz//?i_agree=1&download_now=1" | \
        tar zx -C ${install_location}
    cat <<EOT >> ${KUL_apps_config}
# adding ROBEX
export PATH="${install_location}/ROBEX:\$PATH"

EOT

else
    echo 'Already installed ROBEX'
fi

# Installation of nvtop
if ! command -v nvtop &> /dev/null
then
    sudo apt install cmake libncurses5-dev libncursesw5-dev
    git clone https://github.com/Syllo/nvtop.git
    mkdir -p nvtop/build && cd nvtop/build
    cmake ..
    make
    sudo make install
    cd ../..
    rm -fr nvtop
fi


# complete the config file to be sourced by .bashrc
KULcheck=${install_location}/.KUL_apps_installed_prompts
if [ ! -f ${KULcheck} ]; then
    # the KUL_apps_config
    echo "# Welcome to KUL_Apps" >> ${KUL_apps_config}
    echo "echo \"Welcome to KUL_Apps\" " >> ${KUL_apps_config}
    echo "echo \"  installation DIR is  ${install_location}\" " >> ${KUL_apps_config}
    echo "echo \"  the config file is   ${KUL_apps_config}\" " >> ${KUL_apps_config}
    echo "echo \"   installed software/version is: \""
    echo "source $KUL_app_versions"
    echo "echo \" \" " >> ${KUL_apps_config}
    touch $KULcheck
fi

echo -e "\n\n\n"
echo "All done. Please reboot."
echo "Install the Freesurfer license.txt into ${install_location}/freesurfer_license/"
echo "Finally don't forget to install matlab, if not yet done so"
