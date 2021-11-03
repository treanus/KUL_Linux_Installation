# Here's how to install Neuroimaging Software on Linux, WSL2 and macOS.

This script installs a large number of NeuroImaging related software on Linux (Ubuntu 20.04 preferably), Windows-WSL2 (latest Win11 preferably) or macOS


## Which NeuroImaging software

The script installs the latest stable versions of:
- Anaconda3 
- Video Studio Code 
- nvidia cuda 
- mrtrix3 
- FSL 
- Docker 
- Freesurfer 
- ANTs 
- dcm2niix 
- dcm2bids 
- DCMTK
- GDCM
- SPM12 
- cat12 
- lead-DBS
- conn toolbox 
- KUL_NeuroImaging_tools 
- KUL_VBG
- KUL_FWT
- Scilpy
- FastSurfer
- Mevislab
- Robex

## Prerequisites
### All
- Matlab (R2017b or later)

### Linux
Should run out of the box.
You may want to update your linux system:

<code> 
sudo apt update

sudo apt upgrade 
</code>

### Windows with WSL2
- Install win11, perform all updates
- Install nvidia-cuda: follow https://docs.microsoft.com/en-us/windows/ai/directml/gpu-cuda-in-wsl
- Open powershell as administrator and exe: wsl --install & reboot
- after reboot you will be asked to setup the user/passwd
- INSIDE WIN11: install 
    - visual studio code
    - docker desktop & setup the ubuntu as wsl integration
- open Ubuntu in wsl2 and perform sudo apt upadte and sudo apt upgrade

### macOS
- Install Docker Desktop and set it up
- Install Visual Studio Code
- Install XQuartz


## Installation notes

Open a terminal.
Copy the following commands into terminal. 

<code> 
wget https://raw.githubusercontent.com/treanus/KUL_Linux_Installation/master/KUL_Install_NeuroImagingSoftware.sh

chmod +x KUL_Install_NeuroImagingSoftware.sh 
</code>

Now run the script

<code> ./KUL_Install_NeuroImagingSoftware.sh </code>

In a first step this will install Anaconda3.
Follow the installation instruction, and accept the license and initialization.
Reboot when asked.

Rerun the script.

<code> ./KUL_Install_NeuroImagingSoftware.sh </code>

Depending on the cpu and the internet connection speed this will take a few hourOn some occasions you will be asked to enter your password and/or to confirm the installation.


## Post-Install

- The freesurfer license file needs to be installed. Put it in $KUL_apps_DIR/freesurfer_license
- Start matlab, add spm12 and conn to the path. The path for spm12 and conn is $HOME/KUL_apps/spm and conn.
- On macOS open Docker Desktop; in Resources/FileSharing add the folder with the freesurfer license.
