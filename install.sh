#!/usr/bin/env bash
set -euo pipefail
cd "$(readlink -f "$(dirname "$0")")"

################################################################################
# create symlinks to dotfiles etc. in this repo

setup_link() {
    SOURCE="$1"
    TARGET="$2"
    if [ -e "${TARGET}" -a ! -L "${TARGET}" ]; then
        echo "Conflict with existing non-symlink ${TARGET}" >&2
        return 1
    fi
    ln -sfT "${PWD}/${SOURCE}" "${TARGET}"
}

find toplevel -type f | while read SOURCE; do
    setup_link "${SOURCE}" "${HOME}/.${SOURCE#*/}"
done
mkdir -p /x/bin
find bin -maxdepth 1 -type f -executable | while read SOURCE; do
    setup_link "${SOURCE}" "/x/bin/${SOURCE#*/}"
done
for DIR in vim zsh-functions; do
    setup_link "${DIR}" "${HOME}/.${DIR}"
done

################################################################################
# initialize Vim plugins if necessary

if [ ! -d vim/bundle/Vundle.vim/.git ]; then
    git clone https://github.com/gmarik/Vundle.vim.git vim/bundle/Vundle.vim
    vim +PluginInstall +qall
fi
