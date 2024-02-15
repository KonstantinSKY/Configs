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

ln -sfv $PWD/i3.config $path/config
readlink $path/config


#cp  -vf i3.config $path/config
ls -la $path

echo Creating symbolic link for i3 .profile config ...

ln -sfv $PWD/i3.profile $HOME/.profile
#ls -la $HOME
readlink $HOME/.profile


#cp  -vf i3.config $path/config
ls -la $path

echo Creating symbolic link for i3 mimeapps.list  profile config ...

ln -sfv $PWD/mimeapps.list $HOME/.config/mimeapps.list
#ls -la $HOME
readlink $HOME/.config/mimeapps.list

echo Creating symbolic link for .ideavimrc config ...

ln -sfv $PWD/ideavimrc $HOME/.ideavimrc
#ls -la $HOME
readlink $HOME/.config/mimeapps.list



echo Done!


