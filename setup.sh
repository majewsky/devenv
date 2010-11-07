#!/bin/bash

if [ ! -d .git -o ! -f mappings.txt ]; then
	echo "Execute this script from the toplevel directory of the devenv repo."
	exit 1
fi

case $1 in
	install)
		INSTALLATION_GOOD=1
		while read SOURCE DEST; do
			if [ -e $HOME/$DEST ]; then
				INSTALLATION_GOOD=0
				echo "Conflict with existing file $HOME/$DEST" >&2
			fi
		done < mappings.txt
		if [ $INSTALLATION_GOOD != 1 ]; then
			exit 1
		fi
		while read SOURCE DEST; do
			ln -s $PWD/$SOURCE $HOME/$DEST
		done < mappings.txt
		;;
	*)
		echo "Unknown mode of operation: $1"
		echo "Syntax: ./setup.sh install"
esac

