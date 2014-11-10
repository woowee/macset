#!/bin/bash -u

set -e

dir_current=$(dirname $0)
cd ${dir_current}

#
# check file configration
#
filename_conf="config.sh"
filename_func="functions.sh"

filename_check="check4running.sh"
if [ ! -e "${dir_current}/${filename_check}" ]; then
    echo -e "\033[1;32m$(basename $0)==>\033[0m Cannot run because some necessary information or files is missing. Check your execution enviroment. (Is there '${dir_current}/${filename_check}' ?)"
    exit 1
fi

${dir_current}/${filename_check} ${filename_conf} ${filename_func}

# read configuraton
source ${dir_current}/${filename_conf}
MyCOMPUTERNAME="${COMPUTERNAME}"
MyHOSTNAME="${HOSTNAME}"
MyLOCALHOSTNAME="${LOCALHOSTNAME}"

MyGITHUB_USERNAME="${GITHUB_USERNAME}"
MyGITHUB_EMAIL="${GITHUB_EMAIL}"

# read functions
source ${dir_current}/${filename_func}


#
# FUNCTIONS {
#
## Computer Account
set_systeminfo()
{
    ask_inputvalue "  Enter your computer name   : " MyCOMPUTERNAME
    ask_inputvalue "  Enter your hostname        : " MyHOSTNAME
    ask_inputvalue "  Enter your local host name : " MyLOCALHOSTNAME
    echo ""
}
confirm_systeminfo()
{
    choice="[a(Apply)/r(Redo)/x(eXit this work.)] : "
    msg="$1"

    msg_display="${prefix} ${msg} ${choice}"
    while true; do
        printf "${msg_display}"
        read res

        case "${res}" in
            a) return 0;;
            r)
                execho "Set your system information."
                set_systeminfo

                execho "Check the contents ..."
                execho "  - Computer Name   : ${MyCOMPUTERNAME}"
                execho "  - Hostname        : ${MyHOSTNAME}.local"
                execho "  - Local Host Name : ${MyLOCALHOSTNAME}"
                echo ""
                confirm_systeminfo "${msg}"
                return 0;;
            x)
                return 1;;
            *)
                execho "I can not read your input..."
                confirm_systeminfo "${msg}"
        esac
    done
}
#
# } FUNCTIONS
#


sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#
# Systen Settings
#
echo -e "\033[1m######################### System Information #########################\033[0m"
if ask_yesno "Do you want to set the system information ?"; then

    cat << DATA
Check the contents ... ;
  - Computer Name   : ${MyCOMPUTERNAME}
  - Hostname        : ${MyHOSTNAME}.local
  - Local Host Name : ${MyLOCALHOSTNAME}

DATA
    confirm_systeminfo "Are you sure want to set using above infomation?"

    sudo scutil --set ComputerName "${MyCOMPUTERNAME}"
    sudo scutil --set HostName "${MyHOSTNAME}.local"
    sudo scutil --set LocalHostName "${MyLOCALHOSTNAME}"

    #fin
    execho "${esc_ylw}DONE: System/Account Information Settings${esc_off}"
fi



#
# Generating SSH Keys for Github
#
echo -e "\033[1m############################### GitHub ###############################\033[0m"
ask_yesno "Do you generate a SSH key for GitHub ?" && ./github.sh



#
# Dotfiles
#
echo -e "\033[1m############################## Dotfiles ##############################\033[0m"
ask_yesno "Do you want to clone dotfiles ?" && ./dotfiles.sh



#
# OSX Settings
#
echo -e "\033[1m############################ OSX Settings ############################\033[0m"
ask_confirm "Sets OSX defaults."; ./osx4bootstrap.sh --silent


#
# Applications
#
echo -e "\033[1m######################## Install Applications ########################\033[0m"
ask_yesno "Do you want to install applications, alfred, chrome, and macvim-kaoriya ?" && ./app4bootstrap.sh


## Please restart
cat << END


**************************************************
               NOW IT'S DONE.

   You Should RESTART to activate the settings.
     (c.g., [Command] + [Control] + [EJECT])
**************************************************


END
