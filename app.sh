#!/bin/bash -ux
set -e

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

dir_current=$(dirname $0)
cd ${dir_current}

source ${dir_current}/functions.sh

#
# prepare template dir
#
dir_tmp="${HOME}/tmp"
[ -e "${dir_tmp}" ] || mkdir -p "${dir_tmp}"


#
# staff to install
#

# homebrew
bins=(\
zsh \
tmux \
git \
wget \
openssl \
w3m \
ag \
go \
python \
python3 \
### for LESS
node \
### for radiko
rtmpdump \
ffmpeg \
base64 \
swftools \
eyeD3 \
### for handbrake
libdvdcss \
### homebrew/dupes
rsync \
### woowee/font
ricty \
)

# homebrew-cask
apps=(\
### caskroom/homebrew-cask
alfred \
google-chrome \
appcleaner \
dropbox \
evernote \
iterm2 \
vlc \
handbrake \
shiftit \
gimp \
inkscape \
### woowee/mycask
mytracks \
macvim-kaoriya \
)


#
# homebrew install, tap, and update
#

execho "installing homebrew..."
type brew >/dev/null 2>&1 || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

execho "installing homebrew-cask..."
brew tap | grep caskroom/cask >/dev/null || brew install caskroom/cask/brew-cask

execho "brew tap..."
brew tap homebrew/dupes
brew tap woowee/font
brew tap woowee/mycask

execho "brew update & upgrade..."
brew update && brew upgrade

execho "brew cask update..."
brew upgrade brew-cask || true
brew cask update

# for ricty installation
execho "installing xquartz(x11) ..."
brew cask install "xquartz"


#
# brew
#
execho "brew install commands..."
for bin in "${bins[@]}"; do
    brew install "${bin}"
    # some process as needed
done


#
# cask
#
execho "brew cask install apps..."
for app in "${apps[@]}"; do brew cask install "${app}"; done


#
# settings
#

# shell
path_zsh=$(find $(brew --prefix)/bin -name zsh)
if [ -n ${path_zsh} ]; then
    execho "setting shell..."
    execho "zsh: ${path_zsh}"
    # add zsh
    echo ${path_zsh} | sudo tee -a /etc/shells
    # set zsh
    chsh -s ${path_zsh}
fi

# iterm2
# ref. app4bootstrap.sh

# terminal.app
execho "setting terminal..."
# エンコーディングは UTF-8 のみ。
defaults write com.apple.terminal StringEncodings -array 4
# 環境設定 > エンコーディング = [Unicode (UTF-8)]

cd "${dir_tmp}"

# Use a modified version of the Solarized Dark theme by default in Terminal.app
curl -o "Solarized Dark.terminal" https://gist.githubusercontent.com/woowee/3ff014f5a969e9cfc3a7/raw/fdae845aeaf5295f9c422afa1b4ae8c08cdcf303/Solarized%20Dark.terminal
sleep 1; # Wait a bit...
term_profile='Solarized Dark'
current_profile="$(defaults read com.apple.terminal 'Default Window Settings')";
if [ "${current_profile}" != "${term_profile}" ]; then
    open "${dir_tmp}/${term_profile}.terminal"
    sleep 1; # Wait a bit to make sure the theme is loaded
    defaults write com.apple.terminal 'Default Window Settings' -string "${term_profile}"
    defaults write com.apple.terminal 'Startup Window Settings' -string "${term_profile}"
    killall "Terminal"
fi;
#if [ "${current_profile}" != "Pro" ]; then
#    open "${HOME}/${dir_tmp}/${term_profile}.terminal"
#    sleep 1; # Wait a bit to make sure the theme is loaded
#    defaults write com.apple.terminal 'Default Window Settings' -string 'Pro';
#    defaults write com.apple.terminal 'Startup Window Settings' -string 'Pro';
#fi;

# LESS
if check_existence_command 'npm'; then
  execho "setting LESS..."
  npm install --global less
else
  execho "npm has not been installed. can't use LESS but is that okay?"
fi

# ricty
execho "setting ricty..."
dirRicty=$(mdfind -onlyin "$(brew --prefix)/Cellar" "kMDItemFSName == 'ricty' && kMDItemKind == 'フォルダ'")
dirRictyVer="$(ls "${dirRicty}" | sort -rf | head -1)"
dirRictyIs="${dirRicty}/${dirRictyVer}/share/fonts"
if [ -n "${dirRictyIs}" ]; then
  cp "${dirRictyIs}"/Ricty*.ttf ~/Library/Fonts/ &&:
  if [ $? -ne 0 ]; then
    execho "could ${esc_bld}NOT${esc_off} install ricty."
  else
    fc-cache -vf
    execho "ricty has been installed."
  fi
else
  # err
  execho "could ${esc_bld}NOT${esc_off} install ricty."
fi

# python
execho "setting python..."
brew link --overwrite python
pip install --upgrade setuptools && pip install --upgrade pip || true

# mutagen (to use mid3v2)
if ! check_existence_command 'mid3v2'; then
    execho "setting mutagen..."
    if ! pip install mutagen; then
        [ ! -e $HOME/tmp ] || mkdir -p $HOME/tmp
        mutagen_url="https://pypi.python.org/packages/source/m/mutagen/mutagen-1.22.tar.gz"
        mutagen_name=${mutagen_url##*/}
        cd $HOME/tmp
        curl --location --remote-name "${mutagen_url}"
        tar zxvf "${mutagen_name}"
        cd $(basename $mutagen_name .tar.gz)
        python setup.py build
        sudo python setup.py install
    fi
fi

cd ${dir_current}


# xcode
execho "setting xcode..."
cd ${HOME}
git clone https://github.com/XVimProject/XVim.git
cd XVim
make


# alfred (kMDItemFSName = "Alfred 2.app")
brew cask alfred link


cat << END


**************************************************
NOW IT'S DONE.
**************************************************


END
