#!/bin/bash -eu
#
# @(#) app.sh ver.1.0.0 ver.0.0.0 2014.05.18
#
# Usage:
#   app.sh [mode]
#     arg1 - 処理のモード．
#            0: $MODE_MINIMAL  必要最小限 "minimal" の設定処理を行う．
#            1: $MODE_COMPLETE すべての "complete" 設定処理を行う．
#            mode を設定しない場合は，"1" としてのモードで処理を行う．
#            定数 $MODE_MINIMAL，$MODE_COMPLETE は，functions.sh で定義され
#            ており，`source functions.sh` により取り込まれるもの．
#
# Description:
#   必要なソフトウェア，アプリケーションをインストールする．
#   Homebrew および Homebrew-Cask 導入前提．
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


readonly BINS_MINIMAL=(\
  zsh \
  tmux \
  git \
  wget \
  openssl \
  w3m \
  ag \
  ripgrep \
  the_platinum_searcher \
  pwgen \
  ### for LESS
  node \
  go \
  # python \
  python3 \
  boost \
  expect \
  rsync \
  ### caskformula/caskformula/inkscape
  caskformula/caskformula/inkscape
)

readonly BINS=(\
  ### for handbrake
  libdvdcss \
  ### for radiko
  rtmpdump \
  ffmpeg \
  base64 \
  swftools \
  eye-d3 \
)


# homebrew-cask
readonly APPS_MINIMAL=(\
  alfred \
  dropbox \
  google-chrome \
  iterm2 \
  ### caskroom/versions
  macvim-kaoriya \
)

APPS=(\
  ### caskroom/homebrew-cask
  google-backup-and-sync \
  firefox \
  appcleaner \
  vlc \
  handbrake \
  shiftit \
  gimp \
  licecap \
  keycastr \
  libreoffice \
  libreoffice-language-pack \
  ### woowee/mycask
  mytracks \
)


#
#################### Application Installations and Settings ####################
#
if [ $MODE_IS = $MODE_MINIMAL ]; then
  message="Do you want to install applications, alfred, chrome, dropbox, and macvim-kaoriya ?"
else
  message="Do you want to insall applications ?"
fi

if ! when_its_starting \
      "Application Installations and Settings" \
      "${message}" \
      "$(ps h -o command= $PPID)" \
      "$(basename $(echo $SHELL))"; then
  exit 1
fi



#
# homebrew install, tap, and update
#

myecho "install homebrew..."
type brew >/dev/null 2>&1 || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

myecho "install homebrew-cask..."
brew tap | grep caskroom/cask >/dev/null || brew tap caskroom/cask
brew tap | grep caskroom/versions >/dev/null || brew tap caskroom/versions
brew tap | grep woowee >/dev/null || brew tap woowee/mycask
brew tap | grep sanemat >/dev/null || brew tap sanemat/font
brew tap | grep delphinus >/dev/null || brew tap delphinus/macvim-kaoriya
brew tap | grep caskformula >/dev/null || brew tap caskformula/caskformula


myecho "brew update & upgrade..."
brew update && brew upgrade


#
# installation
#
myecho "install xquartz(x11) ..."
brew cask install "xquartz"            # for ricty


function installation()
{
  local cmd=$1
  shift
  local stuffs=($@)

  for stuff in ${stuffs[@]}
  do
    echo "${PREFIX} $cmd $stuff"
    eval "${cmd} ${stuff}"
    # ref. http://labs.opentone.co.jp/?p=5651
  done

  # ref.http://labs.opentone.co.jp/?p=5890
}

IFS_ORG=$IFS; IFS=$'\n'

# TODO:
myecho -e "Install commands..."
installation "brew install" ${BINS_MINIMAL[@]}
[ $MODE_IS -eq $MODE_COMPLETE ] && installation "brew install" ${BINS[@]}

myecho -e "Install apps..."
installation "brew cask install" ${APPS_MINIMAL[@]}
[ $MODE_IS -eq $MODE_COMPLETE ] && installation "brew cask install" ${APPS[@]}


#
# settings
#

# shell
myecho "Change log-in shell to zsh."
#CHECK:
# path_zsh=$(find $(brew --prefix)/bin -name zsh)
if check_command zsh path_is; then
  #echo ${path_is} | sudo tee -a /etc/shells
  expect -c "
    spawn bash -c \"echo ${path_is} | sudo tee -a /etc/shells\"
    expect \"Password:\"
    send \"${PASSWORD}\n\"
    interact
  "
  # set zsh
  #chsh -s ${path_is}
  expect -c "
    spawn chsh -s ${path_is}
    expect \"Password for $(id -u -n):\"
    send \"${PASSWORD}\n\"
    interact
    "
else
  myecho "Could not find zsh. Settings for zsh was skipped."
fi


#
# "LESS"
#
myecho "Set LESS"
if check_command 'npm'; then
  npm install --global less
else
  myecho  "Could not find npm. npm been installed ?"
fi


#
# "Python"
#
myecho "Set Python"
pip3 install --upgrade setuptools && pip3 install --upgrade pip || true

# mutagen (to use mid3v2)
if ! check_command 'mid3v2'; then
    myecho "setting mutagen..."
    pip3 install mutagen
fi


#
# "Terminal"
#
if [ ${MODE_IS} -eq ${MODE_COMPLETE} ]; then
  myecho "Set Terminal"
  # エンコーディングは UTF-8 のみ。
  defaults write com.apple.terminal StringEncodings -array 4
  # 環境設定 > エンコーディング = [Unicode (UTF-8)]

  #
  # set the default
  #

  # plistbuddy
  readonly PB=/usr/libexec/PlistBuddy
  readonly PLISTIS=${HOME}/Library/Preferences/com.apple.Terminal.plist


  IFS_ORG=$IFS
  IFS=$'\n'

  # get the themes
  url_is=http://cocopon.me/app/vim-iceberg/Iceberg.terminal
  profile_is=$(basename ${url_is} .terminal)

  curl "${url_is}" \
    -o "${DIR_TEMP}/$(basename ${url_is})"

  # remove the tmemes you do not need
  for key in $(${PB} -c "print: 'Window Settings'" ${PLISTIS} | \
                         grep -aE "name =" | \
                         awk -F'=' '{name_is=$2; sub(";","",name_is); gsub(/^[[:space:]]*|[[:space:]]*$/,"",name_is); \
                         print name_is}')
  do
    if [ "$key" != "Pro" ]; then
      # echo "remove the key: ${key}"
      ${PB} -c "Delete :\"Window Settings\":\"${key}\"" ${PLISTIS}
    fi
  done
  IFS=$IFS_ORG

  # apply the theme
  open "${DIR_TEMP}/$(basename ${url_is})"
  sleep 1

  # set defaults
  defaults delete com.apple.Terminal "Default Window Settings"
  defaults write com.apple.Terminal "Default Window Settings" -string "${profile_is}"
  defaults delete com.apple.Terminal "Startup Window Settings"
  defaults write com.apple.Terminal "Startup Window Settings" -string "${profile_is}"

fi


#
# "Photos"
#
myecho "Set photos"
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true


#
# "Alfred"
#
if check_app "alfred" path_is ; then
  myecho "Set Alfred"
  appname=$(basename "${path_is}")
  open -a "${appname}" &
  pid=$!
  wait ${pid}
else
  myecho_error "Could not find \"Alfred\". \"Alfred\" been installed ?"
fi


#
# "Dropbox"
#
if check_app "dropbox" path_is ; then
  myecho "Set Dropbox"
  appname=$(basename "${path_is}")
  open -a "${appname}" &
  pid=$!
  wait ${pid}
else
  myecho_error "Could not find \"Dropbox\". \"Dropbox\" been installed ?"
fi



#
# "iTerm2"
#
if check_app iterm2 path_is ; then
  myecho "Set iTerm2"
  appname=$(basename "${path_is}")

  # reset
  if [ -e ${HOME}/Library/com.googlecode.iterm2.plist ]; then
    mv ${HOME}/Library/com.googlecode.iterm2.plist \
      ${DIR_TEMP}/com.googlecode.iterm2.plist.$(date '+%Y%m%d%H%M')
  fi

  # your plist
  url_is="https://gist.githubusercontent.com/woowee/9efd41d68bca10363d2083902ebc2f43/raw/d307b0261ec954063e2132d7beef4917a43e6f2d/com.googlecode.iterm2.xml"
  ## get plist
  curl "${url_is}" \
    -o "${DIR_TEMP}/$(basename $url_is)"
  ## convert the type
  plutil -convert xml1 ${DIR_TEMP}/com.googlecode.iterm2.xml \
    -o ${DIR_TEMP}/com.googlecode.iterm2.plist
  ## overwrite
  cp -f ${DIR_TEMP}/com.googlecode.iterm2.plist \
    ${HOME}/Library/Preferences/

  defaults read com.googlecode.iterm2 >/dev/null
  # ref.https://github.com/databus23/dotfiles/blob/master/osx
else
  myecho_error "Could not find \"iTerm2\". \"iTerm2\" been installed ?"
fi


#
# font "Ricty"
#
brew cask install "--powerline --vim-powerline ricty" &&:
#c.f. http://qiita.com/ngyuki/items/aefd47700a9522fada75
result=$?
#c.f. http://dqn.sakusakutto.jp/2013/10/shellscript_elif.html
if [ $result -eq 0 ]; then
  myecho "Install the font Ricty..."
  readonly DIR_GENERATED_RICTY=$(brew --prefix)/opt/ricty/share/fonts
  readonly DIR_FONTS=${HOME}/Library/Fonts/
  if (ls ${DIR_GENERATED_RICTY}/Ricty*.ttf >/dev/null 2>&1); then
    [ ! -e ${DIR_FONTS} ] && mkdir ~/Library/Fonts
    cp -f ${DIR_GENERATED_RICTY}/Ricty*.ttf $DIR_FONTS
    fc-cache -vf
  fi
  myecho "Installation of Ricty completed."
else
  brew tap caskroom/fonts
  brew cask install font-ricty-diminished
  myecho "Installed Ricty-Diminished instrad of Ricty."
fi


#
# "MacVim"
#
if check_app macvim-kaoriya path_is ; then
  myecho "Set MacVim"

  readonly DIR_SRC="${HOME}/dots/vimset"
  readonly DIR_DST="${HOME}/.vim"

  if [ -e ${DIR_SRC} ]; then
    [ ! -e ${DIR_DST} ] && mkdir -p ${DIR_DST}

    # once get the path of `DIR_SRC` is absolute
    readonly DIR_SRC_FQPN=$(cd $(dirname $DIR_SRC) && pwd)/$(basename $DIR_SRC)
    # all items under `DIR_SRC` are targets...
    readonly PATTERN=$(echo $DIR_SRC | perl -pe "s/\//\\\\\//g")

    # migration !!
    find "${DIR_SRC_FQPN}" | while read item; do
      # make path
      item_is=$(echo "${item}" | perl -pe "s/"${PATTERN}"//")

      # blank?
      [ -z "${item_is}" ] && continue

      if [ -d "${item}" ]; then
      # the case of directory
        if [ ! -e "${DIR_DST}/${item_is}" ]; then
          mkdir "${DIR_DST}/${item_is}" \
            && echo "  Made the directory. \"${item_is}\""
        fi
      else
        # make symlink
        if ! [ "${item##*/}" = ".DS_Store" -o "${item##*.}" = "un~" ]; then
          ln -fs "${item}" "${DIR_DST}/${item_is}" \
            && echo "  Created symlink.    \"${item_is}\""
        fi
      fi
    done
  fi

  defaults write org.vim.MacVim "MMNativeFullScreen" -bool false
fi


#CHECK::
defaults write com.apple.finder AppleShowAllFiles -boolean true

# fin
echo -e "

----------------------------------------------------------------------
                     Process has been completed.



"

