#!/bin/bash -u

set -e

# arg check
modeis=0
msg_err="usage: $0 [--silent|\s]"
if [ $# -eq 1 ]; then
    if [ $1 = "--silent" -o $1 = "-s" ]; then
        modeis=1
    else
        echo "${msg_err}" 1>&2
    fi
elif [ $# -ge 2 ]; then
    echo "${msg_err}" 1>&2
fi

# confirm
msg_confirm="Are you sure you want to set Japanese localization for Gimp? [o(OK)/c(Cancel)]"
if [ "${modeis}" -eq 0 ]; then
    while true; do
        printf "${msg_confirm}"
        read res

        case ${res} in
            [Oo]*) break;;
            [Cc]*) exit;;
            *)
                echo "Can't read your enter. try again."
                continue
        esac
    done
fi

# Gimp.app (lisanet)
urlis="http://cznic.dl.sourceforge.net/project/gimponosx/GIMP%20Mavericks/Gimp-2.8.10p2-Mavericks.dmg"


# check the exsitence of GIMP.app
path_gimp=$(mdfind -onlyin '/opt' 'kMDItemContentTypeTree == "com.apple.application" && kMDItemFSName == "gimp.app"c')
if [ -z "${path_gimp}" ]; then
    echo "error: there is no GIMP.app" 1>&2
    exit 1
fi


# get Gimp lisanet version
cd ${HOME}/Downloads
curl --location --remote-name "${urlis}"
# expand and get path of the volume
lisanetgimpis=$(hdiutil attach $(mdfind -onlyin $(pwd) -name ${urlis##*/}) -noidmereveal | grep -i "^/dev/.*Apple_HFS" | awk -F $'\t' '{print $3}')

# copy lang files
cp -fR "${lisanetgimpis}/Gimp.app/Contents/Resources/share/locale/ja" "${path_gimp}/Contents/Resources/share/locale"

# modify gimp file and move to a target line
msg_confirm=$(cat <<END

You must modify the setting file to activate the localization changes.
The setting file was opened now, so you modify 'APP=name' to 'APP=\"gimp20\"'
and then save and close with ':wq'
END
)
if [ "${modeis}" -eq 0 ]; then
    while true; do
        # just wait user's response hitting enter key.
        printf "${msg_confirm} (tap [enter] key)"
        read res

        if [ ${res} ]; then
            execho "Sorry, please hit [enter] key."
            continue
        fi
        break
    done
    vim "${path_gimp}/Contents/MacOS/GIMP" +"/^APP=name"
else
    sleep 3
    # silentmode
    vim --noplugin "${path_gimp}/Contents/MacOS/GIMP" +":%s/^APP=name/APP=\"gimp20\"/g" +":wq"
fi

# dettach & remove .dmg
hdiutil detach "${lisanetgimpis}"; rm $(mdfind -onlyin $(pwd) -name ${urlis##*/})

# open GIMP.app
open -a ${path_gimp} && echo -e "\033[1;32mITS DONE.\033[0m"
