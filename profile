#!/bin/bash

export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_STYLE_OVERRIDE="kvantum"
#export GTK_THEME="Dracula"
#export GTK_THEME_NAME="Dracula"
#export GTK_THEME_NAME=Materia-dark
export GTK_THEME=Materia-dark

#set editor
if command -v nvim >/dev/null 2>&1; then
    export EDITOR=/usr/bin/nvim
else
    export EDITOR=/usr/bin/nano
fi

export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
# fix "xdg-open fork-bomb" export your preferred browser from here


export BROWSER=/usr/bin/google-chrome-stable

#$PATH add new paths to environment
#export PATH=$PATH:/usr/bin/google-chrome-stable
#export JB_MAX_INSTANCE_COUNT=2 usr/bin/pycharm


. "$HOME/.cargo/env"
