#!/bin/bash -eu
#
# @(#) bootstrap.sh ver.1.0.0 ver.0.0.0 2014.05.18
#
# Usage:
#   bootstrap.sh [mode]
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
  local esc_reset='${ESC_OFF}'

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
# config
#
computername_is=${COMPUTERNAME}
hostname_is=${HOSTNAME}
localhostname_is=${LOCALHOSTNAME}

# readonly MyGITHUB_USERNAME="${GITHUB_USERNAME}"
# readonly MyGITHUB_EMAIL="${GITHUB_EMAIL}"



sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#
# Systen Settings
#
generate_title "System Information"
if ask_yesno "Do you want to set the system information ?"; then

  while true; do
    cat << DATA

    - Computer Name   : ${computername_is}
    - Hostname        : ${hostname_is}.local
    - Local Host Name : ${localhostname_is}

DATA

    printf "${PREFIX} Are you sure you want to set system information with the above content ? [a(Apply)/r(Redo)/x(eXit this work.)]: "

    read res

    case "${res}" in
      a)
        break
        ;;
      r)
        echo -e "\n  Enter your system information.;"
        ask_inputvalue "      Enter your computer name   : " computername_is
        ask_inputvalue "      Enter your hostname        : " hostname_is
        ask_inputvalue "      Enter your local host name : " localhostname_is
        ;;
      x)
        exit 1
        ;;
      *)
        myecho "Can't read your enter. try again."
        ;;
    esac
  done

  sudo scutil --set ComputerName "${computername_is}"
  sudo scutil --set HostName "${hostname_is}.local"
  sudo scutil --set LocalHostName "${localhostname_is}"

  myecho "${ESC_YLW}DONE: System/Account Information Settings${ESC_OFF}"
fi



#
# Generating SSH Keys for Github
#
generate_title "GitHub"
ask_yesno "Do you want to generate a SSH key for GitHub ?" && $(dirname $0)/github.sh



#
# Dotfiles
#
generate_title "Dotfiles"
ask_yesno "Do you want to clone dotfiles ?" && $(dirname $0)/dotfiles.sh



#
# OSX Settings
#
generate_title "macOS Settings"
ask_yesno "Do you want to set macOS system ?" && $(dirname $0)/macos.sh ${MODE_MINIMAL}



#
# Applications
#
generate_title "Install Minimal Applications"
ask_yesno "Do you want to install applications, alfred, chrome, dropbox, and macvim-kaoriya ?" && $(dirname $0)/app.sh ${MODE_MINIMAL}


## Please restart
cat << END


**************************************************
           THE PROCESS BEEN COMPLETED.

   You Should RESTART to activate the settings.
     (c.g., [Command] + [Control] + [EJECT])
**************************************************


END
