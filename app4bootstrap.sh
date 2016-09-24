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
app_macvim_url='https://github.com/splhack/macvim-kaoriya/releases/download/20160312/MacVim-KaoriYa-20160312.dmg'

app_alfred_name="Alfred 2"
app_alfred_brewname="alfred"
app_alfred_filename="Alfred 2.app"
app_alfred_url='https://cachefly.alfredapp.com/Alfred_2.8.3_435.zip'

app_chrome_name='Google Chrome'
app_chrome_brewname='google-chrome'
app_chrome_filename='Google Chrome.app'
app_chrome_url='https://dl.google.com/chrome/mac/stable/GGRM/googlechrome.dmg'

app_iterm2_name='iTerm2'
app_iterm2_brewname='iterm2'
app_iterm2_filename='iTerm.app'
app_iterm2_url='https://iterm2.com/downloads/stable/iTerm2-2_1_4.zip'



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

type brew &>/dev/null

if [ "$?" -eq 0 ]; then
  execho "Been installed Homebrew. Update brew."
  brew update
else
  execho "Install Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  execho "Install Homebrew Cask"
  brew tap | grep caskroom/cask >/dev/null || brew tap caskroom/cask

  execho "Install Homebrew MY Cask"
  brew tap | grep woowee/mycask >/dev/null || brew tap woowee/mycask

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


# iTerm2.app
execho "${app_iterm2_filename} Settings..."
if check_existence_app "${app_iterm2_filename}" path_app; then
    execho "${app_iterm2_filename}= ${path_app}"

    #execho "opening iterm2. please wait ..."
    #open -W -a "${app_iterm2_filename}"
    cd "${dir_tmp}"

    curl -o com.googlecode.iterm2.plist https://gist.githubusercontent.com/woowee/53fd864693f2ea01a247/raw/1efbfd5578149fac9937107f80859d5058bc4e07/com.googlecode.iterm2.plist
    cp -f com.googlecode.iterm2.plist ${HOME}/Library/Preferences

    curl -o "Solarized Dark.itermcolors" https://raw.githubusercontent.com/altercation/solarized/master/iterm2-colors-solarized/Solarized%20Dark.itermcolors
    open "Solarized Dark.itermcolors"; rm "Solarized Dark.itermcolors"

    curl -o Hybrid.itermcolors https://gist.githubusercontent.com/w0ng/5e0a431531670e05dc4f/raw/138b83d2736070f7b089a1ff22068c2d1702cf6c/gistfile1.txt
    open Hybrid.itermcolors; rm Hybrid.itermcolors
    # ref.https://github.com/databus23/dotfiles/blob/master/osx

    plist="${HOME}/Library/Preferences/com.googlecode.iterm2.plist"
    if [ -e "${plist}" ]; then
        #blur
        sudo /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Blur\" true" ${HOME}/Library/Preferences/com.googlecode.iterm2.plist
        sudo /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Blur Radius\" 2.500" ${HOME}/Library/Preferences/com.googlecode.iterm2.plist
        #transparency
        sudo /usr/libexec/PlistBuddy -c "Print :\"New Bookmarks\":0:\"Transparency\"" ${HOME}/Library/Preferences/com.googlecode.iterm2.plist
        sudo /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Transparency\" 0.250" ${HOME}/Library/Preferences/com.googlecode.iterm2.plist
        #window type
        sudo /usr/libexec/PlistBuddy -c "Print :\"New Bookmarks\":0:\"Window Type\"" ${HOME}/Library/Preferences/com.googlecode.iterm2.plist
        sudo /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Window Type\" 2" ${HOME}/Library/Preferences/com.googlecode.iterm2.plist

        # Don’t display the annoying prompt when quitting iTerm
        defaults write com.googlecode.iterm2 PromptOnQuit -bool false
    else
        execho "Oops! ${plist} was not found. Please set preferences of iTerm2 later."
    fi

    cd ${HOME}

else
    execho "Sorry, ${app_iterm2_filename} was not found..."
fi

# Terminal.app
# does it mean that can not set itself while using Terminal.app itself ?

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
