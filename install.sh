#!/usr/bin/env bash
set -euo pipefail
cd "$(readlink -f "$(dirname "$0")")"

################################################################################
# create symlinks to dotfiles etc. in this repo

setup_link() {
    SOURCE="$1"
    TARGET="$2"
    if [ -e "${TARGET}" ] && [ ! -L "${TARGET}" ]; then
        echo "Conflict with existing non-symlink ${TARGET}" >&2
        return 1
    fi
    mkdir -p "$(dirname "${TARGET}")"
    ln -sfT "${PWD}/${SOURCE}" "${TARGET}"
}

find toplevel -type f | while read -r SOURCE; do
    setup_link "${SOURCE}" "${HOME}/.${SOURCE#*/}"
done
mkdir -p /x/bin
find bin -maxdepth 1 -type f -executable | while read -r SOURCE; do
    setup_link "${SOURCE}" "/x/bin/${SOURCE#*/}"
done
for DIR in vim zsh-functions config/opencode; do
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

collect_snippets() {
    find "${1%.*}/" -maxdepth 2 -name \*."${1#*.}" | awk -F/ -v hostname="$(hostname)" '$2 == "common" || $2 == hostname' | sort -t/ -k3
}

if hash sway &> /dev/null; then
    mkdir -p "${HOME}/.config/sway"
    collect_snippets sway.conf | xargs printf "include $PWD/%s\n" > "${HOME}/.config/sway/config"
fi

if hash i3status-rs &> /dev/null; then
    for FILE in $(collect_snippets i3status-rust.toml); do
        cat "${FILE}"
        echo
    done > "${HOME}/.config/i3status-rust.toml"
fi

################################################################################
# inject customizations into Firefox profiles

if [ -d "${HOME}/.mozilla/firefox" ]; then
    for PROFILE_DIR in "${HOME}/.mozilla/firefox"/*.default; do
        git ls-files firefox | while read -r SOURCE_FILE; do
            setup_link "${SOURCE_FILE}" "${PROFILE_DIR}/${SOURCE_FILE#firefox/}"
        done
    done
fi
