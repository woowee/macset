#!/bin/bash -u

set -e

# 処理内容；
#   rsync によりバックアップ処理を実行する．
#
#   * {dir_SRC}、および {dir_DST} で指定したパスの各種チェックは行わない。
#     原則、別スクリプトファイル setbackup.sh との併用を前提にしており、
#     そちらでチェックを行っている為。
#
# 使い方；
#   dobackup.sh {dir_SRC} {dir_DST}
#
# 引数；
#   01. dir_SRC ... バックアップ対象(デフォルト；$HOME)
#   02. dir_DST ... バックアップ先(デフォルト；/Volumes/My\ Passport\ Studio/bkup/)
# 引数チェック


dir_macset="$HOME/macset"
dir_log="$HOME/log"

source "${dir_macset}/functions.sh"


if [ ! $# -eq 2 ]; then
    echo "usage: $0 {source} {destination}" 1>&2
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
# バックアップ処理実行 (rsync)
#
rsync -vv -az "${dir_SRC}" "${dir_DST}" >>"${logfile}"


#
# 終了
#

execho "${esc_bld}Now it's done.${esc_off}"

# ログファイルを開く
open "${logfile}"
