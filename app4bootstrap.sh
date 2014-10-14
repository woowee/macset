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
# Applications
#
app_macvim_name='MacVim-KaoriYa'
app_macvim_brewname='macvim-kaoriya'
app_macvim_filename='MacVim.app'
app_macvim_url='https://github.com/splhack/macvim/releases/download/20140107/macvim-kaoriya-20140107.dmg'

app_alfred_name="Alfred 2"
app_alfred_brewname="alfred"
app_alfred_filename="Alfred 2.app"
app_alfred_url='http://cachefly.alfredapp.com/Alfred_2.2_243b.zip'

app_chrome_name='Google Chrome'
app_chrome_brewname='google-chrome'
app_chrome_filename='Google Chrome.app'
app_chrome_url='https://dl.google.com/chrome/mac/stable/GGRM/googlechrome.dmg'


#
# FUNCTIONS {
#
installby_brew()
{
#   type brew >/dev/null 2>&1 || ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    type brew >/dev/null 2>&1 || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    # set PATH
    [ -e ${HOME}/.bashrc ] || touch ${HOME}/.bashrc
    echo "export PATH=/usr/local/bin:/usr/local/sbin:$PATH" > ${HOME}/.bashrc
    source ${HOME}/.bashrc
    execho "PATH: ${PATH}"

    brew update && brew upgrade

    # tap
    brew tap | grep caskroom/cask >/dev/null || brew tap caskroom/cask; brew install brew-cask
    brew tap | grep woowee/mycask >/dev/null || brew tap woowee/mycask

    # brew-cask
    brew upgrade brew-cask || true
    brew cask update

    brew cask install "${app_alfred_brewname}" "${app_chrome_brewname}" "${app_macvim_brewname}"
}

installby_diy()
{
    dir_tmp="${HOME}/tmp"
    [ -e "${dir_tmp}" ] || mkdir -p "${dir_tmp}"

    installer "${app_macvim_name}" "${app_macvim_filename}" "${app_macvim_url}" "${dir_tmp}"
    installer "${app_alfred_name}" "${app_alfred_filename}" "${app_alfred_url}" "${dir_tmp}"
    installer "${app_chrome_name}" "${app_chrome_filename}" "${app_chrome_url}" "${dir_tmp}"
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
        echo $?
        installby_diy
    fi
fi

#
# Settings
#
execho "Setting for the applications..."
# Terminal.app
defaults write com.apple.terminal "Default Window Settings" -string "Pro"
defaults write com.apple.terminal "Startup Window Settings" -string "Pro"

# MacVim.app + plugins
if check_existence_app ${app_macvim_filename}; then
    defaults write org.vim.MacVim "MMNativeFullScreen" -bool false

    # MacVim > Neobundle
    if ask_yesno "MacVim, Install the plugins ?"; then
        vimbundle="~/.vim/bundle"
        if [ -e ${HOME}/.vim ]; then
            mv ${HOME}/.vim "${HOME}/.vim~$(date '+%Y%m%d%H%M')"
        fi
        mkdir -p ~/.vim/bundle
        git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim

        vim -u ~/.vimrc -i NONE -c "try | NeoBundleUpdate! | finally | q! | endtry" -e -s -V1 &&:
        echo ""
    fi
fi

# Alfred.app
if check_existence_app "${app_alfred_filename}"; then
    open -a "${app_alfred_filename}"
    sleep 8 & echo "opening alfred 2. please wait ..."
    brew cask alfred link
fi


#fin
execho "${esc_ylw}DONE: App Installations and Some Settings${esc_off}"
