#!/bin/bash -eu
#
# @(#) github.sh ver.0.0.0 2014.05.18
#
# Usage:
#   github.sh
#     arg1 - なし
#
# Description:
#   github のアカウント設定を行う．
#
#
# references:
# - https://help.github.com/articles/checking-for-existing-ssh-keys/
# - https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
###########################################################################

#
# PREPARE
#

# Check the files required for this process
readonly FILE_FUNC="$(dirname $0)/functions.sh"
readonly FILE_CONF="$(dirname $0)/configurations.sh"

function check_files() {
  local esc_red='\033[0;31m'
  local esc_reset='\033[0m'
  # local esc_reset=`tput sgr0`

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
# Confirmation start
#
echo -e "
                                Github
----------------------------------------------------------------------
"
if ! ask_yesno "Do you generate a SSH key for GitHub ?" ; then
  myecho "This process been canceled."
  exit 1
fi



# read configuraton
username_is="${GITHUB_USERNAME}"
email_is="${GITHUB_EMAIL}"



#
# Generating SSH Keys for Github
#

readonly SSHKEY_NAME="github_rsa"
readonly SSHKEY_FILE="${HOME}/.ssh/${SSHKEY_NAME}"

# account infomation
while true; do
  cat << DATA

    - User Name       : ${username_is}
    - E-mail address  : ${email_is}

DATA

    printf "${PREFIX} Are you sure you want to set your GitHub account with the above content ? [a(Apply)/r(Redo)/x(eXit this work.)]: "

    read res

    case "${res}" in
      a)
        break
        ;;
      r)
        echo -e "\n  Enter your GitHub account.;"
        ask_inputvalue "      Enter your user name      : " username_is
        ask_inputvalue "      Enter your e-mail address : " email_is
        ;;
      x)
        exit 1
        ;;
      *)
        myecho "Can't read your enter. try again."
        ;;
    esac
  done


[ ! -e ${HOME}/.ssh ] && mkdir -p ${HOME}/.ssh

# generating
# ssh-keygen -t rsa -b 4096 -f ${SSHKEY_FILE} -C "${email_is}"
expect -c "
  spawn ssh-keygen -t rsa -b 4096 -f ${SSHKEY_FILE} -C ${email_is}
  expect \"Enter passphrase (empty for no passphrase):\"
  send \"${GITHUB_PASSWORD}\n\"
  expect \"Enter same passphrase again:\"
  send \"${GITHUB_PASSWORD}\n\"
  interact
"


# start the ssh-agent in the background
# eval $(ssh-agent -s)

# add your new key to the ssh-agent
# ssh-add ${SSHKEY_FILE}
expect -c "
  spawn ssh-add ${SSHKEY_FILE}
  expect \"Enter passphrase for ${SSHKEY_FILE}:\"
  send \"${GITHUB_PASSWORD}\n\"
  interact
"

# Copies the contents of the id_rsa.pub file to your clipboard
pbcopy < "${SSHKEY_FILE}.pub"
sudo chmod 600 "${SSHKEY_FILE}.pub"    # just in case...'

echo ""
myecho "ok, now open browser ${ESC_REVS}\"Safari\"${ESC_OFF}."
ask_confirm "
  you should register your ssh pub key to your account settings of github.\n \
  when you finish settings it, then type '${ESC_UNDR}done${ESC_OFF}'.;"

open -a Safari "https://github.com/settings/ssh" &
pid=$!
wait ${pid}

while true; do
    read res
    if [ "${res}" == "done" ]; then
        break
    else
        myecho "finish settings? so type 'done'."
    fi
done
# Are you sure you want to continue connecting (yes/no)?
# make config file
cat << EOF > "${HOME}/.ssh/config"
Host github github.com
  Hostname github.com
  Identityfile ${SSHKEY_FILE}
  User git
EOF

cat << EOF >> "${HOME}/.gitconfig"
[url "github:"]
    InsteadOf = https://github.com/
    InsteadOf = git@github.com:
EOF

# test!
ssh -T git@github.com &&:


# to set your account's default identity.
# Omit --global to set the identity only in this repository.
git config --global user.name "${username_is}"
git config --global user.email "${email_is}"


# fin
echo -e "

----------------------------------------------------------------------
                     Process has been completed.



"

