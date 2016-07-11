#!/bin/bash -u

set -e


#
# constants
#
# DIR_SRC="${HOME}/macset/vimset"
DIR_SRC="${HOME}/dots/vimset"
DIR_DST="${HOME}/.vim"


#
# read function
#

# current
dir_current=$(dirname $0)
cd ${dir_current}
# read
filename_func=$(dirname $0)/functions.sh

if [ ! -e ${filename_func} ]; then
    echo -e "\033[1;32m$(basename $0)==>\033[0m Cannot run because some necessary information or files is missing. Check your execution enviroment. (Is there '${filename_func}' ?)"
    exit 1
fi
source ${filename_func}


#
# PREPARE
#

# argments and defaults
if [ $# -eq 0 ]; then
  SRC_IS="${DIR_SRC}"
  DST_IS="${DIR_DST}"
elif [ $# -eq 1 ]; then
  SRC_IS="$1"
  DST_IS="${DIR_DST}"
elif [ $# -eq 2 ]; then
  SRC_IS="$1"
  DST_IS="$2"
else
  echo "usage : $0 {source} {destination}" 1>&2
  exit 1
fi

# check the existence
# source
if [ ! -e "${SRC_IS}" ]; then
  echo -e "\033[1;32m$(basename $0)==>\033[0m \033[1;31merror has occured.\033[0m"
cat << END
there is not the specified directory as source.; "${SRC_IS}"
END
  exit 1
fi
# destination
if [ ! -e "${DIR_DST}" ]; then
  echo -e "\033[1;32m$(basename $0)==>\033[0m \033[1mconfirmation\033[0m"
  if ask_yesno "there is not the specified directory as destination.\ndo you want to make new directory?"; then
    mkdir "${DIR_DST}"
  else
    eixt 1
  fi
fi


#
#
#

# once get the path of `DIR_SRC` is absolute
SRC_IS=$(cd $(dirname $SRC_IS) && pwd)/$(basename $SRC_IS)

# all items under `DIR_SRC` are targets...
pattern=$(echo $DIR_SRC | perl -pe "s/\//\\\\\//g")
find "${SRC_IS}" | while read ITEM; do

 # make path
 itemIs=$(echo "${ITEM}" | perl -pe "s/"${pattern}"//")

 if [ -d "${ITEM}" ]; then
   # the case of directory
   if [ ! -e "${DST_IS}$itemIs" ]; then
     echo "  - ${ITEM}"
     mkdir "${DST_IS}/${itemIs}"
   fi
 else
   # make symlink
   if ! [ "${ITEM##*/}" = ".DS_Store" -o "${ITEM##*.}" = "un~" ]; then
     echo "ln -fs " "${ITEM}" "${DST_IS}${itemIs}"
     ln -fs "${ITEM}" "${DST_IS}${itemIs}"
   fi
 fi
done

echo "DONE: Set your vim runtime. Check $DIR_DST."
