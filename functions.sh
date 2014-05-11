#!/bin/bash -u

iam=$(basename $0)

esc='\033[1;32m'
esc_uln='\033[4m'
esc_bld='\033[1m'
esc_rev='\033[7m'
esc_off='\033[0m'

prefix="$esc${iam}==>$esc_off"

ask_confirm()
{
    msg="$1"
    msg_display="${prefix} ${msg}"
    while true; do
        # just wait user's response hitting enter key.
        printf "${msg_display} (tap [enter] key)"
        read res

        if [ ${res} ]; then
            execho "Sorry, please use ${esc_rev}enter${esc_off} key."
            ask_confirm "${msg}"
        fi
        return 0
    done
}

ask_yesno()
{
    # yes/no
    choice="[y(Yes)/n(No)] : "

    msg="$1"
    msg_display="${prefix} ${msg} ${choice}"
    while true; do
        printf "${msg_display}"
        read res

        case ${res} in
            [Yy]*) return 0;;
            [Nn]*) return 1;;
            *)
                execho "Can't read your enter. try again."
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

check_existence_app()
{
    if [ $# -lt 1 ]; then
        execho "usage: $0 ${esc_uln}App Name(*.app)${esc_off}" 1>&2
        exit 1
    fi

    path_app=$(mdfind "kMDItemContentTypeTree==\"com.apple.application\" && kMDItemFSName==\"$1\"")

    if [ -n "${path_app}" ]; then
        [ $# -eq 2 ] && eval $2="\"${path_app}\""     #"
        return 0
    else
        return 1
    fi
}

check_existence_command()
{
    if [ $# -lt 1 ]; then
        execho "usage: $0 ${esc_uln}Command Name${esc_off}" 1>&2
        exit 1
    fi

    path_command=$(type -p $1)
    if [ -n "${path_command}" ]; then
        [ $# -eq 2 ] && eval $2="\"${path_command}\"" #"
        return 0
    else
        return 1
    fi

}

execho()
{
    echo_usage=0

    #echo msg
    case $# in
        1)
            echo -e "${prefix} $1" ;;
        2)
            [ $1 == "err" ] && echo -e "${prefix} $2" 1>&2 || echo_usage=1 ;;
        *)
            echo_usage=1
    esac

    #usage?
    if [ ${echo_usage} -ne 0 ]; then
        echo -e "${prefix} usage: ${esc_bld}$0${esc_off} [err] ${esc_uln}msg${esc_off}"
        exit 1
    fi
}
