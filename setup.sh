#!/bin/bash

if [ ! -d .git -o ! -f mappings.txt ]; then
	echo "Execute this script from the toplevel directory of the devenv repo."
	exit 1
fi

install_core()
{
		INSTALLATION_GOOD=1
		while read SOURCE DEST; do
			if [ -e $HOME/$DEST -a ! -L $HOME/$DEST ]; then
				INSTALLATION_GOOD=0
				echo "Conflict with existing file $HOME/$DEST" >&2
			fi
		done < mappings.txt
		if [ $INSTALLATION_GOOD != 1 ]; then
			exit 1
		fi
		while read SOURCE DEST; do
			if [ ! -L $HOME/$DEST ]; then
				ln -s $PWD/$SOURCE $HOME/$DEST
			fi
		done < mappings.txt
}

install_gui()
{
	# compile kfullscreenrunner
	ORIGPWD=$PWD
	mkdir -p $ORIGPWD/build/kfullscreenrunner
	cd $ORIGPWD/build/kfullscreenrunner
	cmake -DCMAKE_INSTALL_PREFIX=$HOME $ORIGPWD/bin/kfullscreenrunner
	make -j2
	make install/fast
}

case $1 in
	install-core)
		install_core
		;;
	install-gui)
		install_core
		install_gui
		;;
	install-gui-only)
		install_gui
		;;
	dryrun-install)
		while read SOURCE DEST; do
			if [ ! -L $HOME/$DEST ]; then
				echo ln -s $PWD/$SOURCE $HOME/$DEST
			fi
		done < mappings.txt
		;;
	*)
		echo "Unknown mode of operation: $1"
		echo "Syntax: ./setup.sh [install-core|install-gui|dryrun-install]"
esac

