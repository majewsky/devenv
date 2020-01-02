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
    mkdir -p "$(dirname "${TARGET}")"
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

################################################################################
# build Sway config

if hash sway &> /dev/null; then
    mkdir -p "${HOME}/.config/sway"
    printf "include $PWD/%s\n" $(ls -1 sway/common/*.conf sway/"$(hostname)"/*.conf | sort -t/ -k3) > "${HOME}/.config/sway/config"
fi

if hash i3status-rs &> /dev/null; then
    for FILE in $(ls -1 i3status-rust/common/*.toml i3status-rust/"$(hostname)"/*.toml | sort -t/ -k3); do
        cat "${FILE}"
        echo
    done > "${HOME}/.config/i3status-rust.toml"
fi

################################################################################
# inject customizations into Firefox profiles

if [ -d "${HOME}/.mozilla/firefox" ]; then
    for PROFILE_DIR in "${HOME}/.mozilla/firefox"/*.default; do
        git ls-files firefox | while read SOURCE_FILE; do
            setup_link "${SOURCE_FILE}" "${PROFILE_DIR}/${SOURCE_FILE#firefox/}"
        done
    done
fi
