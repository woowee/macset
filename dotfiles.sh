#!/bin/bash -eu
#
# @(#) dotfiles.sh ver.1.0.0 ver.0.0.0 2014.05.18
#
# Usage:
#   dotfiles.sh
#     arg - なし
#
# Description:
#   dotfiles をダウンロード。
#
###########################################################################

#
# PREPARE
#

# Check the files required for this process
readonly FILE_FUNC="$(dirname $0)/functions.sh"
readonly FILE_CONF="$(dirname $0)/configurations.sh"

function check_files() {
  local esc_red='\033[0;31m'
  local esc_reset='\033[0m'

  local file_is=$1

  # existense check
  if [ ! -e $1 ]; then
    # error message
    echo -e $(basename $0)\)  ${esc_red}ERROR: ${esc_reset} \
      There is not the file \"$1\". \
      Check the file \"${1##*/}\". \
      Process will be canceled.
      exit 1
  fi

  # read
  if ! source ${file_is}; then
    echo -e $(basename $0)\)  ${esc_red}ERROR: ${esc_reset} \
      Couldnot read the file \"$(basename $1)\". \
      The file itself or the content may be incurrect. \
      Process will be canceled.
    exit 1
  fi
}


check_files $FILE_FUNC
check_files $FILE_CONF

[ ! -e ${DIR_TEMP} ] && mkdir -p ${DIR_TEMP}

get_mode $@
# echo "Mode is $MODE_IS."


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

# TODO:
ln -fs ${dotfiles}/dein.toml ${HOME}/dein.toml

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


myecho "${ESC_YLW}DONE: Dotfiles settings.${ESC_OFF}"
