#!/bin/bash -eu
#
# @(#) macos4after-disabled-csrutil.sh
#
# Usage:
#   ./macos4after-disabled-csrutil.sh
#   (Don't need args.)
#
# Description:
#    This script configures settings of macOs.
#    All items to be set here, it is necessary to disable the System Integrity Protection (SIP).
#    Disable SIP before run this script.
#
# c.f.
#  - [Configuring System Integrity Protection](https://developer.apple.com/library/content/documentation/Security/Conceptual/System_Integrity_Protection_Guide/ConfiguringSystemIntegrityProtection/ConfiguringSystemIntegrityProtection.html)
###########################################################################

#
# PREPARE
#

# Check the status of SIP
checkStatus=$(csrutil status)
if [ "${checkStatus#*disabled}" = "$checkStatus" ]; then
  # "Should set SIP to disable."
  echo -e "SIP を無効にしてください．\n処理を中断します．"
  exit 1
fi

filename_func=$(dirname $0)/functions.sh

if [ ! -e ${filename_func} ]; then
    echo -e "\033[1;32m$(basename $0)==>\033[0m Cannot run because some necessary information or files is missing. Check your execution enviroment. (Is there '${filename_func}' ?)"
    exit 1
fi
source ${filename_func}



echo -e 'Input: 数字，記号はシングルバイトでの入力にする．'
#
# Store `PlistBuddy` path
#
# Expected Result:
#     pb=/usr/libexec/PlistBuddy

pb=$(mdfind -onlyin /usr/libexec -name Plistbuddy)

#
# And define the functions
#
function keyCheck {

  val=$("${pb}" -c "Print :keys:${1}:${2}:character" "${plistis}" 2>/dev/null || true)

  if [ "${val}" = "" ]; then
    sudo "${pb}" -c "Add :keys:${1}:${2}:character string ${3}" "${plistis}"
  else
    sudo "${pb}" -c "Set :keys:${1}:${2}:character ${3}" "${plistis}"
  fi
}

#
# Store `KeySetting_Default.plist` path
#
# Expected Result:
#     plistis=/System/Library/Input\ Methods/JapaneseIM.app/Contents/PlugIns/JapaneseIM.appex/Contents/Resources/KeySetting_Default.plist

echo "'locate' コマンドの準備 1/2; データベースの生成..."
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist &
wait
echo "...終了．"

echo "'locate' コマンドの準備 2/2; データベースを更新..."
sudo /usr/libexec/locate.updatedb &
wait
echo "...終了．"

plistis=$(sudo locate  "KeySetting_Default.plist" | grep "/System/.*/KeySetting_Default.plist$")
if [ -z "${plistis}" ]; then
  echo "'KeySetting_Default.plist' が見つかりませんでした。スキップしました。"
else
  # back up the original plist file
  [ ! -e ${HOME}/temp ] && mkdir ${HOME}/temp
  sudo cp -f "${plistis}" "${HOME}/temp/KeySetting_Default.plist~$(date '+%Y%m%d%H%M')"

  sudo "${pb}" -c "Set :keys:before_typing:\'' \'':command 'direct_input'" "${plistis}"  # 　   space
  keyCheck "before_typing" "\'' \''" "' '"
  sudo "${pb}" -c "Set :keys:*:\''|\'':character '|'" "${plistis}"              # ｜   vertical bar
  sudo "${pb}" -c "Set :keys:*:\''\!\'':character '\!'" "${plistis}"            # ！   exclamation
  sudo "${pb}" -c "Set :keys:*:\''"'\"'"\'':character '"'\"'"'" "${plistis}"    # ”   double quotation
  sudo "${pb}" -c "Set :keys:*:\''#\'':character '#'" "${plistis}"              # ＃   sharp
  sudo "${pb}" -c "Set :keys:*:\''$\'':character '$'" "${plistis}"              # ＄   dollar
  sudo "${pb}" -c "Set :keys:*:\''%\'':character '%'" "${plistis}"              # ％   percent
  sudo "${pb}" -c "Set :keys:*:\''&\'':character '&'" "${plistis}"              # ＆   ampersand
  sudo "${pb}" -c "Set :keys:*:\''\'\'':character '\''" "${plistis}"            # ’   apostrophe(single quotation)
  sudo "${pb}" -c "Set :keys:*:\''(\'':character '('" "${plistis}"              # （） parentheses
  sudo "${pb}" -c "Set :keys:*:\'')\'':character ')'" "${plistis}"
  sudo "${pb}" -c "Set :keys:*:\''*\'':character '*'" "${plistis}"              # ＊   asterisk
  sudo "${pb}" -c "Set :keys:*:\''+\'':character '+'" "${plistis}"              # ＋   plus
  sudo "${pb}" -c "Set :keys:*:\''\:\'':character ':'" "${plistis}"             # ：   colon
  sudo "${pb}" -c "Set :keys:*:\'';\'':character ';'" "${plistis}"              # ；   semicolon
  sudo "${pb}" -c "Set :keys:*:\''<\'':character '<'" "${plistis}"              # ＜＞ angle bracket
  sudo "${pb}" -c "Set :keys:*:\''>\'':character '>'" "${plistis}"
  sudo "${pb}" -c "Set :keys:*:\''=\'':character '='" "${plistis}"              # ＝   equals
  sudo "${pb}" -c "Set :keys:*:\''?\'':character '?'" "${plistis}"              # ？   question
  sudo "${pb}" -c "Set :keys:*:\''@\'':character '@'" "${plistis}"              # ＠   at
  sudo "${pb}" -c "Set :keys:*:\''^\'':character '^'" "${plistis}"              # ＾   caret
  sudo "${pb}" -c "Set :keys:*:\''_\'':character '_'" "${plistis}"              # ＿   underscore
  sudo "${pb}" -c "Set :keys:*:\''\`\'':character '\`'" "${plistis}"            # ‘   back quote
  keyCheck "before_typing" "\''/\''" "'/'"                                      # ／ slash (solidus)
  keyCheck "typing" "\''/\''" "'/'"
  keyCheck "before_typing" "\''\\\\\''" "'\\\'"                                 # ＼ backslash (reverse solidus)
  keyCheck "typing" "\''\\\\\''" "'\\\'"
fi


echo -e 'Finder: フォルダの名称は、英語表記．'
sudo mv \
    /System/Library/CoreServices/SystemFolderLocalizations/ja.lproj/SystemFolderLocalizations.strings \
    /System/Library/CoreServices/SystemFolderLocalizations/ja.lproj/SystemFolderLocalizations.strings.org
sudo cp -f \
  /System/Library/CoreServices/SystemFolderLocalizations/en.lproj/SystemFolderLocalizations.strings \
  /System/Library/CoreServices/SystemFolderLocalizations/ja.lproj/



echo -e 'Time Machine: Time Machine の設定．'
sudo tmutil addexclusion \
  "/Applications" \
  "/Library" \
  "/Network" \
  "/System" \
  "/Users/Guest" \
  "/Users/Shared" \
  "/Volumes" \
  "/bin" \
  "/cores" \
  "/etc" \
  "/installer.failurerequests" \
  "/opt" \
  "/private" \
  "/sbin" \
  "/tmp" \
  "/usr" \
  "/var" \

sudo tmutil addexclusion \
  "${HOME}/Applications" \
  "${HOME}/Desktop" \
  "${HOME}/Dropbox" \
  "${HOME}/Library"
  # "${HOME}/Public" \
  # "${HOME}/temp" \

#対象外の確認: mdfind "com_apple_backup_excludeitem = 'com.apple.backupd'"
#対象外の確認: ls -l@

# TODO:
# tmutil destinationinfo

#Time Machine target items are;
#  * ${HOME}/Documents
#  * ${HOME}/Downloads
#  * ${HOME}/Music
#  * ${HOME}/Pictures
#  * ${HOME}/Movies

