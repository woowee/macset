#!/bin/bash -ux
set -e

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

dir_current=$(dirname $0)
cd ${dir_current}

source ${dir_current}/functions.sh

#
# prepare template dir
#
dir_tmp="${HOME}/tmp"
[ -e "${dir_tmp}" ] || mkdir -p "${dir_tmp}"


# ricty
execho "setting ricty..."
dirRicty=$(mdfind -onlyin "$(brew --prefix)/Cellar" "kMDItemFSName == 'ricty' && kMDItemKind == 'フォルダ'")
dirRictyVer="$(ls "${dirRicty}" | sort -rf | head -1)"
dirRictyIs="${dirRicty}/${dirRictyVer}/share/fonts"
if [ -n "${dirRictyIs}" ]; then
  cp "${dirRictyIs}"/Ricty*.ttf ~/Library/Fonts/ &&:
  if [ $? -ne 0 ]; then
    execho "could ${esc_bld}NOT${esc_off} install ricty."
  else
    fc-cache -vf
    execho "ricty has been installed."
  fi
else
  # err
  execho "could ${esc_bld}NOT${esc_off} install ricty."
fi


cat << END


**************************************************
NOW IT'S DONE.
**************************************************


END
