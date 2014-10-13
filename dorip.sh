#!/bin/bash -u

set -e

#
# function.sh 読み込み
#

dirFnc="$(dirname $0)/functions.sh"
if [ ! -e "${dirFnc}" ]; then
  dirFnc="$HOME/macset/functions.sh"
  if [ ! -e "${dirFnc}" ]; then
    echo "check your operating enviroment." 1>&2
    exit 1
  fi
fi
source "${dirFnc}"

#
# 引数チェック
#
if [ ! $# -eq 0 ]; then
  execho "usage: $0" 1>&2
  exit 1
fi


#
# 環境チェック
#

# 入力
src=$(diskutil info disk1 | grep 'Escaped.*Volume' | awk -F':' '{print $2}' | awk '{gsub(/^[ \t]+|[ \t]+$/, "")}1')
if [ ! -e "${src}" ]; then
  execho "the specified path \"${src}\" is incorrect."
fi


# 出力
dst=$HOME/Desktop/films
[ $# -eq 2 ] && dst=$2
[ ! -e "${dst}" ] && mkdir -p "${dst}"

msg_confirm=$(cat <<END
Processing ins started as following. Is it OK? ;
  - source      : "${src}"
  - destination : "${dst}"

  hdiutil makehybrid -iso -joliet -o "${dst}/${src##*/}.iso" "${src}/"

)

if ! ask_yesno "${msg_confirm}\n\n"; then
  echo "processing been canceled."
  exit 1
fi

src_devnode=$(diskutil info "${src}" | grep 'Device Node:' | awk -F':' '{print $2}' | awk '{gsub(/^[ \t]+|[ \t]+$/, "")}1')
hdiutil makehybrid -iso -joliet -o "${dst}/${src##*/}.iso" "${src}/"
hdiutil eject "${src}"

echo "it's done!"
