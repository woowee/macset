#!/bin/zsh -eu

# 処理内容；
#   バックアップを行う．
#
#
#   * $destination(バックアップ先) に $sources(バックアップしたいもの) を
#     バックアップする．
#   * 作成者の個人的な意向で，恣意的にデフォルト値を設けている．
#     デフォルト値はそれぞれ，$DEFAULT_DESTINATION，$DEFAULT_SROUCES へ，
#     定義しているもの．
#     個人的なもので，任意で良いもの．
#
# 使い方；
#   dobakcup.sh [source ...] [destination]
#
# 引数；
#   必要に応じ．
#
# 注意 ;
#   source を複数にすると，最後のパスが正常に渡すことができない模様．
#   このことから，--exclude-from で外部ファイルにバックアップ対象を
#   定義する方法を採る．
#
# 謝辞 ;
# このスクリプトは，下記のスクリプトを参考にしております．
# ありがとうございます．
# [samdoran/rsync-time-machine: Backup mimicking Time Machine from Mac OS X using rsync](https://github.com/samdoran/rsync-time-machine)
# Thank you very match.
#

source $HOME/macset/configurations.sh

readonly ESC_RED='\033[0;31m'
readonly ESC_LRED='\033[1;31m'
readonly ESC_BOLD='\033[1m'
readonly ESC_OFF='\033[0m'

readonly PROGNAME=$0

# readonly DEFAULT_SROUCES="\
# ${HOME}/Documents \
# ${HOME}/Downloads \
# ${HOME}/Music \
# ${HOME}/Pictures \
# ${HOME}/Movies"
readonly DEFAULT_SROUCES="$HOME/"
readonly EXCLUDE_FROM="$HOME/.rsync-backup-exclude"
readonly DEFAULT_DESTINATION="$BACKUP_DESTINATION"

# Cannot use like this...
# readonly RSYNC_OPTIONS="--archive --verbose --partial --progress --human-readable --dry-run"
readonly RSYNC_OPTIONS="-avvz"
readonly RSYNC_LOGFILE="rsync_log.txt"

readonly DATE_FORMAT=$(date "+%Y-%m-%d-%H%M%S")
readonly CURRENT_YEAR=$(date +%Y)
readonly CURRENT_MONTH=$(date +%m)
readonly LAST_YEAR=$(date -v -1y "+%Y")

readonly SCRIPTNAME="$0"

usage() {
  echo "Usage:"
  echo "  $PROGNAME: [OPTIONS] [SOURCE]... [DESTINATION]"
  echo "  This script will backup using rsync."
  echo "Options:"
  echo "  -i  (interactive)"
  echo
  exit 1
}


#
# Define sources and destination
#

sources=""
destination=""

# Check options
local -A opthash
zparseopts -D -A opthash -- i


if [ -n "${opthash[(i)-i]}" ]; then
  readonly HAS_OPTIONS="Yes"
else
  readonly HAS_OPTIONS="No"
fi

for optionCheck in "$@";
do
  if [ ${optionCheck[(i)${:--}]} -eq 1 ]; then
    echo
    echo "${ESC_LRED}Specified option is incorrect.${ESC_OFF}"
    echo "${ESC_LRED}The option '-i' should put the first of arguments.${ESC_OFF}"
    usage
    exit 1
  fi
done


# Check arguments
if [ $# -eq 0 ]; then
  if [ "$HAS_OPTIONS" = "Yes" ]; then
    echo "None of the arguments is specified."
    echo "Use the defaults value."
  else
    :
  fi
elif [ ! $# -ge 2 ]; then
  echo
  echo "${ESC_LRED}Specify the arguments of sources and destination.${ESC_OFF}"
  usage
  exit 1
else
  arguments=("$@")
  sources=$arguments[1,-2]
  destination=$arguments[-1]
fi

# Srouces and destination
sources=${sources:=$DEFAULT_SROUCES}
destination=${destination:=$DEFAULT_DESTINATION}

if [ "$HAS_OPTIONS" = "Yes" ]; then
  echo -e "Do you want to back up using rsync"
  tcho -e "with the following settings?"
  echo -e "- Srouces:"
  # c.f. https://qiita.com/uasi/items/82b7708d5da213ba7c31
  for item in ${=sources};
  do
    echo "  $item"
  done
  echo -e "- Destination:"
  echo -e "  $destination"
  # Wait enter.
  while true;
  do
    echo -n "Choice [y/n]: "
    read res

    case ${res} in
      [Yy]*) break;;
      [Nn]*) return 1;;
      *) echo "Can't read your enter. try again.";;
    esac
  done
fi


#
# Rsync processing
#

if [ ! -d "$destination" ]; then
  mkdir -p "$destination"
fi

if [ ! -L "$destination/Latest" ] ; then
  echo "HEY!! THERE IS NO SYMLINK."
  # rsync $RSYNC_OPTIONS \
  #              --delete \
  #              --log-file="$RSYNC_LOGFILE" \
  #              --exclude-from="$EXCLUDE_FROM" \
  #              "$sources" "$destination/$DATE_FORMAT"
  rsync $RSYNC_OPTIONS \
               --log-file="$RSYNC_LOGFILE" \
               --exclude-from="$EXCLUDE_FROM" \
               "$sources" "$destination/$DATE_FORMAT"
else
  echo "HEY!! THERE IS THE SYMLINK."
  # rsync $RSYNC_OPTIONS \
  #              --delete \
  #              --log-file="$RSYNC_LOGFILE" \
  #              --exclude-from="$EXCLUDE_FROM" \
  #              --link-dest="$destination/Latest" \
  #              "$sources" "$destination/$DATE_FORMAT"
  rsync $RSYNC_OPTIONS \
               --log-file="$RSYNC_LOGFILE" \
               --exclude-from="$EXCLUDE_FROM" \
               --link-dest="$destination/Latest" \
               "$sources" "$destination/$DATE_FORMAT"
fi

rm -f "$destination/Latest"

# Create symlink to latest backup
ln -s $DATE_FORMAT "$destination/Latest"


# TODO:
# # Keep monthly backups for one year
# for (( month = 1 ; month < $CURRENT_MONTH ; month++ )); do
#   # List latest backup from each month of current year
#   # Use printf to pad the single digit months with a 0
#   LATEST_BACKUP=$(find "$DESTINATION" -mindepth 1 -maxdepth 1 -name ${CURRENT_YEAR}-$(printf "%02d" $month)-* | sort | tail -n 1)
#   find "$DESTINATION" -mindepth 1 -maxdepth 1 -name ${CURRENT_YEAR}-$(printf "%02d" $month)-* | grep -v "$LATEST_BACKUP" | xargs -I {} rm -rf {}
# done
#
# for (( month = $CURRENT_MONTH ; month <= 12 ; month++ )); do
#   # List latest backup from each month of current year
#   # Use printf to pad the single digit months with a 0
#   LATEST_BACKUP=$(find "$DESTINATION" -mindepth 1 -maxdepth 1 -name ${LAST_YEAR}-$(printf "%02d" $month)-* | sort | tail -n 1)
#   find "$DESTINATION" -mindepth 1 -maxdepth 1 -name ${LAST_YEAR}-$(printf "%02d" $month)-* | grep -v "$LATEST_BACKUP" | xargs -I {} rm -rf {}
# done
#
#
# # Remove backups older than one year
# for (( month = 1 ; month < $CURRENT_MONTH ; month++ )); do
#   find "$DESTINATION" -mindepth 1 -maxdepth 1 -type d -name "$LAST_YEAR-$(printf "%02d" $month)-*" | xargs -I {} rm -rf {}
# done
#
# find "$DESTINATION" -mindepth 1 -maxdepth 1 -type d ! -name "$CURRENT_YEAR-*" | grep -v "$LAST_YEAR-*" | xargs -I {} rm -rf {}
#
