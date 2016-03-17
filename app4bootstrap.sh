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
app_macvim_url='https://github.com/splhack/macvim/releases/download/20140805/macvim-kaoriya-20140805.dmg'

app_alfred_name="Alfred 2"
app_alfred_brewname="alfred"
app_alfred_filename="Alfred 2.app"
app_alfred_url='https://cachefly.alfredapp.com/Alfred_2.5.1_308.zip'

app_chrome_name='Google Chrome'
app_chrome_brewname='google-chrome'
app_chrome_filename='Google Chrome.app'
app_chrome_url='https://dl.google.com/chrome/mac/stable/GGRM/googlechrome.dmg'

app_iterm2_name='iTerm2'
app_iterm2_brewname='iterm2'
app_iterm2_filename='iTerm.app'
app_iterm2_url='http://www.iterm2.com/downloads/stable/iTerm2_v2_0.zip'



#
# FUNCTIONS {
#
installby_brew()
{
    execho "install homebrew..."
    type brew >/dev/null 2>&1 || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    # set PATH
    [ -e ${HOME}/.bashrc ] || touch ${HOME}/.bashrc
    echo "export PATH=/usr/local/bin:/usr/local/sbin:$PATH" > ${HOME}/.bashrc
    source ${HOME}/.bashrc
    execho "PATH: ${PATH}"

    execho "update and upgrade homebrew..."
    brew update && brew upgrade

    execho "install homebrew-cask..."
    # brew tap | grep caskroom/cask >/dev/null || brew tap caskroom/cask; brew install brew-cask
    brew tap | grep caskroom/cask >/dev/null || brew install caskroom/cask/brew-cask
    brew tap | grep woowee/mycask >/dev/null || brew tap woowee/mycask

    execho "upgrade and update homebrew-cask..."
    brew upgrade brew-cask && brew cleanup && brew cask cleanup
    brew cask update

    execho "install apps using homebrew-cask..."
    brew cask install \
        "${app_alfred_brewname}" \
        "${app_chrome_brewname}" \
        "${app_macvim_brewname}" \
        "${app_iterm2_brewname}"
}

installby_diy()
{
    [ -e "${dir_tmp}" ] || mkdir -p "${dir_tmp}"

    installer "${app_macvim_name}" "${app_macvim_filename}" "${app_macvim_url}" "${dir_tmp}"
    installer "${app_alfred_name}" "${app_alfred_filename}" "${app_alfred_url}" "${dir_tmp}"
    installer "${app_chrome_name}" "${app_chrome_filename}" "${app_chrome_url}" "${dir_tmp}"
    installer "${app_iterm2_name}" "${app_iterm2_filename}" "${app_iterm2_url}" "${dir_tmp}"
}

installer()
{
    # arguments.check
    if [ $# -lt 3 ]; then
        execho "usage: \033[1minstall_application\033[0m \033[4mapp_name\033[0m \033[4mapp_filename(*.app)\033[0m \033[4murl\033[0m [\033[4mdir\033[0m]" 1>&2
        return 1
    fi
    # arguments.set
    app_name=$1
    app_filename=$2
    app_url=$3
    if [ $# -eq 4 ]; then
        dir_tmp=$4
    else
        dir_tmp="${HOME}/tmp_installation"
        mkdir -p ${dir_tmp}
    fi

    # existence check
    if check_existence_app "${app_filename}" path_app; then
        if ! ask_yesno "${app_name} has already been installed (${path_app}). Do you want to continue installation?"; then
            return 0
        fi
    fi

    execho "Installing \033[1;32m${app_name}\033[0m..."

    # get
    cd "${dir_tmp}"
    curl --location --remote-name "${app_url}"
    app_filepath="${HOME}/${dir_tmp}/${app_url##*/}"

    # expansion & install
    case "${app_url##*.}" in
    'zip')
        unzip -q "${app_filepath}"
        cp -a "${app_filename}" "/Applications"
        ;;
    'dmg')
        app_mount="/Volumes/${app_name}"
        hdiutil attach "${app_filepath}" -noidmereveal
        cp -a "${app_mount}/${app_filename}" "/Applications"
        hdiutil detach -force "${app_mount}"
        ;;
    esac
}
#
# } FUNCTIONS
#



#
# Installation
#
execho "Installing Apps..."
if installby_brew; then
    execho "Installed using brew-cask."
else
    if ask_yesno "Could not install app using brew-cask.\n${indent} Do yoo want to try again using curl and hdiutil/unzip commands?\n${indent} * notes: Apps will be installed into \`/Application\` not \`~/Application\` as brew-cask do."; then
        installby_diy
    fi
fi



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

    # MacVim > dein.vim
    curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
    sh ./installer.sh ~/.vim/dein
    # ref. https://github.com/Shougo/dein.vim#if-you-are-using-unixlinux-or-mac-os-x
else
    execho "Sorry, ${app_macvim_filename} was not found..."
fi



#fin
execho "${esc_ylw}DONE: App Installations and Some Settings${esc_off}"
