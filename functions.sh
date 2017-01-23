#!/bin/bash -u
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

set -eu

readonly IAM=$(basename $0)
readonly PREFIX="$IAM) "

#
# 定数
#

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
    # echo -e ${PREFIX} ${ESC_RED}ERROR: ${ESC_OFF}Argument is incurrect. \
    #   You can specify argument is 0 \(as \"minimal\"\) or 1 \(as \"complete\"\). \
    #   Process will be canceled.
    myecho_error Argument is incurrect. \
      You can specify argument is 0 \(as \"minimal\"\) or 1 \(as \"complete\"\). \
      Process will be canceled.
    exit 1
  fi

  readonly MODE_IS=$n

}



# # 作業用に使用する一時的なディレクトリ
# readonly DIR_TEMP="~/temp"
# [ ! -e $DIR_TEMP ] && mkdir -p $DIR_TEMP


# ask_confirm()
# {
#     msg="$1"
#     msg_display="${prefix} ${msg}"
#     while true; do
#         # just wait user's response hitting enter key.
#         printf "${msg_display} (tap [enter] key)"
#         read res
#
#         if [ ${res} ]; then
#             execho "Sorry, please use ${esc_rev}enter${esc_off} key."
#             ask_confirm "${msg}"
#         fi
#         return 0
#     done
# }
#
ask_yesno()
{
    # yes/no
    local choice="[y(Yes)/n(No)] : "

    local msg="$1"
    local msg_display="${prefix} ${msg} ${choice}"
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
        printf "${prefix} $1"
        read res

        eval $2="\"${res}\""    # $2 is the variable name(")
        return 0
    done
}

# check_existence_app()
# {
#     if [ $# -lt 1 ]; then
#         execho "usage: $0 ${esc_uln}App Name(*.app)${esc_off}" 1>&2
#         exit 1
#     fi
#
#     path_app=$(mdfind "kMDItemContentTypeTree==\"com.apple.application\" && kMDItemFSName==\"$1\"")
#
#     if [ -n "${path_app}" ]; then
#         [ $# -eq 2 ] && eval $2="\"${path_app}\""     #"
#         return 0
#     else
#         return 1
#     fi
# }
#
# check_existence_command()
# {
#     if [ $# -lt 1 ]; then
#         execho "usage: $0 ${esc_uln}Command Name${esc_off}" 1>&2
#         exit 1
#     fi
#
#     path_command=$(type -p $1)
#     if [ -n "${path_command}" ]; then
#         [ $# -eq 2 ] && eval $2="\"${path_command}\"" #"
#         return 0
#     else
#         return 1
#     fi
#
# }
#
