# Here's how to install a linux machine with all software for neuroimaging.

We start by an example where you or your promoter get you a laptop or pc. 
If the laptop or PC are bought new, take one with FreeDos instead of buying (the license of) Windows 7/8/10, this will safe you a couple of hundred euro's on the Windows license.

In this example we start with a HP laptop Zbook 17 G6 (17 inch screen, 6th generation).
Specs can be found here: https://support.hp.com/id-en/document/c06409806
We have an RTX3000 GPU, 1T HD and 1T SSD, iCore 9 CPU, 32 GB mem
According to https://www.phoronix.com/scan.php?page=article&item=hp-zbook17-g6&num=2 it specs are really good in Q2-2002.
We will use Linux Mint 20 as the operating system (OS).
We start by installing Mint 20. See https://www.linuxmint.com/.
You need a USB stick.
Follow the guide in linux mint how to make a bootable install usb stick.

Note that sometimes some bios settings of your laptop/pc need to be updated.
In the case of a HP Zbook we need to press F10 at startup to go into the bios.
We set in the advanced bios tab: Secure boot: Legacy Support and Secure boot disabled,
Then also in the advanced bios tap we had to turn off the microphone device (no driver exists yet).

In this case we used an install from a USB stick (see above). 
Then we pressed F9 at startup of the PC/Laptop and choose the USB stick to install Linux Mint.
During the install, we connected to the wifi network  to get all updates.
Re-partitioning the hard-drive maybe tricky; if in doubt ask Stefan.
The example HP Zbook has 2 hard drives, 1 standard and 1 super fast nvme SSD. We install Linux Mint on the standard drive and will put all neuro-imaging data (MR images) in the super fast SSD.
Also make your account, and set not to login automatically.
Once installed, it will ask to reboot, and then to remove the usb.

Login to your freshly installed Linux Mint.
"Welcome to Linux Mint" will pop up.
In "First Steps" you may configure a dark theme (Desktop Colours), select the "Modern Panel Layout". 
Also here in "First Steps" perform "Update Manager".
Restart.

After login, in "First Steps" run the "Driver Manager". In case of the Zbook with an NVidia RTX3000, we install the latest nvidia drivers.
Restart.

At new login or later you may want to use "System Snapshots" and install additional language packs.


## Installing NeuroImaging software

Now, we install all major neuro-imaging software tools.

It will install:
- Anaconda3 (version 2020-07, python for science)
- htop (latest version, process monitor)
- numlockx (latest version, allows to have NumLock on at startup)
- Video Studio Code (latest version, your editor for programming)
- nvidia cuda (latest version, GPU cuda drivers)
- mrtrix3 (latest version)
- FSL (latest version)
- Docker (latest version, docker containers for fmriprep, etc...)
- Freesurfer (version 7.1.1)
- ANTs (latest version)
- dcm2niix (latest version, converts dicom to niftii)
- dcm2bids (latest Jooh version, converts to BIDS)
- SPM12 (latest version, compiles the binaries)
- cat12 (latest version)
- conn toolbox (version 19c)
- KUL_NeuroImaging_tools (latest version)

We use a "script" specifically designed for UZ/KULeuven.
We download this script from github and execute it.

Open a terminal.
Copy the following commands into terminal. (Note that - in order to copy the exact command - you could already open our website on the Linux Mint machine; open firefox, login to our page).

<code> wget https://raw.githubusercontent.com/treanus/KUL_Linux_Installation/master/KNT_Linux_Install.sh </code>
<code> chmod +x KNT_Linux_Install.sh </code>

Now run the script

./KNT_Linux_Install.sh

In a first step this will install Anaconda3.
Follow the installation instruction, and accept the license and initialization.
Reboot when asked.

Rerun the script.

./KNT_Linux_Install.sh

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




Notes
For the example HP laptop Zbook 17 G6, the "startup ACPI error" at boot time is nothing to worry about. Same for the "disk unmount error" at shutdown/reboot.
