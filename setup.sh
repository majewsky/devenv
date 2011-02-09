#!/bin/bash

if [ ! -d .git -o ! -f mappings.txt ]; then
	echo "Execute this script from the toplevel directory of the devenv repo."
	exit 1
fi

case $1 in
	install)
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
		# compile prettyprompt
		GXX_EXTRA_ARGS=""
		[ -d /usr/include/qt4 ] && GXX_EXTRA_ARGS="-I/usr/include/qt4"
		g++ $GXX_EXTRA_ARGS -lQtCore -o $HOME/bin/prettyprompt $PWD/bin/prettyprompt.cpp
		# compile kfullscreenrunner
		ORIGPWD=$PWD
		mkdir -p $ORIGPWD/build/kfullscreenrunner
		cd $ORIGPWD/build/kfullscreenrunner
		cmake -DCMAKE_INSTALL_PREFIX=$HOME $ORIGPWD/bin/kfullscreenrunner
		make -j2
		make install/fast
		;;
	dryrun-install)
		while read SOURCE DEST; do
			if [ ! -L $HOME/$DEST ]; then
				echo ln -s $PWD/$SOURCE $HOME/$DEST
			fi
		done < mappings.txt
		GXX_EXTRA_ARGS=""
		[ -d /usr/include/qt4 ] && GXX_EXTRA_ARGS="-I/usr/include/qt4"
		echo g++ $GXX_EXTRA_ARGS -lQtCore -o $HOME/bin/prettyprompt $PWD/bin/prettyprompt.cpp
		;;
	*)
		echo "Unknown mode of operation: $1"
		echo "Syntax: ./setup.sh install"
esac

