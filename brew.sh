#!/bin/bash -u
set -e

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

dir_current=$(dirname $0)
cd ${dir_current}

source ${dir_current}/functions.sh

here=$(basename $0)

#
# staff to install
#

# homebrew
bins=(\
"zsh" \
"tmux" \
"git" \
"wget" \
"openssl" \
"w3m" \
"go" \
"python" \
"python3" \
### for radiko
"rtmpdump" \
"ffmpeg" \
"base64" \
"swftools" \
"eyeD3" \
### for handbrake
"libdvdcss" \
### homebrew/dupes
"rsync" \
### sanemat/font
"ricty" \
)

# homebrew-cask
apps=(\
### phinze/cask
"alfred" \
"google-chrome" \
"appcleaner" \
"dropbox" \
"evernote" \
"iterm2" \
"libreoffice" \
"vlc" \
"handbrake" \
"bettertouchtool" \
"shiftit" \
"gimp-lisanet" \
"inkscape" \
### woowee/mycask
"mytracks" \
"macvim-kaoriya" \
)


#
# homebrew install, tap, and update
#
type brew >/dev/null 2>&1 || ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

brew tap homebrew/dupes
brew tap sanemat/font
brew tap phinze/cask
brew tap woowee/mycask

brew update && brew upgrade

#
# brew
#
echo -e "\033[32m${here}>\033[0m brew install..."
for bin in "${bins[@]}"; do brew install "${bin}"; done


#
# cask
#
brew upgrade brew-cask || true
brew cask update
echo -e "\033[32m${here}>\033[0m brew cask install..."
for app in "${apps[@]}"; do brew cask install "${app}"; done


#
# settings for applications/commands, etc
#

# shell
path_zsh=$(find $(brew --prefix)/bin -name zsh)
if [ -n ${path_zsh} ]; then
    echo -e "\033[32m${here}>\033[0m shell, zsh settings..."
    echo "zsh: ${path_zsh}"
    # add zsh
    echo ${path_zsh} | sudo tee -a /etc/shells
    # set zsh
    chsh -s ${path_zsh}
fi

# iterm2
if check_existence_app 'iTerm.app' path_app; then
    echo -e "\033[32m${here}>\033[0m iterm settings..."
    echo "iterm: ${path_app}"
    #todo. iterm settings (should use profile ?)
fi

# python
brew link --overwrite python
pip install --upgrade setuptools
pip install --upgrade pip

# ricty
cp -f $(brew --prefix)/share/fonts/Ricty*.ttf ~/Library/Fonts/ && fc-cache -vf && echo "ricty was installed..." && echo "warrning: installation of ricty occured some error..." 1>&2

# mutagen (to use mid3v2)
if ! check_existence_command 'mutagen'; then
    echo -e "\033[32m${here}>\033[0m mutagen installation..."
    pip install mutagen
fi

# alfred
brew cask alfred link


cat << END


**************************************************
               NOW IT'S DONE.
**************************************************


END
