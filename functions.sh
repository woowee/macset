#!/bin/bash -eu
#
# @(#) functions.sh ver.0.0.0 2014.05.18
#
# Usage:
#   (source function.sh)
#
# Description:
#   各シェルスクリプトで共有する定数や関数を定義．
#
###########################################################################


#
# 定数
#

readonly IAM=$(basename $0)
readonly PREFIX="$IAM) "

# Color and format of text
readonly ESC_GRM='\033[1;32m'
readonly ESC_YLW='\033[0;33m'
readonly ESC_RED='\033[0;31m'
readonly ESC_UNDR='\033[4m'
readonly ESC_BOLD='\033[1m'
readonly ESC_REVS='\033[7m'
readonly ESC_OFF='\033[0m'
# ref.https://gist.github.com/brandonb927/3195465#file-osx-for-hackers-sh-L12

# モード
readonly MODE_MINIMAL=0
readonly MODE_COMPLETE=1

myecho()
{
    echo -e "${PREFIX} $1"
}

myecho_error()
{
    echo -e "${PREFIX} ${ESC_RED}ERROR:${ESC_OFF} $1"
}

get_mode() {
  local n=-1

  case $# in
    0) n=$MODE_COMPLETE ;;
    1)
      case $1 in
        0) n=$MODE_MINIMAL ;;
        1) n=$MODE_COMPLETE ;;
        *) n=-1 ;;
      esac
      ;;
    *) n=-1 ;;
  esac

  if [ $n -eq -1 ]; then
    myecho_error Argument is incurrect. \
      You can specify argument is 0 \(as \"minimal\"\) or 1 \(as \"complete\"\). \
      Process will be canceled.
    exit 1
  fi

  readonly MODE_IS=$n

}



ask_confirm()
{
    local msg="$1"
    local msg_display="${PREFIX} ${msg}"
    while true; do
        # just wait user's response hitting enter key.
        printf "${msg_display} (tap [enter] key)"
        read res

        if [ ${res} ]; then
            myecho "Sorry, please use [enter] key."
            ask_confirm "${msg}"
        fi
        return 0
    done
}

ask_yesno()
{
    # yes/no
    local choice="[y(Yes)/n(No)] : "

    local msg="$1"
    local msg_display="${PREFIX} ${msg} ${choice}"
    while true; do
        printf "${msg_display}"
        read res

        case ${res} in
            [Yy]*) return 0;;
            [Nn]*) return 1;;
            *)
                myecho "Can't read your enter. try again."
                ask_yesno "${msg}"
        esac
    done
}

ask_inputvalue()
{
    while true; do
        printf "$1"
        read res

        eval $2="\"${res}\""    # $2 is the variable name(")
        return 0
    done
}

check_app()
{
    if [ $# -lt 1 -o $# -gt 2 ]; then
        myecho "usage: $0 ${ESC_UNDR}App Name${ESC_OFF} [path(return value)]" 1>&2
        exit 1
    fi

    local app=$(brew cask info $1 \
      | grep -A1 "==> Artifacts" | grep -v "==> Artifacts" \
      | awk '{$NF=""; gsub(/^[[:space:]]*|[[:space:]]*$/,"",$0); print $0}')
    # echo "functions: ${app}"

    local retry=0
    while true; do
      local path_app=$(mdfind -onlyin "/Applications" "kMDItemFSName==\"$app\"")
      # echo "functions: $path_app"

      if [ -n "${path_app}" ]; then
        [ $# -eq 2 ] && eval $2="\"${path_app}\""     #"
        return 0
        # break
      elif [ $retry -gt 3 ]; then
        # myecho_error "Could not find \"$appis\"."
        return 1
        # break
      else
        sleep 1
        retry=$(($retry+1))
      fi

    done

}

check_command()
{
    if [ $# -lt 1 -o $# -gt 2 ]; then
        myecho "usage: $0 ${ESC_UNDR}Command Name${ESC_OFF} [path(return value)]" 1>&2
        exit 1
    fi

    local cmd=$(type -p $1)
    if [ -n "${cmd}" ]; then
        [ $# -eq 2 ] && eval $2="\"${cmd}\"" #"
        return 0
    else
        return 1
    fi

}

generate_title()
{
#
# args;
# $1:   Title strings.
#
  if [ $# -ne 1 ]; then
    myecho "usage: ${ESC_BOLD}${FUNCNAME}${ESC_OFF} ${ESC_UNDR}\"Title to display\"${ESC_OFF}" 1>&2
    exit 1
  fi

  #
  # Title
  #
  # printf "\n\n\n"
  length=80

  repeat=$(($((${length} - $((${#1} + 2)) )) / 2 ))
  # printf ' %.0s' $(eval echo {1..${repeat}}); printf "${ESC_BOLD}${ESC_LYLW}$1${ESC_OFF}\n"
  bar=$(printf '#%.0s' $(eval echo {1..${repeat}});)

  myecho "\n\n\n${ESC_BOLD}$bar $1 $bar${ESC_OFF}\n\n"

}

when_its_starting()
{
# args;
# $1:   Title to display.
# $2:   Message type, "yesno", "confirm".
# $3:   Message statement.
# $4:   Parent PID command name.
# $5:   Substring to evaluate where was called from.

  parentProcess="$3"
  parentProcess="${parentProcess##*/}"
  parentProcess="${parentProcess%.*}"
  substring=$4

  #
  # the process been kicked at where?
  #
  if [ "${parentProcess#*$substring}" != "$parentProcess" ]; then
    # run the target script at the terminal directly.

    # title
    generate_title "$1"

    # confirmation
    if ! ask_yesno "$2" ; then
      myecho "Been canceled."
      return 1
    fi
  fi
}

