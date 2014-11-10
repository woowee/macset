#!/bin/bash -u
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
### for radiko
rtmpdump \
ffmpeg \
base64 \
swftools \
eyeD3 \
the_silver_searcher \
### for handbrake
libdvdcss \
### phinze/cask
brew-cask \
### homebrew/dupes
rsync \
### sanemat/font
automake \
ricty \
)

# homebrew-cask
apps=(\
### phinze/cask
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

execho "homebrew install..."
type brew >/dev/null 2>&1 || ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

execho "brew tap..."
brew tap homebrew/dupes
brew tap phinze/cask
brew tap sanemat/font
brew tap woowee/mycask

execho "brew update & upgrade..."
brew update && brew upgrade

execho "brew cask updating..."
brew upgrade brew-cask || true
brew cask update

# for installation of ricty
execho "brew cask updating..."
brew cask install "xquartz"


#
# brew
#
execho "brew install commands..."
for bin in "${bins[@]}";
do
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
    execho "shell, zsh settings..."
    execho "zsh: ${path_zsh}"
    # add zsh
    echo ${path_zsh} | sudo tee -a /etc/shells
    # set zsh
    chsh -s ${path_zsh}
fi

# iterm2
# ref. app4bootstrap.sh

# terminal.app
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
    open "${HOME}/${dir_tmp}/${term_profile}.terminal"
    sleep 1; # Wait a bit to make sure the theme is loaded
    defaults write com.apple.terminal 'Default Window Settings' -string "${term_profile}"
    defaults write com.apple.terminal 'Startup Window Settings' -string "${term_profile}"
fi;
#if [ "${current_profile}" != "Pro" ]; then
#    open "${HOME}/${dir_tmp}/${term_profile}.terminal"
#    sleep 1; # Wait a bit to make sure the theme is loaded
#    defaults write com.apple.terminal 'Default Window Settings' -string 'Pro';
#    defaults write com.apple.terminal 'Startup Window Settings' -string 'Pro';
#fi;

# ricty
cp -f $(brew --prefix)/share/fonts/Ricty*.ttf ~/Library/Fonts/ && fc-cache -vf && echo "ricty was installed..."

# python
brew link --overwrite python
pip install --upgrade setuptools && pip install --upgrade pip || true

# mutagen (to use mid3v2)
if ! check_existence_command 'mid3v2'; then
    execho "mutagen installation..."
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

# alfred (kMDItemFSName = "Alfred 2.app")
brew cask alfred link


cat << END


**************************************************
               NOW IT'S DONE.
**************************************************


END
