#!/bin/bash

############################################################################
# Script name :                              Date   :                      #
# Author      : Stan SKY                     E-mail : sky012877@gmail.com  #
# Description :                                                            #
############################################################################

echo Editing global i3 config ...
sudo sed -i "s/exec i3-config-wizard//g" /etc/i3/config

echo Creating symbolic link for user i3 config
path=$HOME/.i3
mkdir -vp $path

[ -f $path/config ] && mv $path/config $path/config.old

ln -sf $PWD/i3.config $path/config
readlink $path/config


#cp  -vf i3.config $path/config
ls -la $path

echo Creating symbolic link for i3 .profile config ...

ln -sfv $PWD/i3.profile $HOME/.profile
#ls -la $HOME
readlink $HOME/.profile

echo Done!


