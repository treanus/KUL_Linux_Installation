#!/bin/bash

# This script installs many NeuroImaging software for use in 
# MRI neuroimaging on Linux, WSL2 or macOS...
# Stefan Sunaert - first version dd 08092020 - v0.1
#  current version dd 01112021 - v0.6

# ask each time to install a program
if [ ! -z $1 ]; then
    if [ $1 = "auto" ]; then
        auto=1
    fi
else 
    auto=0
fi

# do you want to install cuda (only for an nvidia GPU)
install_cuda=1


# Define the install location
install_location=/usr/local/KUL_apps
KUL_apps_config="${install_location}/KUL_apps_config"
KUL_apps_versions="${install_location}/KUL_apps_versions"


# check the operating system
#   1 for macOS
#   2 for WSL2
#   3 for Ubuntu
if [[ $(uname | grep Darwin) ]];then
    local_os=1
    os_name="macOS"
    bashfile=$HOME/.bash_profile
elif [[ $(grep microsoft /proc/version) ]]; then
    local_os=2
    os_name="Windows-WSL2"
    bashfile=$HOME/.bashrc
else
    local_os=3
    os_name="Linux"
    bashfile=$HOME/.bashrc
fi
echo "This script will install a lot of neuro-imaging software on ${os_name}"


# Define functions to keep installation of things tidy
function install_KUL_apps {
    cd ${install_location}
    source $bashfile
    echo -e "\n"
    do_not_install=0
    if [ $auto -eq 0 ]; then
        read -r -p "Proceed with the installation of $1? [Y/n] " prompt
        prompt=${prompt:-y}
        if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
            echo 'OK we continue'
        else
            do_not_install=1
        fi
    fi
}


# Give some information & ask permission to continue (if not yet done so)
if [ ! -f $HOME/.KUL_apps_install_yes ]; then
    echo "      for details see https://github.com/treanus/KUL_Linux_Installation"
    echo "      it will take several hours to install (and compile, if needed) all software."
    echo "      You may have to exit the shell several times, after which you have to restart the script."
    echo "      The script will check what has already been installed and continue installing software"
    echo "      This script may ask you a several times for your password in order to install software (sudo usage)"
    read -r -p "Proceed with the installation? [Y/n] " prompt
    prompt=${prompt:-y}
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
        echo 'OK we continue'
        touch $HOME/.KUL_apps_install_yes
    else
        exit
    fi
fi


# Check if users have installed dependancies for WSL2
if [ $local_os -eq 2 ] && [ ! -f $HOME/.KUL_apps_install_wsl2_yes ]; then
    echo -e "\n"
    echo "You are running WSL"
    echo "  this script only works well on WSL2 in win11 (or latest preview win10)"
    echo "  be sure to INSTALL FIRST ON WIN11: "
    echo "      1/ enable nvidia cuda in WSL following https://docs.microsoft.com/en-us/windows/ai/directml/gpu-cuda-in-wsl "
    echo "      2/ install docker in win11 and setup wsl2 - ubuntu integration"
    echo "      otherwise, exit the script (answer "no" below) and do this first"
    read -r -p "Proceed with the installation? [Y/n] " prompt
    prompt=${prompt:-y}
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
if [ ! -f ${install_location}/.KUL_apps_make_installdir ]; then
    echo "Making the install directory, readable and executable for all users"
    echo "  you might have to give your password (if needed)"
    sleep 3
    # Determine group id
    kul_group=$(id -g)
    #echo $kul_group
    sudo mkdir -p ${install_location}
    sudo chgrp -R ${kul_group} ${install_location}
    sudo chmod -R 770 ${install_location}
    touch ${install_location}/.KUL_apps_make_installdir
fi


# Install requirements - TODO: check what is *really* needed!
if [ ! -f ${install_location}/.KUL_apps_install_required_yes ]; then
    
    # LINUX AND WSL2
    if [ $local_os -gt 1 ]; then
        echo -e "\n"
        echo "We first install a number of needed packages"
        echo 'The system will now ask for your password (if needed) to update and upgrade all linux system software'
        sleep 4
        sudo apt update
        sudo apt upgrade
        sudo apt -y install \
            git \
            htop \
            libgl1-mesa-glx \
            libegl1-mesa \
            libxrandr2 \
            libxss1 \
            libxcursor1 \
            libxcomposite1 \
            libasound2 \
            libxi6 \
            libxtst6 \
            g++ \
            zlib1g-dev \
            libeigen3-dev \
            libqt5opengl5-dev \
            libqt5svg5-dev \
            libgl1-mesa-dev \
            libfftw3-dev \
            libtiff5-dev \
            libpng-dev \
            tcsh \
            cmake \
            pkg-config \
            libncurses5-dev \
            libncursesw5-dev \
            libblas-dev \
            liblapack-dev \
            libopenblas0 \
            dc \
            python \
            mesa-utils \
            gedit \
            pulseaudio \
            libquadmath0 \
            libgtk2.0-0 \
            firefox \
            python2.7 

        if [ $local_os -eq 2 ];then
            sudo apt -y install nautilus
        fi
        touch ${install_location}/.KUL_apps_install_required_yes  


    # macOS
    elif [ $local_os -eq 1 ]; then

        # Install command line developer tools
        if xcode-select --install 2>&1 | grep installed; then
            echo "Already installed command line developer tools - ignore the warning/error"
        else
            echo -e "\n\n\n"
            echo "Installing command line developer tools"
            sleep 3
            xcode-select --install
        fi

        # Check for Homebrew, install if we don't have it
        if ! command -v brew &> /dev/null; then
            echo -e "\n\n\n"
            echo "Installing brew"
            sleep 3
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        # Update homebrew recipes
        brew update
        
        # install a number of brew packages
        echo -e "\n\n\n"
        echo "Installing packages..."
        echo "  you may see errors or warnings if packages are already installed"
        sleep 3
        brew install git
        brew install hub
        brew install jq
        brew install wget
        brew install eigen
        brew install qt
        brew install pkg-config
        brew install libtiff
        brew install fftw
        brew install mmv
        brew install cmake
        brew install netpbm
        brew install openblas
        brew install zlib
        brew install lapack
        brew install htop

        echo -e "\n\n\n"
        echo "Installing cask apps..."
        echo "  you may see errors or warnings if programs are already installed"
        sleep 3
        brew install --cask visual-studio-code
        brew install --cask xquartz
        brew install --cask cyberduck
        brew install --cask docker
        brew install --cask firefox
        brew install --cask menumeters
        brew install --cask osirix-quicklook
        brew install --cask quicklook-json
        brew install --cask quicklook-csv

        echo -e "\n\n\n"
        echo "KUL_Install_NeuroImagingSoftware:"
        echo "Now:"
        echo "  1/ manually setup docker (open app and set up)"
        echo "  2/ if you are behind a strict (hospital/university) firewall you may want to copy the line below:"
        echo "      git config --global url."https://".insteadOf git://"
        echo "      into another terminal and execute"
        echo "  3/ reboot and run the KNT_Linux_install.sh again from a new terminal"
        touch ${install_location}/.KUL_apps_install_required_yes  
        exit

    fi   
fi


# initiate the config file to be sourced by ${bashfile}
if [ ! -f ${KUL_apps_config} ]; then
    # the KUL_apps_config
    echo "export KUL_apps_DIR=${install_location}" > ${KUL_apps_config}
    # the KUL_apps_version
    cat <<EOT > $KUL_apps_versions
#!/bin/bash
EOT
    # update ${bashfile}
    echo "" >> ${bashfile}
    echo "# Source the KUL_apps and other neuroimaging software" >> ${bashfile}
    echo "source ${KUL_apps_config}"  >> ${bashfile}
    source ${bashfile}
    sleep 4
fi


# Installation of Anaconda --- BEGIN
if ! command -v conda &> /dev/null; then
    install_KUL_apps "Anaconda3"
    if [ $do_not_install -eq 0 ]; then 
        if [ $local_os -eq 1 ]; then
            anaconda_version=Anaconda3-2021.05-MacOSX-x86_64.pkg
            wget https://repo.anaconda.com/archive/${anaconda_version}
            sudo installer -pkg ${anaconda_version} -target ${install_location}
        else
            anaconda_version=Anaconda3-2021.05-Linux-x86_64.sh
            #sudo apt-get -y install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
            wget https://repo.anaconda.com/archive/${anaconda_version}
            echo -e "\n\n"
            echo "Here we give the installation instructions for anaconda..."
            echo "ACCEPT THE LICENSE"
            echo "CHANGE THE INSTALL DIRECTORY to /usr/local/KUL_apps/anaconda3"
            echo "Say no NO initialize Anaconda3"
            read -p "Press any key to continue... " -n1 -s
            bash ${anaconda_version}
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

        fi

        rm ${anaconda_version}
        echo "echo -e \"\t Anaconda3\t-\t${anaconda_version}" \" >> $KUL_apps_versions
        echo -e "\n\n\n"
        echo "Now exit all ${os_name} terminals and run the KNT_Linux_install.sh again from a new terminal"
        
        exit

    else
        echo "Ananconda is really essential - don't know what to do but exit"
        exit
    fi
else
    echo "Already installed Anaconda3"
fi
# Installation of Anaconda --- END


# Setup some useful stuff
if ! [ -f "${install_location}/.KUL_apps_useful_installed" ]
then
    echo "Setting up useful aliases "

    echo "# KUL_apps - Setting up some useful stuff" >> ${KUL_apps_config}
    echo "alias ll='ls -alhF'" >> ${KUL_apps_config}
    if [ $local_os -eq 1 ];then 
        echo "export BASH_SILENCE_DEPRECATION_WARNING=1" >> ${KUL_apps_config}
        echo "export PATH=\$HOME/.local/bin:\$PATH" >> ${KUL_apps_config}
    fi
    if [ $local_os -eq 2 ];then 
        echo "alias code='code &'" >> ${KUL_apps_config}
    fi
    touch ${install_location}/.KUL_apps_useful_installed
else
    echo "Already set up useful aliases"
fi


# install cuda toolkit
if [ $local_os -eq 2 ]; then
    echo "Already installed cuda in win11"
elif [ $local_os -eq 15 ]; then
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
elif [ $local_os -eq 1 ]; then
    echo "Not installing cuda on macOS (no nvidia cards available)"
fi


# Installation of Visual Studio Code
if [ ! command -v code &> /dev/null ] && [ $local_os -gt 1 ]; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt-get -y install apt-transport-https
    sudo apt-get -y update
    sudo apt-get -y install code
    rm packages.microsoft.gpg
else
    echo "Already installed Visual Studio Code"
fi


# Installation of HD-BET
if ! command -v hd-bet &> /dev/null
then
    install_KUL_apps "HD-BET"
    if [ $do_not_install -eq 0 ]; then 
        git clone https://github.com/MIC-DKFZ/HD-BET
        cd HD-BET
        if [ $local_os -eq 1 ]; then
            sudo pip install -e . # sudo needed for macOS, yes
        else
            pip install -e . # ??? sudo needed for macOS, check if needed for Linux/WSL2 next time
        fi
        cd
        echo "echo -e \"\t HD-BET\t\t-\t\$(cd $KUL_apps_DIR/HD-BET; git fetch; git fetch; git status | head -2 | tail -1)\"" >> $KUL_apps_versions
        if [ $local_os -eq 1 ]; then
            echo "" >> ${KUL_apps_config}
            echo "# Setting up HD-BET" >> ${KUL_apps_config}
            echo "alias hd-bet='hd-bet -device cpu -mode fast -tta 0 ' " >> ${KUL_apps_config}
        fi
    else
        echo "ok - you choose not to install HD-BET"
    fi
else
    echo "Already installed HD-BET"
fi


# Installation of MRtrix3
if ! command -v mrconvert &> /dev/null; then
    install_KUL_apps "MRtrix3"
    if [ $do_not_install -eq 0 ]; then 
        git clone https://github.com/MRtrix3/mrtrix3.git
        cd mrtrix3 
        if [ $local_os -eq 1 ];then
            ./configure -conda
        else
            ./configure
        fi
        ./build
        # begin cat command - see below
        cat <<EOT >> ${KUL_apps_config}
# adding MRTRIX3
export PATH=${install_location}/mrtrix3/bin:\$PATH

EOT
        # end cat command - see above
        ${install_location}/KUL_apps/mrtrix/install_mime_types.sh
    
        echo "echo -e \"\t mrtrix3\t-\t\$(mrconvert -version | head -1 | awk '{ print \$3 }') \"" >> $KUL_apps_versions
    else
        echo "ok - you choose not to install MRtrix3"
    fi
else
    echo "Already installed MRtrix3"
fi


# Installation of KNT
if ! [ -d "${install_location}/KUL_NeuroImaging_Tools" ]; then
    install_KUL_apps "KUL_NeuroImaging_Tools"
    if [ $do_not_install -eq 0 ]; then
        git clone https://github.com/treanus/KUL_NeuroImaging_Tools.git
        #cd KUL_NeuroImaging_Tools
        #git checkout development
        #cd ..
        if [ $local_os -gt 1 ]; then
            #sudo apt-get install libopenblas0
            cp KUL_NeuroImaging_Tools/share/eddy_cuda11.2_linux.tar.gz .
            tar -xzvf eddy_cuda11.2_linux.tar.gz
            rm eddy_cuda11.2_linux.tar.gz
            sudo ln -s ${install_location}/eddy_cuda/eddy_cuda11.2 /usr/local/fsl/bin/eddy_cuda
        fi
        cat <<EOT >> ${KUL_apps_config}
# adding KUL_NeuroImaging_Tools
export PATH=${install_location}/KUL_NeuroImaging_Tools:\$PATH
export PYTHONPATH=${install_location}/mrtrix3/lib:\$PYTHONPATH

EOT
        echo "echo -e \"\t KUL_NIT\t-\t\$(cd $KUL_apps_DIR/KUL_NeuroImaging_Tools; git fetch; git status | head -2 | tail -1)\"" >> $KUL_apps_versions
    else
        echo "ok - you choose not to install KUL_NeuroImaging_Tools"
    fi
else
    echo "Already installed KUL_NeuroImaging_Tools"
fi


# Installation of Docker
if ! command -v docker &> /dev/null; then
    if [ $local_os -gt 1 ]; then
        install_KUL_apps "Docker"
        if [ $do_not_install -eq 0 ]; then 
            sudo apt-get -y update
            sudo apt-get -y remove docker docker-engine docker.io
            sudo apt-get -y install docker.io
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo groupadd docker
            sudo usermod -aG docker $USER
            newgrp docker
        else
            echo "ok - you choose not to install Docker - it is essential though in most cases..."
        fi
    fi
else
    echo "Already installed Docker"
fi


# Installation of dcm2niix
if ! command -v dcm2niix &> /dev/null; then
    install_KUL_apps "dcm2niix"
    if [ $do_not_install -eq 0 ]; then
        git clone https://github.com/rordenlab/dcm2niix.git
        cd dcm2niix
        mkdir build && cd build
        cmake -DZLIB_IMPLEMENTATION=Cloudflare -DUSE_JPEGLS=ON -DUSE_OPENJPEG=ON ..
        make
        cat <<EOT >> ${KUL_apps_config}
# adding dcm2nixx
export PATH=${install_location}/dcm2niix/build/bin:\$PATH

EOT
        echo "echo -e \"\t dcm2nixx\t-\t\$(dcm2niix --version | head -1 | awk '{ print \$5 }') \"" >> $KUL_apps_versions 
    else
        echo "ok - you choose not to install dcm2niix"
    fi
else
    echo "Already installed dcm2niix"
fi


# Installation of dcm2bids
if ! command -v dcm2bids &> /dev/null; then
    install_KUL_apps "dcm2bids"
    if [ $do_not_install -eq 0 ]; then
        pip install dcm2bids
        echo "echo -e \"\t dcm2bids\t-\t\$(dcm2bids -h | grep dcm2bids | tail -1 | awk '{ print \$2 }') \"" >> $KUL_apps_versions 
    else
        echo "ok - you choose not to install dcm2bids"
    fi
else
    echo "Already installed dcm2bids"
fi


# lets's make install current
source ${bashfile}

# download a number of Docker containers
if [ ! -f ${install_location}/.KUL_apps_install_containers_yes ]; then
    echo "Now installing some useful docker containers"
    sleep 3
    if [ $local_os -eq 1 ]; then
        echo -e "\n\n\n"
        echo "Here we give the installation instructions for docker containers on macOS..."
        echo "See to it that Docker Desktop is setup and running"
        read -p "Press any key to continue... " -n1 -s
        echo "Not installing hd-glio-auto on macOS (no compatible GPU)"
        echo "echo -e \"\t hd-glio-auto\t-\tcannot be installed (no compatible GPU) \"" >> $KUL_apps_versions
    else
        docker pull jenspetersen/hd-glio-auto
        echo "echo -e \"\t hd-glio-auto\t-\tcannot be checked (but latest docker) \"" >> $KUL_apps_versions
    fi
    echo "Installing synb0"
    docker pull hansencb/synb0
    echo "echo -e \"\t synb0\t\t-\tcannot be checked (but latest docker) \"" >> $KUL_apps_versions
    touch ${install_location}/.KUL_apps_install_containers_yes
else
    echo "Already installed required docker containers"
fi


# Installation of FSL
if ! command -v fslmaths &> /dev/null; then
    install_KUL_apps "FSL"
    if [ $do_not_install -eq 0 ]; then 
        #if [ $local_os -eq 2 ]; then
        #    sudo apt-get -y install dc python mesa-utils gedit pulseaudio libquadmath0 libgtk2.0-0 firefox
        #fi
        wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py
        #if [ $local_os -gt 1 ]; then
        #    sudo apt-get -y install python2.7
        #fi
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
        echo "echo -e \"\t FSL\t\t-\t\$(cat \$FSLDIR/etc/fslversion)\"" >> $KUL_apps_versions
    else
        echo "ok - you choose not to install FSL"
    fi
else
    echo "Already installed FSL"
fi


# Installation of Freesurfer
if ! command -v freeview &> /dev/null; then
    echo "KUL_apps: which version do you want to install"
    echo "  1 - v6.0.0 (recommended)"
    echo "  2 - v7.2.0"
    read -r -p "Freesurfer version: [1/2] " fs_prompt
    if [[ $fs_prompt == "2" ]]; then
       freesurfer_version="7.2.0"
       if [ $local_os -eq 1 ]; then
            freesurfer_file="freesurfer-darwin-macOS-7.2.0"
        else
            freesurfer_file="freesurfer-linux-ubuntu18_amd64-7.2.0"
        fi
    else
        freesurfer_version="6.0.0"
        if [ $local_os -eq 1 ]; then
            freesurfer_file="freesurfer-Darwin-OSX-stable-pub-v6.0.0"
        else
            freesurfer_file="freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.0"
        fi
    fi
    install_KUL_apps "Freesurfer v ${freesurfer_version}"
    if [ $do_not_install -eq 0 ]; then 
        wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${freesurfer_version}/${freesurfer_file}.tar.gz
        tar -zxvpf ${freesurfer_file}.tar.gz
        cat <<EOT >> ${KUL_apps_config}
# adding freesurfer
export FREESURFER_HOME=${install_location}/freesurfer
export SUBJECTS_DIR=\$FREESURFER_HOME/subjects
export FS_LICENSE=${install_location}/freesurfer_license/license.txt
source \$FREESURFER_HOME/SetUpFreeSurfer.sh

EOT

        echo "echo -e \"\t freesurfer\t-\t\$(recon-all -version) \"" >> $KUL_apps_versions
        mkdir -p ${install_location}/freesurfer_license
        echo "Install the license.txt into ${install_location}/reesurfer_license"
        rm ${freesurfer_file}.tar.gz
    else
        echo "ok - you choose not to install Freesurfer"
    fi    
else
    echo "Already installed Freesurfer ${freesurfer_version}"
    echo "  however do not forget to install the license.txt into ${install_location}/freesurfer_license"
fi


# Installation of Ants
if ! [ -d "${install_location}/ANTs_installed" ]; then
    install_KUL_apps "Ants"
    if [ $do_not_install -eq 0 ]; then
        wget https://raw.githubusercontent.com/cookpa/antsInstallExample/master/installANTs.sh
        chmod +x installANTs.sh
        #if [ $local_os -gt 1 ]; then
        #    sudo apt-get -y install cmake pkg-config
        #fi
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
        echo "echo -e \"\t ants\t\t-\t\$(antsRegistration --version | head -1 | awk '{ print \$3 }') \"" >> $KUL_apps_versions
    else
        echo "ok - you choose not to install Ants"
    fi
else
    echo "Already installed ANTs"
fi


# Installation of DCMTK
if ! command -v storescu &> /dev/null; then
    install_KUL_apps "DCMTK"
    if [ $do_not_install -eq 0 ]; then
        if [ $local_os -eq 1 ]; then
            brew install dcmtk
        else
            sudo apt-get -y install dcmtk
        fi
    else
        echo "ok - you choose not to install DCMTK"
    fi
else
    echo "Already installed DCMTK"
fi


# Installation of GDCM (other dicom tools)
if ! command -v gdcmtar &> /dev/null; then
    install_KUL_apps "GDCM"
    if [ $do_not_install -eq 0 ]; then
        if [ $local_os -eq 1 ]; then
            brew install gdcm
        else
            sudo apt-get -y install libgdcm-tools
        fi
    else
        echo "ok - you choose not to install GDCM"
    fi
else
    echo "Already installed GDCM"
fi


# Setup of Matlab
#if ! command -v matlab &> /dev/null
#then
#    echo "" >> $HOME/${bashfile}
#    echo "# adding matlab" >> $HOME/${bashfile}
#    echo "export PATH=/usr/local/MATLAB/R2018a/bin:\$PATH" >> $HOME/${bashfile}
#    echo "alias matlab='xrandr --dpi 144; matlab &'" >> $HOME/${bashfile}
#fi


# Installation of SPM12
if ! [ -d "${install_location}/spm12" ]; then
    install_KUL_apps "spm12"
    if [ $do_not_install -eq 0 ]; then
        wget https://www.fil.ion.ucl.ac.uk/spm/download/restricted/eldorado/spm12.zip
        unzip spm12.zip
        #Note: Matlab needs to be installed first to compile the mex files
        read -r -p "Do you want to recompile to SPM binaries (if so, you need yo have matlab installed and set up) [y/n] " prompt
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
        echo "echo -e \"\t spm12\t\t-\tcheck from within matlab please \"" >> $KUL_apps_versions
    else
        echo "ok - you choose not to install spm12. Do not install cat12, lead-dbs and conn since it depends on it"
    fi
else
    echo "Already installed spm12"
fi


# Installation of cat12
if ! [ -d "${install_location}/spm12/toolbox/cat12" ]; then
    install_KUL_apps "cat12"
    if [ $do_not_install -eq 0 ]; then
        wget http://www.neuro.uni-jena.de/cat12/cat12_latest.zip
        unzip cat12_latest.zip -d spm12/toolbox
        rm cat12_latest.zip
        echo "echo -e \"\t cat12\t\t-\tcheck from within matlab please \"" >> $KUL_apps_versions
    else
        echo "ok - you choose not to install cat12"
    fi
else
    echo "Already installed cat12"
fi


# Installation of Lead-DBS
if ! [ -d "${install_location}/leaddbs" ]; then
    install_KUL_apps "Lead-DBS"
    if [ $do_not_install -eq 0 ]; then
        git clone https://github.com/netstim/leaddbs.git
        wget -O leaddbs_data.zip http://www.lead-dbs.org/release/download.php?id=data_pcloud
        echo -e "\n\n\n"
        echo "Here we give the installation instructions for Lead-dbs..."
        echo "answer yes when asked to replace templates"
        read -p "Press any key to continue... " -n1 -s
        unzip leaddbs_data.zip -d leaddbs/
        rm leaddbs_data.zip
        echo "echo -e \"\t Lead-DBS\t-\tcheck from within matlab please \"" >> $KUL_apps_versions
    else
        echo "ok - you choose not to install Lead-DBS"
    fi
else
    echo "Already installed Lead-DBS"
fi


# Installation of CONN
conn_version="con20b"
if ! [ -d "${install_location}/${conn_version}" ]; then
    install_KUL_apps "conn-toolbox version ${conn_version}"
    if [ $do_not_install -eq 0 ]; then
        wget https://www.nitrc.org/frs/download.php/11714/${conn_version}.zip
        unzip ${conn_version}.zip
        mv conn ${conn_version}
        rm ${conn_version}.zip
        echo "echo -e \"\t conn\t\t-\t${conn_version} \"" >> $KUL_apps_versions
    else
        echo "ok - you choose not to install ${conn_version}"
    fi
else
    echo "Already installed conn-toolbox version ${conn_version}"
fi


# Installation of VBG
if ! [ -d "${install_location}/KUL_VBG" ]; then
    install_KUL_apps "KUL_VBG"
    if [ $do_not_install -eq 0 ]; then
        git clone https://github.com/treanus/KUL_VBG.git
        cat <<EOT >> ${KUL_apps_config}
# adding KUL_VBG
export PATH=${install_location}/KUL_VBG:\$PATH

EOT
        echo "echo -e \"\t KUL_VBG\t-\t\$(cd $KUL_apps_DIR/KUL_VBG; git fetch; git status | head -2 | tail -1)\"" >> $KUL_apps_versions
    else
        echo "ok - you choose not to install KUL_VBG"
    fi
else
    echo "Already installed KUL_VBG"
fi


# Installation of FWT
if ! [ -d "${install_location}/KUL_FWT" ] 
then
    install_KUL_apps "KUL_FWT"
    if [ $do_not_install -eq 0 ]; then
        git clone https://github.com/treanus/KUL_FWT.git
        cd KUL_FWT
        git checkout dev_cshdp
        cd ..
        cat <<EOT >> ${KUL_apps_config}
# adding KUL_VBG
export PATH="${install_location}/KUL_FWT:\$PATH"

EOT
        echo "echo -e \"\t KUL_FWT\t-\t\$(cd $KUL_apps_DIR/KUL_FWT; git fetch; git status | head -2 | tail -1)\"" >> $KUL_apps_versions
    else
        echo "ok - you choose not to install KUL_FWT"
    fi
else
    echo "Already installed KUL_FWT"
fi


# Installation of Scilpy
if ! command -v scil_filter_tractogram.py &> /dev/null; then
    install_KUL_apps "Scilpy"
    if [ $do_not_install -eq 0 ]; then
        #if [ $local_os -gt 1 ]; then
        #    sudo apt-get -y install libblas-dev liblapack-dev
        #fi
        git clone https://github.com/scilus/scilpy.git
        cd scilpy
        pip install -e .
        echo "echo -e \"\t scilpy\t\t-\t\$(cd $KUL_apps_DIR/scilpy; git fetch; git status | head -2 | tail -1)\"" >> $KUL_apps_versions
    else
        echo "ok - you choose not to install Scilpy"
    fi
else
    echo "Already installed Scilpy"
fi


# Installation of FastSurfer
if ! [ -d "${install_location}/FastSurfer/" ] && [ $local_os -gt 1 ]; then
    install_KUL_apps "FastSurfer"
    if [ $do_not_install -eq 0 ]; then
        git clone https://github.com/Deep-MI/FastSurfer.git
        cat <<EOT >> ${KUL_apps_config}
# adding FastSurfer
export FASTSURFER_HOME="${install_location}/FastSurfer"

EOT
        source ${install_location}/KUL_apps_config
        # install Pytorch
        conda install -y  pytorch torchvision torchaudio cudatoolkit=11.2 -c pytorch
        echo "echo -e \"\t FastSurfer\t-\t\$(cd $KUL_apps_DIR/FastSurfer; git fetch; git status | head -2 | tail -1)\"" >> $KUL_apps_versions
    else
        echo "ok - you choose not to install FastSurfer"
    fi
elif [ $local_os -eq 1 ]; then
    echo "On macOS we will use the docker version of Fastsurfer"
else
    echo "Already installed FastSurfer"
fi

# Installation of Karawun
if ! [ -f "${install_location}/.KUL_apps_installed_karawun" ]; then
    install_KUL_apps "Karawun"
    if [ $do_not_install -eq 0 ]; then
        sudo chown -R "$(id -u):$(id -g)" $HOME/.conda
        conda config --append channels conda-forge --append channels anaconda --append channels SimpleITK
        conda install -y  git
        conda create --name KarawunEnv --file https://github.com/DevelopmentalImagingMCRI/karawun/raw/master/requirements.txt
        conda activate KarawunEnv
        pip install git+https://github.com/DevelopmentalImagingMCRI/karawun.git@master
        conda deactivate
        touch ${install_location}/.KUL_apps_installed_karawun
    else
        echo "ok - you choose not to install Karawun"
    fi
else
    echo "Already installed Karawun"
fi


# Installation of Mevislab 3.4
if ! [ -f "${install_location}/.KUL_apps_installed_mevislab" ]; then
    install_KUL_apps "Mevislab 3.4"
    if [ $do_not_install -eq 0 ]; then
        if [ $local_os -eq 1 ]; then
            ml_file="https://mevislabdownloads.mevis.de/Download/MeVisLab3.4.2/Mac/X86-64/MeVisLabSDK3.4.2_x86-64.dmg"
            wget $ml_file
            hdiutil mount $ml_file
            sudo cp -R /Volumes/MeVisLabSDK/MeVisLab.app /Applications
            hdiutil unmount /Volumes/MeVisLabSDK
            rm $ml_file
        else
            wget https://mevislabdownloads.mevis.de/Download/MeVisLab3.4.3/Linux/GCC7-64/MeVisLabSDK3.4.3_gcc7-64.bin
            chmod u+x MeVisLabSDK3.4.3_gcc7-64.bin
            #mkdir MeVisLabSDK3.4 
            ./MeVisLabSDK3.4.3_gcc7-64.bin --prefix ${install_location}/MevislabSDK3.4 --mode silent
            rm MeVisLabSDK3.4.3_gcc7-64.bin
        fi
        touch ${install_location}/.KUL_apps_installed_mevislab
    else
        echo "ok - you choose not to install Mevislab 3.4"
    fi
else
    echo "Already installed MevislabSDK3.4"
fi


# Installation of Robex
if ! [ -d "${install_location}/ROBEX/" ] && [ $local_os -gt 1 ]; then
    install_KUL_apps "ROBEX"
    if [ $do_not_install -eq 0 ]; then
        wget -qO- "https://www.nitrc.org/frs/download.php/5994/ROBEXv12.linux64.tar.gz//?i_agree=1&download_now=1" | \
            tar zx -C ${install_location}
        cat <<EOT >> ${KUL_apps_config}
# adding ROBEX
export PATH="${install_location}/ROBEX:\$PATH"

EOT
    else
        echo "ok - you choose not to install Robex"
    fi
elif [ $local_os -eq 1 ]; then
    echo "Not installing Robex on macOS"
else
    echo "Already installed ROBEX"
fi


# Installation of Spinal Cord Toolbox
program="spinalcordtoolbox"
if ! [ -d "${install_location}/${program}" ]; then
    install_KUL_apps ${program}
    if [ $do_not_install -eq 0 ]; then
        git clone https://github.com/spinalcordtoolbox/spinalcordtoolbox
        cd spinalcordtoolbox
        ./install_sct
    else
        echo "ok - you choose not to install ${program}"
    fi
else
    echo "Already installed ${program}"
fi


# Installation of nvtop
if [ ! command -v nvtop &> /dev/null ] && [ $local_os -gt 1 ]; then
    install_KUL_apps "nvtop"
    if [ $do_not_install -eq 0 ]; then
        #sudo apt install cmake libncurses5-dev libncursesw5-dev
        git clone https://github.com/Syllo/nvtop.git
        mkdir -p nvtop/build && cd nvtop/build
        cmake ..
        make
        sudo make install
        cd ../..
        rm -fr nvtop
    else
        echo "ok - you choose not to install nvtop"
    fi
elif [ $local_os -eq 1 ]; then
    echo "Not installing nvtop on macOS"
else
    echo "Already installed nvtop"
fi


# complete the config file to be sourced by ${bashfile}
KULcheck=${install_location}/.KUL_apps_installed_prompts
if [ ! -f ${KULcheck} ]; then
    # the KUL_apps_config
    echo "# Welcome to KUL_Apps" >> ${KUL_apps_config}
    echo "echo \"Welcome to KUL_Apps\" " >> ${KUL_apps_config}
    echo "echo \"  installation DIR is  ${install_location}\" " >> ${KUL_apps_config}
    echo "echo \"  the config file is   ${KUL_apps_config}\" " >> ${KUL_apps_config}
    echo "echo \"  installed software/version is: \"" >> ${KUL_apps_config}
    echo "source $KUL_apps_versions" >> ${KUL_apps_config}
    echo "echo \" \" " >> ${KUL_apps_config}
    touch $KULcheck
fi

echo -e "\n\n\n"
echo "All done. Please reboot."
echo "Install the Freesurfer license.txt into ${install_location}/freesurfer_license/"
