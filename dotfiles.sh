#!/bin/bash -u

set -e

#sudo -v
#while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

dir_current=$(dirname $0)
cd ${dir_current}

#
# check file configration
#
filename_conf="config.sh"
filename_func="functions.sh"

filename_check="check4running.sh"
if [ ! -e "${dir_current}/${filename_check}" ]; then
    echo -e "\033[1;32m$(basename $0)==>\033[0m Cannot run because some necessary information or files is missing. Check your execution enviroment. (Is there '${dir_current}/${filename_check}' ?)"
    exit 1
fi

${dir_current}/${filename_check} ${filename_conf} ${filename_func}

# read configuraton
source ${dir_current}/${filename_conf}

# read functions
source ${dir_current}/${filename_func}


#
# Dotfiles
#
dotfiles="${HOME}/dots"

if [ -e "${dotfiles}" ]; then
    mv "${dotfiles}" "${dotfiles}~$(date '+%Y%m%d%H%M')"
fi
mkdir -p ${dotfiles}

git clone https://github.com/woowee/dots.git "${dotfiles}"

ln -fs ${dotfiles}/.vimrc ${HOME}/.vimrc
ln -fs ${dotfiles}/.gvimrc ${HOME}/.gvimrc
ln -fs ${dotfiles}/.zshrc ${HOME}/.zshrc
ln -fs ${dotfiles}/.gitignore ${HOME}/.gitignore

if [ -e ${HOME}/.gitconfig ]; then
    if ! $(grep "excludesfile.*\.gitignore" ${HOME}/.gitconfig >/dev/null); then
        cat << EOF >> "${HOME}/.gitconfig"
[core]
   excludesfile = ~/.gitignore
EOF
    fi
else
    cat << EOF > "${HOME}/.gitconfig"
[core]
    excludesfile = ~/.gitignore
EOF
fi

# set .gitconf again
# git config --global user.name "${MyGITHUB_USERNAME}"
# git config --global user.email "${MyGITHUB_EMAIL}"


execho "${esc_ylw}DONE!!: Settings for dotfiles.${esc_off}"
