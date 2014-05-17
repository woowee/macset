#!/bin/bash -u

set -e

#sudo -v
#while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

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
MyGITHUB_USERNAME="${GITHUB_USERNAME}"
MyGITHUB_EMAIL="${GITHUB_EMAIL}"

# read functions
source ${dir_current}/${filename_func}


#
# FUNCTIONS {
#
set_githubaccountinfo()
{
    ask_inputvalue "  Enter your Github user name                     : " MyGITHUB_USERNAME
    ask_inputvalue "  Enter your email address registered with Github : " MyGITHUB_EMAIL
    echo ""
}
confirm_githubaccountinfo()
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
                execho "Tell me your information of Github."
                set_githubaccountinfo

                execho "Check the contents ..."
                execho "  - User Name       : ${MyGITHUB_USERNAME}"
                execho "  - E-mail address  : ${MyGITHUB_EMAIL}"
                echo ""
                confirm_githubaccountinfo "${msg}"
                return 0;;
            x)
                return 1;;
            *)
                echo "I can note read your input..."
                confirm_githubaccountinfo "${msg}"
                return 0;;
        esac
    done
}

#
# } FUNCTIONS
#


#
# Generating SSH Keys for Github
#

MySSH_KEYNAME="github_rsa"
MySSH_FILE="${HOME}/.ssh/${MySSH_KEYNAME}"

cat << DATA
Check the contents ...
  - User Name       : ${MyGITHUB_USERNAME}
  - E-mail address  : ${MyGITHUB_EMAIL}

DATA

confirm_githubaccountinfo "Are you sure want to set using above infomation for your GitHub?"

# generating
ssh-keygen -t rsa -f ${MySSH_FILE} -C "${MyGITHUB_EMAIL}"
# save the key (/c/Users/you/.ssh/id_rsa): ${HOME}/.ssh/github_rsa

# % Enter passphrase (empty for no passphrase): *****
# % Enter same passphrase again: *****

# add your new key to the ssh-agent
ssh-add ${MySSH_FILE}

# Copies the contents of the id_rsa.pub file to your clipboard
pbcopy < "${MySSH_FILE}.pub"
sudo chmod 600 "${MySSH_FILE}.pub"    # just in case...'

echo ""
execho "ok, now open browser, \033[1;4;32m\"Safari\"\033[0m just now ?"
ask_confirm "you should register your ssh pub key to your account settings of github.\n"

execho "opening Safari ..."
open -a Safari "https://github.com/settings/ssh"

execho "when you finish settings it, then type '\033[1;4mdone\033[0m'.;"
while true; do
    read res
    if [ "${res}" == "done" ]; then
        break
    else
        execho "finish settings? so type 'done'."
    fi
done

# make config file
cat << EOF > "${HOME}/.ssh/config"
Host github.com
Hostname github.com
Identityfile ${MySSH_FILE}
EOF

#
ssh -T git@github.com &&:

# Are you sure you want to continue connecting (yes/no)?
#
# Hi username! You've successfully authenticated, but GitHub does not provide shell access.

# to set your account's default identity.
# Omit --global to set the identity only in this repository.
git config --global user.name "${MyGITHUB_USERNAME}"
git config --global user.email "${MyGITHUB_EMAIL}"


#fin
execho "${esc_ylw}DONE: SSH Keys for Github Generating${esc_off}"