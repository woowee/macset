#!/bin/bash -u

set -e
dir_src="${HOME}/macset/vimset"
dir_dst="${HOME}/.vim"

# arguments
SRC_IS="macset/vimset"
DST_IS=".vim"
# SRC_IS="vimset"
# DST_IS=".vim"
if [ $# -eq 2 ]; then
  SRC_IS=$1
  DST_IS=$2
elif [ $# -eq 1 ]; then
  SRC_IS=$1
  DST_IS=${DST_IS}
elif [ $# -eq 0 ]; then
  SRC_IS=${SRC_IS}
  DST_IS=${DST_IS}
else
  echo "usage : $0 {source} {destination}" 1>&2
  exit 1
fi

dir_src="${HOME}/$SRC_IS"
dir_dst="${HOME}/$DST_IS"


if [ -e "${dir_src}" ]; then

  # once get the path of `dir_src` is absolute
  dir_src=$(cd $(dirname $dir_src) && pwd)/$(basename $dir_src)

  # check existence of dir `dir_dst`
  [ ! -e "${dir_dst}" ] && mkdir "${dir_dst}"

  # all items under `dir_src` are targets...
  pattern=$(echo $dir_src | perl -pe "s/\//\\\\\//g")
  find "${dir_src}" | while read ITEM; do

    # make path
    itemIs=$(echo "${ITEM}" | perl -pe "s/"${pattern}"//")

    if [ -d "${ITEM}" ]; then
      # the case of directory
      if [ ! -e "${dir_dst}$itemIs" ]; then
        echo "  - ${ITEM}"
        mkdir "${dir_dst}/${itemIs}"
      fi
    else
      # make symlink
      if ! [ "${ITEM##*/}" = ".DS_Store" -o "${ITEM##*.}" = "un~" ]; then
        ln -fs "${ITEM}" "${dir_dst}/${itemIs}"
      fi
    fi
  done
fi

echo "DONE: Set your vim runtime. Check $dir_dst."
