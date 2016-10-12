#!/bin/bash

if [ ! -d .git -o ! -f mappings.txt ]; then
	echo "Execute this script from the toplevel directory of the devenv repo."
	exit 1
fi

git_clone()
{
	local REPO="$1"
	local DEST="$2"
	if [ -d "$DEST" ]; then
		git -C "$DEST" pull
	else
		mkdir -p "$(dirname "$DEST")"
		git clone "$REPO" "$DEST"
	fi
}


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
			DEST_DIR="$(dirname "$HOME/$DEST")"
			if [ ! -d "$DEST_DIR" ]; then
				mkdir -p "$DEST_DIR"
			fi
			if [ ! -L $HOME/$DEST ]; then
				ln -s $PWD/$SOURCE $HOME/$DEST
			fi
		done < mappings.txt

	if [ -d "$HOME/.vim" ]; then
		git_clone https://github.com/gmarik/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
	fi
	vim +PluginInstall +qall
}

install_gui()
{
	# compile quickstart
	ORIGPWD=$PWD
	mkdir -p $ORIGPWD/build/quickstart
	cd $ORIGPWD/build/quickstart
	cmake -DCMAKE_INSTALL_PREFIX=$HOME -DCMAKE_BUILD_TYPE=Release $ORIGPWD/bin/quickstart
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

