#!/bin/bash -u

set -e
dir_macset="$HOME/macset"
dir_log="$HOME/log"

source "${dir_macset}/functions.sh"

# 引数チェック
if [ ! $# -eq 2 ]; then
    execho "usage: $0 {source} {destination}" 1>&2
    exit 1
fi

# 引数
dir_SRC=$1
if [ "${dir_SRC: -1}" != '/' ]; then
    dir_SRC="${dir_SRC}/"
fi
dir_DST=$2

# ログ
[ ! -e "${dir_log}" ] && mkdir -p "${dir_log}"
ls "${dir_log}" | grep rsync$(date -v-2w "+%Y%m%d")*.log | xargs rm -f

# タイムスタンプ取得
time_start=$(date "+%Y%m%d-%H%M%S")

# ログファイル
logfile="${dir_log}/rsync${time_start}.log"
touch ${logfile}

# チェック
#rsync -vv -az --dry-run --delete "${dir_SRC}" "${dir_DST}" | open -f -a terminal; \
#    ask_yesno "do you wanto execute?" || execho "processing will be canceled."; exit 1
#
#echo -e "\n\n------------------------------\n\n"

#
# バックアップ (rsync)
#
rsync -vv -az --delete "${dir_SRC}" "${dir_DST}" >>"${logfile}"
