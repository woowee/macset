#!/bin/bash -u
set -e

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

dir_current=$(dirname $0)
cd ${dir_current}

source ${dir_current}/functions.sh

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
bettertouchtool \
shiftit \
gimp-lisanet \
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
execho "brew cask updating..."
brew upgrade brew-cask || true
brew cask update
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
if check_existence_app 'iTerm.app' path_app; then
    execho "iterm settings..."
    execho "iterm: ${path_app}"

    #blur
    /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Blur\" true" Library/Preferences/com.googlecode.iterm2.plist
    /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Blur Radius\" 2.500" Library/Preferences/com.googlecode.iterm2.plist
    #transparency
    /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Transparency\" 0.250" Library/Preferences/com.googlecode.iterm2.plist
    #wond type
    /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Window Type\" 2" Library/Preferences/com.googlecode.iterm2.plist
fi

# ricty
cp -f $(brew --prefix)/share/fonts/Ricty*.ttf ~/Library/Fonts/ && fc-cache -vf && echo "ricty was installed..."

# python
brew link --overwrite python
pip install --upgrade setuptools
pip install --upgrade pip

# mutagen (to use mid3v2)
if ! check_existence_command 'mutagen'; then
    execho "mutagen installation..."
    if ! pip install mutagen; then
        [ ! -e $HOME/tmp ] || mkdir -p $HOME/tmp
        mutagen_url="https://pypi.python.org/packages/source/m/mutagen/mutagen-1.22.tar.gz"
        mutagen_name=${mutagen_url##*/}
        curl --location --remote-name "${mutagen_url}"
        tar zxvf "${HOME}/${mutagen_name}"
        cd ${HOME}/$(basename $mutagen_name .tar.gz)
        python setup.py build
        sudo python setup.py install
    fi
fi

# alfred (kMDItemFSName = "Alfred 2.app")
brew cask alfred link


cat << END


**************************************************
               NOW IT'S DONE.
**************************************************


END
