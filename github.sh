#!/bin/bash -eu
#
# @(#) github.sh ver.0.0.0 2014.05.18
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
      処理に必要なファイル「$1」がありません。 \
      「${1##*/}」の中に対象のファイルがあるか確認してください。 \
      処理を中断します。
      exit 1
  fi

  # read
  if ! source ${file_is}; then
    echo -e $(basename $0)\)  ${esc_red}ERROR: ${esc_reset} \
      ファイル「$(basename $1)」を読み込めませんでした。 \
      ファイルが壊れているか、内容が正しくない可能性があります。 \
      処理を中断します。
    exit 1
  fi
}

check_files $FILE_FUNC
check_files $FILE_CONF

[ ! -e ${DIR_TEMP} ] && mkdir -p ${DIR_TEMP}

get_mode $@
# echo "Mode is $MODE_IS."


#
#################################### GitHub ####################################
#
if ! when_its_starting \
      "GitHub" \
      "GitHub アカウントを作成します。よろしいですか？" \
      "$(ps h -o command= $PPID)" \
      "$(basename $(echo $SHELL))"; then
  exit 1
fi



# read configuraton
readonly USERNAME="${GITHUB_USERNAME}"  # from  $FILE_CONF (configurations.sh)
readonly EMAIL="${GITHUB_EMAIL}"        # from  $FILE_CONF (configurations.sh)

readonly SSHKEY_NAME="${GITHUB_SSHKEY_NAME:-id_rsa}"
readonly SSHKEY_FILEPATH_PRIVATE="${HOME}/.ssh/${SSHKEY_NAME}"


# account infomation
while true; do
  cat << DATA

    - User Name       : ${USERNAME}
    - E-mail address  : ${EMAIL}

DATA

    printf "${PREFIX}この GitHub アカウントで SSH Key を作成します。よろしいですか？ [a(適用)/r(変更)/x(中止)]: "

    read res

    case "${res}" in
      a)
        break
        ;;
      r)
        echo -e "\nGitHub アカウントを入力してください。;"
        ask_inputvalue "      Enter your user name      : " USERNAME
        ask_inputvalue "      Enter your e-mail address : " EMAIL
        ;;
      x)
        exit 1
        ;;
      *)
        myecho "入力したキーが正しくありません。入力し直してください。"
        ;;
    esac
  done


#
# CHECKING FOR EXISTING SSH KEYS
#
if [ ! -e ${SSHKEY_FILEPATH_PRIVATE%/*} ]; then
  mkdir -p ${SSHKEY_FILEPATH_PRIVATE%/*}
fi

if [ -e ${SSHKEY_FILEPATH_PRIVATE} ]; then
  if ask_yesno "「${SSHKEY_FILEPATH_PRIVATE}」は既にあるようです。\nこのまま処理を続けてもよろしいですか？"; then
    mv "${SSHKEY_FILEPATH_PRIVATE}" "${SSHKEY_FILEPATH_PRIVATE}~$(date '+%Y%m%d%H%M')"
  else
    exit 1
  fi
fi



#
# GENERATING A NEW SSH KEY AND ADDING IT TO THE SSH-AGENT
#

# generating
# ssh-keygen -t rsa -b 4096 -f ${SSHKEY_FILE} -C "${EMAIL}"
expect -c "
  spawn ssh-keygen -t rsa -b 4096 -C "${EMAIL}"
  expect \"Enter file in which to save the key (${SSHKEY_FILEPATH_PRIVATE}):\"
  send \"${SSHKEY_FILEPATH_PRIVATE}\n\"
  expect \"Enter passphrase (empty for no passphrase):\"
  send \"${GITHUB_PASSWORD}\n\"
  expect \"Enter same passphrase again:\"
  send \"${GITHUB_PASSWORD}\n\"
  interact
"

# start the ssh-agent in the background
eval "$(ssh-agent -s)"
sleep 1


# incantation to automatically load keys into the ssh-agent (by AddKeysToAgent)
# and store the passphrase into keychain (by UseKeychain)
cat << EOF > "${HOME}/.ssh/config"
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ${SSHKEY_FILEPATH_PRIVATE}
EOF


# add your new key to the ssh-agent
# ssh-add -K ${SSHKEY_FILE}
expect -c "
  spawn ssh-add -K ${SSHKEY_FILEPATH_PRIVATE}
  expect \"Enter passphrase for ${SSHKEY_FILEPATH_PRIVATE}:\"
  send \"${GITHUB_PASSWORD}\n\"
  interact
"



#
# ADDING A NEW SSH KEY TO THE GITHUB ACCOUNT
#

# Copies the contents of the id_rsa.pub file to your clipboard
pbcopy < "${SSHKEY_FILEPATH_PRIVATE}.pub"
chmod 600 "${SSHKEY_FILEPATH_PRIVATE}.pub"    # just in case...'

echo ""
myecho "Web ブラウザ ${ESC_REVS}\"Safari\"${ESC_OFF} を開き、GitHub へアクセスします。"
ask_confirm "
アカウントページの [Settings] ページの [SSH and GPG keys] で、生成したキーを追加してください。\n \
終わったらこのターミナルに戻り、'${ESC_UNDR}done${ESC_OFF}' と入力してください。\n \
接続テストを行います。;"

open -a Safari "https://github.com/settings/ssh" &
pid=$!
wait ${pid}

while true; do
  read res
  if [ "${res}" == "done" ]; then
      break
  else
      myecho "追加したら、'done' と入力してください。"
  fi
done


# test!
ssh -T git@github.com &&:


# to set your account's default identity.
# Omit --global to set the identity only in this repository.
git config --global user.name "${USERNAME}"
git config --global user.email "${EMAIL}"


# fin
echo -e "

----------------------------------------------------------------------
                           終了しました。



"
