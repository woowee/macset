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


#
# staff to install
#

# homebrew
readonly BINS=(\
zsh \
tmux \
git \
wget \
openssl \
w3m \
ag \
go \
# python \
python3 \
### for LESS
node \
### for radiko
rtmpdump \
ffmpeg \
base64 \
swftools \
# eyeD3 \  TODO: hey, "Error: No formulae found in taps." ?
### for handbrake
libdvdcss \
### homebrew/dupes
rsync \
### sanemat/font
ricty \
)

# homebrew-cask
readonly APPS_MINIMAL=(\
alfred \
dropbox \
google-chrome \
### caskroom/versions
macvim-kaoriya \
)
APPS=(\
### caskroom/homebrew-cask
google-drive \
"firefox --language=ja" \
appcleaner \
iterm2 \
vlc \
handbrake \
shiftit \
gimp \
inkscape \
licecap \
keycastr \
### woowee/mycask
mytracks \
# "$(brew --repository)/Library/Taps/caskroom/homebrew-cask/developer/bin/generate_cask_token" MyTracks
)


#
# homebrew install, tap, and update
#

myecho "install homebrew..."
type brew >/dev/null 2>&1 || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

myecho "install homebrew-cask..."
# brew tap | grep caskroom/cask >/dev/null || brew install caskroom/cask/brew-cask
brew tap | grep caskroom/cask >/dev/null || brew tap caskroom/cask
brew tap | grep caskroom/dupes >/dev/null || brew tap homebrew/dupes
brew tap | grep caskroom/versions >/dev/null || brew tap caskroom/versions
brew tap | grep woowee >/dev/null || brew tap woowee/mycask
brew tap | grep sanemat >/dev/null || brew tap sanemat/font


myecho "brew update & upgrade..."
brew update && brew upgrade


# for ricty installation
myecho "install xquartz(x11) ..."
brew cask install "xquartz"


#
# installation
#
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

echo -e "${PREFIX} Install commands..."
installation "brew install" ${BINS[@]}
echo -e "${PREFIX} Install apps..."
installation "brew cask install" ${APPS_MINIMAL[@]}
if [ $MODE_IS -eq $MODE_COMPLETE ]; then
  installation "brew cask install" ${APPS[@]}
fi

IFS=$IFS_ORG



#
# settings
#

# shell
path_zsh=$(find $(brew --prefix)/bin -name zsh)
if [ -n ${path_zsh} ]; then
    myecho "setting shell..."
    myecho "zsh: ${path_zsh}"
    # add zsh
    echo ${path_zsh} | sudo tee -a /etc/shells
    # set zsh
    chsh -s ${path_zsh}
fi

# iterm2
# ref. app4bootstrap.sh

# terminal.app
myecho "set terminal..."
# エンコーディングは UTF-8 のみ。
defaults write com.apple.terminal StringEncodings -array 4
# 環境設定 > エンコーディング = [Unicode (UTF-8)]

cd "${DIR_TEMP}"

# Use a modified version of the Solarized Dark theme by default in Terminal.app
curl -o "Solarized Dark.terminal" https://gist.githubusercontent.com/woowee/3ff014f5a969e9cfc3a7/raw/efa793e6e9f0a89b11c743db6aafa33b93293608/Solarized%2520Dark.terminal
sleep 1; # Wait a bit...

#TODO:
# term_profile='Solarized Dark'
# current_profile="$(defaults read com.apple.terminal 'Default Window Settings')";
# if [ "${current_profile}" != "${term_profile}" ]; then
#     open "${dir_tmp}/${term_profile}.terminal"
#     sleep 1; # Wait a bit to make sure the theme is loaded
#     defaults write com.apple.terminal 'Default Window Settings' -string "${term_profile}"
#     defaults write com.apple.terminal 'Startup Window Settings' -string "${term_profile}"
#     killall "Terminal"
# fi;

# LESS
if check_existence_command 'npm'; then
  myecho "setting LESS..."
  npm install --global less
else
  myecho "npm has not been installed. can't use LESS but is that okay?"
fi

#TODO:
### font
#execho "installing ricty-diminished..."
#brew cask install font-ricty-diminished &&:

# python
myecho "setting python..."
pip3 install --upgrade setuptools && pip3 install --upgrade pip || true

#TODO:
# # mutagen (to use mid3v2)
# if ! check_existence_command 'mid3v2'; then
#     execho "setting mutagen..."
#     if ! pip install mutagen; then
#         [ ! -e $HOME/tmp ] || mkdir -p $HOME/tmp
#         mutagen_url="https://pypi.python.org/packages/source/m/mutagen/mutagen-1.22.tar.gz"
#         mutagen_name=${mutagen_url##*/}
#         cd $HOME/tmp
#         curl --location --remote-name "${mutagen_url}"
#         tar zxvf "${mutagen_name}"
#         cd $(basename $mutagen_name .tar.gz)
#         python setup.py build
#         sudo python setup.py install
#     fi
# fi

#TODO:
# cd ${dir_current}


# photos.app
myecho "set photos.app..."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true



cat << END


**************************************************
NOW IT'S DONE.
**************************************************


END
