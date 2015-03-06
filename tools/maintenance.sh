#!/bin/bash -u

set -e

# arg check

# constants
esc='\033[1;32m'
esc_off='\033[0m'
msg_display="$esc$0==>$esc_off"

# functions
ask_yn()
{
    choice="[y/n]"

    msg=$1
    msg_display=$msg
    while true; do
        printf "${msg_display}"
        read res

        case "$res" in
            [yY]) ret=0; return 0;;
            [nN]) ret=1; return 1;;
            *)
                echo "Can't read your enter. try again."
                ask_yn "${msg}"
                return 0;;
        esac
    done
}

##
# process
#

# open
# open -a Terminal

case $1 in
    [rR]) msgis="${msg_display} Do you want to reboot your Mac for maintenance ?";;
    [pP]) msgis="${msg_display} Do you want to run Repair Disk Permissions ?";;
    [sS]) msgis="${msg_display} Do you want to boot your Mac into Safe mode ?\n${msg_display} NOTE: You must reboot again to change ";;
    *) echo "An internal error has occured."; return 1;;
esac



if ask_yn "$msgis"; then
    case $1 in
        [rR])
            # Reboot
            echo "sudo shutdown +r now";;
        [pP])
            # Repair Disk Permission
            echo "diskutil repairPermissions /";;
        [sS])
            # Reboot into Safe Mode
            echo 'sudo nvram boot-args="-x -v"';;
        *) echo "An internal error has occured."; return 1;;
    esac
fi

