#!/bin/bash -u

set -e

dir_current=$(dirname $0)
cd ${dir_current}

source ${dir_current}/functions.sh

type brew >/dev/null 2>&1 || ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

if ! brew tap >/dev/null 2>&1; then
    brew tap homebrew/dupes
    brew tap sanemat/font
    brew tap phinze/cask
    brew tap woowee/mycask
fi

brew update && brew upgrade

brew install zsh
brew install tmux

brew install git
brew install wget
brew install openssl
brew install w3m

brew install rtmpdump
brew install ffmpeg
brew install base64
brew install swftools
brew install eyeD3
brew install libdvdcss    # handbrake

brew install go
brew install python
brew install python3
brew link --overwrite python

brew install rsync
brew install ricty
cp -f $(brew --prefix)/share/fonts/Ricty*.ttf ~/Library/Fonts/ && fc-cache -vf && echo "ricty was installed..." && echo "warrning: installation of ricty occured some error..." 1>&2

brew install brew-cask
brew cask install alfred
brew cask install google-chrome
brew cask install appcleaner
brew cask install dropbox
brew cask install evernote
brew cask install iterm2
brew cask install libreoffice
brew cask install vlc
brew cask install handbrake
brew cask install bettertouchtool
brew cask install shiftit
brew cask install gimp-lisanet
brew cask install inkscape
brew cask install mytracks

brew cask alfred link

## settings for applications/commands
#
#

# zsh
# path_zsh=$(mdfinds -onlyin $(brew --prefix) -name zsh)
path_zsh=$(find $(brew --prefix)/bin -name zsh)
if [ -n ${path_zsh} ]; then
    echo -e "\033[32m==>\033[0m zsh settings..."
    echo "zsh: ${path_zsh}"
    # add zsh
    echo ${path_zsh} | sudo tee -a /etc/shells
    # set zsh
    chsh -s ${path_zsh}
fi

# iterm2
if check_existence_app 'iTerm.app' path_app; then
    echo -e "\033[32m==>\033[0m iterm settings..."
    echo "iterm: ${path_app}"
fi

# mutagen to use mid3v2
if ! check_existence_command 'mutagen'; then
    echo -e "\033[32m==>\033[0m mutagen installation..."
    pip install mutagen
fi


cat << END


**************************************************
               NOW IT'S DONE.
**************************************************


END

