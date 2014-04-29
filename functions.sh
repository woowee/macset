#!/bin/bash -u

ask_confirm()
{
    msg="$1"
    while true; do
        # just wait user's response hitting enter key.
        printf "${msg} (tap \033[7menter\033[0m key)"
        read res

        if [ ${res} ]; then
            echo -e "Sorry, please use [enter] key.\n"
            ask_confirm "${msg}"
        fi
        return 0
    done
}

ask_yesno()
{
    # yes/no
    choice="[y(Yes)/n(No)] : "
    msg="$1 ${choice}"
    while true; do
        printf "${msg}"
        read res

        case ${res} in
            [Yy]*) return 0;;
            [Nn]*) return 1;;
            *)
                echo "Can't read your enter. try again."
                ask_yesno "$1"
        esac
    done
}

ask_inputvalue()
{
    while true; do
        printf "$1"
        read res

        eval $2="\"${res}\""    # $2 is the variable name
        return 0
    done
}

check_existence_app()
{
    if [ $# -lt 1 ]; then
        echo "usage: $0 <App Name>" 1>&2
        exit 1
    fi

    path_app=$(mdfind "kMDItemContentTypeTree==\"com.apple.application\" && kMDItemFSName==\"$1\"")

    if [ -n "${path_app}" ]; then
        [ $# -eq 2 ] && eval $2="\"${path_app}\""
        return 0
    else
        return 1
    fi
}


check_existence_command()
{
    if [ $# -lt 1 ]; then
        echo "usage: $0 <Command Name>" 1>&2
        exit 1
    fi

    path_command=$(type -p $1)
    if [ -n "${path_command}" ]; then
        [ $# -eq 2 ] &&  eval $2="\"${path_command}\""
        return 0
    else
        return 1
    fi

}
