# Here's how to install a linux machine with all software for neuroimaging.

This script installs a large number of NeuroImaging related software on Linux (Ubuntu 20.04 preferably), Windows-WSL2 (latest Win11 preferably) or macOS


## Installing NeuroImaging software

Now, we install all major neuro-imaging software tools.

It will install:
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
- SPM12 
- cat12 
- lead-DBS
- conn toolbox 
- KUL_NeuroImaging_tools 
- KUL_VBG
- KUL_FWT

## Installation notes

Open a terminal.
Copy the following commands into terminal. 

<code> wget https://raw.githubusercontent.com/treanus/KUL_Linux_Installation/master/KNT_Linux_Install.sh </code>

<code> chmod +x KUL_Install_NeuroImagingSoftware.sh </code>

Now run the script

<code> ./KUL_Install_NeuroImagingSoftware.sh </code>

In a first step this will install Anaconda3.
Follow the installation instruction, and accept the license and initialization.
Reboot when asked.

Rerun the script.

./KUL_Install_NeuroImagingSoftware.sh

Depending on the cpu and the internet connection speed this will take a few hours.
On some occasions you will be asked to enter your password and/or to confirm the installation.
FSL installer needs your interaction. Accept the default location (/usr/local/fsl).



After this continue:

Matlab
Ask Stefan for the installation media (2 iso files).
 If the USB stick with Matlab R2018a is called UNTITLED:

sudo mkdir /media/mathworks
sudo mount -t iso9660 -o loop /media/sarah/UNTITLED/MathWorks\ MATLAB\ R2018a\ Linux/R2018a_glnxa64_dvd1.iso /media/mathworks/
sudo /media/mathworks/install &
When asked for the second DVD:
sudo umount /media/mathworks
sudo mount -t iso9660 -o loop /media/sarah/UNTITLED/MathWorks\ MATLAB\ R2018a\ Linux/R2018a_glnxa64_dvd2.iso /media/mathworks/

Modify your .bashrc with
\# Setup Matlab
alias matlab='xrandr --dpi 144; /usr/local/MATLAB/R2018a/bin/matlab &'

If the matlab fonts are small on a highres monitor: see https://nl.mathworks.com/matlabcentral/answers/406956-does-matlab-support-high-dpi-screens-on-linux#answer_325831. Possibly you need to add xrandr --dpi 144 to your .bashrc (as done in the example above)


Other things to do to complete the full setup.

The freesurfer license file needs to be installed. This goes into $HOME/KUL_apps/freesurfer. Then set the 'export FS_LICENSE=/$HOME/KUL_apps/freesurfer/license.txt' in your .bashrc.
Start matlab, add spm12 and conn to the path. The path for spm12 and conn is $HOME/KUL_apps/spm and conn.

Extra Optional but Useful Stuff

Numlock on at startup
Go to Administration -> Login Window -> Settings, set activate numlock on

Chrome
Go to https://www.google.com/chrome/

Also possible via Mint Software Manager:
- remmina: client for remote desktop and vnc (to connect to a windows pc or mac)
- gimp (photoshop alike)
- stellarium (nice to look at the night sky for stars)

Activate some useful Applets:
Go to Preferences -> Applets
Scale lets you view windows easily
Download Multi-Core System Monitor and activate to see cpu/mem/etc...

Places (aka the Finder or Explorer)
Set in the Edit -> Preferences -> Default View -> View new folders using "List View" for a nice Mac OsX Finder behavior.




----

Notes for WSL2 using Win11


1/ Install win11, perform all updates

2/ Install nvidia-cuda: follow https://docs.microsoft.com/en-us/windows/ai/directml/gpu-cuda-in-wsl

3/ Open powershell as administrator and exe: wsl --install & reboot

4/ after reboot you will be asked to setup the user/passwd

5/ INSIDE WIN11: install 
- visual studio code
- docker desktop & setup the ubuntu as wsl integration

6/ open Ubuntu in wsl2 and perform sudo apt upadte and sudo apt upgrade

7/ KNT_Linux_Installation



