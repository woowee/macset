#!/bin/bash -u

set -e
#
# PREPARE
#

filename_func=$(dirname $0)/functions.sh

if [ ! -e ${filename_func} ]; then
    echo -e "\033[1;32m$(basename $0)==>\033[0m Cannot run because some necessary information or files is missing. Check your execution enviroment. (Is there '${filename_func}' ?)"
    exit 1
fi
source ${filename_func}

case $1 in
  "-s" | "-y" | "--silent" | "silent" )
    echo "Running in silent mode..."
    auto=Y
    shift 1
    ;;
  *)
    auto=N
    if [ ! -t 0 ]; then
      echo "Interactive mode needs terminal!" >&2
      exit 1
    fi
    ;;
esac

function ask {
  while true; do

    if [ "$2" == "Y" ]; then
      prompt="\033[1;32mY\033[0m/n"
      default=Y
    elif [ "$2" == "N" ]; then
      prompt="y/\033[1;32mN\033[0m"
      default=N
    else
      prompt="y/n"
      default=
    fi

    printf "$prefix $1 [$prompt] "

    yn=""
    if [ "$auto" == "Y" ]; then
      echo
    else
      read yn
    fi

    if [ -z "$yn" ]; then
      yn=$default
    fi

    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
    esac
  done
}

if ask 'Input: 数字，記号はシングルバイトでの入力にする．' Y; then
    pb=/usr/libexec/PlistBuddy
    plistis=/System/Library/Input\ Methods/JapaneseIM.app/Contents/Resources/KeySetting_Default.plist

    function keyCharExistence {

      val=$("${pb}" -c "Print :keys:${1}:${2}:character" "${plistis}" 2>/dev/null || true)

      if [ "${val}" = "" ]; then
        # echo "add"
        "${pb}" -c "Add :keys:${1}:${2}:character string ${3}" "${plistis}"
      else
        # echo "set(modify)"
        "${pb}" -c "Set :keys:${1}:${2}:character ${3}" "${plistis}"
      fi
    }

    sudo cp -f "${plistis}" "$HOME/KeySetting_Default.plist.org"

    sudo "${pb}" -c "Set :keys:before_typing:\'' \'':character ' '" "${plistis}" # 　   space
    #sudo "${pb}" -c "Set :keys:*:\''-\'':character '-'" "${plistis}"            # －   minus
    #sudo "${pb}" -c "Set :keys:*:\''[\'':character '['" "${plistis}"            # 「」 bracket
    #sudo "${pb}" -c "Set :keys:*:\'']\'':character ']'" "${plistis}"
    sudo "${pb}" -c "Set :keys:*:\''|\'':character '|'" "${plistis}"             # ｜   vertical bar
    sudo "${pb}" -c "Set :keys:*:\''\!\'':character '\!'" "${plistis}"           # ！   exclamation
    sudo "${pb}" -c "Set :keys:*:\''"'\"'"\'':character '"'\"'"'" "${plistis}"   # ”   double quotation
    sudo "${pb}" -c "Set :keys:*:\''#\'':character '#'" "${plistis}"             # ＃   sharp
    sudo "${pb}" -c "Set :keys:*:\''$\'':character '$'" "${plistis}"             # ＄   dollar
    sudo "${pb}" -c "Set :keys:*:\''%\'':character '%'" "${plistis}"             # ％   percent
    sudo "${pb}" -c "Set :keys:*:\''&\'':character '&'" "${plistis}"             # ＆   ampersand
    sudo "${pb}" -c "Set :keys:*:\''\'\'':character '\''" "${plistis}"           # ’   apostrophe(single quotation)
    sudo "${pb}" -c "Set :keys:*:\''(\'':character '('" "${plistis}"             # （） parentheses
    sudo "${pb}" -c "Set :keys:*:\'')\'':character ')'" "${plistis}"
    sudo "${pb}" -c "Set :keys:*:\''*\'':character '*'" "${plistis}"             # ＊   asterisk
    sudo "${pb}" -c "Set :keys:*:\''+\'':character '+'" "${plistis}"             # ＋   plus
    sudo "${pb}" -c "Set :keys:*:\''\:\'':character ':'" "${plistis}"            # ：   colon
    sudo "${pb}" -c "Set :keys:*:\'';\'':character ';'" "${plistis}"             # ；   semicolon
    sudo "${pb}" -c "Set :keys:*:\''<\'':character '<'" "${plistis}"             # ＜＞ angle bracket
    sudo "${pb}" -c "Set :keys:*:\''>\'':character '>'" "${plistis}"
    sudo "${pb}" -c "Set :keys:*:\''=\'':character '='" "${plistis}"             # ＝   equals
    sudo "${pb}" -c "Set :keys:*:\''?\'':character '?'" "${plistis}"             # ？   question
    sudo "${pb}" -c "Set :keys:*:\''@\'':character '@'" "${plistis}"             # ＠   at
    sudo "${pb}" -c "Set :keys:*:\''^\'':character '^'" "${plistis}"             # ＾   caret
    sudo "${pb}" -c "Set :keys:*:\''_\'':character '_'" "${plistis}"             # ＿   underscore
    sudo "${pb}" -c "Set :keys:*:\''\`\'':character '\`'" "${plistis}"           # ‘   back quote
    keyCharExistence "before_typing" "\''/\''" "'/'"                             # ／ slash (solidus)
    keyCharExistence "typing" "\''/\''" "'/'"
    keyCharExistence "before_typing" "\''\\\\\''" "'\\\'"                        # ＼ backslash (reverse solidus)
    keyCharExistence "typing" "\''\\\\\''" "'/'"
fi

if ask 'Finder: フォルダの名称は、英語表記．' Y; then
    sudo mv \
        /System/Library/CoreServices/SystemFolderLocalizations/ja.lproj/SystemFolderLocalizations.strings \
        /System/Library/CoreServices/SystemFolderLocalizations/ja.lproj/SystemFolderLocalizations.strings.org
   sudo cp -f \
      /System/Library/CoreServices/SystemFolderLocalizations/en.lproj/SystemFolderLocalizations.strings \
      /System/Library/CoreServices/SystemFolderLocalizations/ja.lproj/
fi

