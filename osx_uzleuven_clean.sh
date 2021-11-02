#!/usr/bin/env bash
# 
# Clean on OsX machine

# remove bash_profile
cd
mv $HOME/.bash_profile $HOME/bash_profile_backup

# remove anaconda
rm -rf $HOME/opt/anaconda3
rm -rf $HOME/anaconda3

# remove brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

