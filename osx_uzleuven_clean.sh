#!/usr/bin/env bash
# 
# Clean on OsX machine

# remove bash_profile
cd
mv .bash_profile bash_profile_magweg

# remove anaconda
rm $HOME/opt/anaconda3

# remove brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

