#!/bin/bash -u

dir_current=$(dirname $0)
cd ${dir_current}

errmsg="\033[1;32m$(basename $0)==>\033[0m Cannot run because some necessary information or files is missing. Check your execution enviroment."

#
# escape sequence for echo
#
iam=$(basename $0)

esc='\033[1;32m'
esc_uln='\033[4m'
esc_bld='\033[1m'
esc_rev='\033[7m'
esc_off='\033[0m'

prefix="$esc${iam}==>$esc_off"

# arg
if [ $# -lt 2 ]; then
    echo -e "${prefix} USAGE: ${esc_bld}check4running.sh${esc_off} ${esc_uln}filename_conf${esc_off} ${esc_uln}filename_func${esc_off}"
    exit 1
fi

#
# config.sh
#
filename_conf="$1"

dir_tmp="${HOME}/temp"
if [ -e "${dir_current}/${filename_conf}" ]; then
    file_conf="${dir_current}/${filename_conf}"
elif [ -e "${dir_tmp}/${filename_conf}" ]; then
    ln -s "${dir_tmp}/${filename_conf}" "${dir_current}/${filename_conf}"
    file_conf="${dir_current}/${filename_conf}"
else
    # here is error case
    [ -e ${dir_tmp} ] || mkdir -p ${dir_tmp}

    cat << EOF > "${dir_tmp}/${filename_conf}"
#!/bin/bash

# Computer Account Settings
COMPUTERNAME=
HOSTNAME=
LOCALHOSTNAME=
# GitHub Account Settings
GITHUB_USERNAME=
GITHUB_EMAIL=
EOF
    echo -e "${errmsg} (Is there '${filename_conf}' ?)" 1>&2
    exit 1
fi
# read
# source ${file_conf}

#
# function.sh
#
filename_func="$2"

if [ ! -e ${dir_current}/${filename_func} ]; then
    echo -e "${errmsg} (Is there '${filename_func}' ?)" 1>&2
    exit 1
fi
# read
# source ${dir_current}/functions.sh
