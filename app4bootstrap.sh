#!/bin/bash -u

set -e

#sudo -v
#while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

dir_current=$(dirname $0)
cd ${dir_current}



#
# check file configration
#
filename_func="functions.sh"

# read functions
source ${dir_current}/${filename_func}


#
# prepare template dir
#
dir_tmp="${HOME}/tmp"
[ -e "${dir_tmp}" ] || mkdir -p "${dir_tmp}"

#
# Applications
#
app_macvim_name='MacVim-KaoriYa'
app_macvim_brewname='macvim-kaoriya'
app_macvim_filename='MacVim.app'

app_alfred_name="Alfred 2"
app_alfred_brewname="alfred"
app_alfred_filename="Alfred 2.app"

app_chrome_name='Google Chrome'
app_chrome_brewname='google-chrome'
app_chrome_filename='Google Chrome.app'

app_iterm2_name='iTerm2'
app_iterm2_brewname='iterm2'
app_iterm2_filename='iTerm.app'



#
# FUNCTIONS {
#
installby_brew()
{

  for app in $*
  do
    execho "installing $app ..."
    brew cask install $app
    # TODO: error case.
  done

}


#
# } FUNCTIONS
#



#
# Installation
#
execho "install apps using homebrew-cask..."

switch_installation_brew=0

type brew &>/dev/null || switch_installation_brew=1

if [ "$switch_installation_brew" -eq 1 ]; then
  execho "Install Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  execho "Install Homebrew Cask"
  brew tap | grep caskroom/cask >/dev/null || brew tap caskroom/cask

  execho "Install Homebrew MY Cask"
  brew tap | grep woowee/mycask >/dev/null || brew tap woowee/mycask

else
  execho "Been installed Homebrew. Update brew."
  brew update

fi

installby_brew \
        "${app_alfred_brewname}" \
        "${app_chrome_brewname}" \
        "${app_macvim_brewname}" \
        "${app_iterm2_brewname}"



#
# Settings
#
execho "Setting for the applications..."

# Alfred.app
execho "${app_alfred_filename} Settings ..."
if check_existence_app "${app_alfred_filename}" path_app; then
    execho "opening alfred 2 once..."
    open -a "${app_alfred_filename}"
else
    execho "Sorry, ${app_alfred_filename} was not found..."
fi

# MacVim.app + plugins, and settings for personal runtimepath (ex. ftplugins)
execho "${app_macvim_filename} Settings..."
if check_existence_app "${app_macvim_filename}" app_path; then
    execho "${app_macvim_filename}= ${app_path}"

    defaults write org.vim.MacVim "MMNativeFullScreen" -bool false

else
    execho "Sorry, ${app_macvim_filename} was not found..."
fi

# photos.app
execho "setting photos.app..."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true


#fin
execho "${esc_ylw}DONE: App Installations and Some Settings${esc_off}"
