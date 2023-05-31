#!/bin/bash

############################################################################
# Script name : first_setup.sh               Date   : 10/02/22             #
# Author      : Stan SKY                     E-mail : sky012877@gmail.com  #
# Description : Add env vars and my rc part to bashrc and to others ..rs fi#
############################################################################
chmod_list=""

echo Adding additional environment variables an rc aliases

link=". $PWD/rc"
rc_files=".bashrc .testrc .zhsrc .zshrc"

echo Copying $rc_files to Config directory..


echo Adding link string $link to .rc files ...
for file in $rc_files
    do
		file=$HOME/$file
		echo Checking $file ...
		if [[ ! -f $file ]]; then
			echo File $file not found
			echo Creating Empty  $file
			touch $file
		fi

		echo Trying to add rc link to $file ...
        grep -q "$link"	$file && echo "The $file already has: $link" || echo $link >> $file
		echo Checking inside the file...
		tail -n 5 $file
		echo "==============="

	done

