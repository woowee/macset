#!/bin/bash -u

set -e
source "$(dirname $0)/functions.sh"

# 処理内容；
#   バックアップ処理の為のスケジュールを設定する。
#   毎日 {sch_houris} 時、{dir_SRC} を {dir_DST} へバックアップをとる。
#
# 使い方；
#   setbackup.sh {dir_SRC} {dir_DST}
#
# 引数；
#   01. dir_SRC ... バックアップ対象(デフォルト；$HOME)
#   02. dir_DST ... バックアップ先(デフォルト；/Volumes/My\ Passport\ Studio/bkup/)


#
# 初期値(defaults)
#
# バックアップを録る場所
dir_SRC="$HOME/"
# バックアップを置く場所(スペースは\エスケープしては駄目)
dir_DST="/Volumes/My Passport Studio/bkup/"

# launchd の plist
dir_launch="$HOME/Library/LaunchAgents"
# パスの指定、リトライ回数
retry=3
# バックアップ処理を実行する時刻、毎日
sch_houris=3    # 03:00 am

# ログを置く場所
file_process="$HOME/macset/backup.sh"

#
# Functions
#
check_existence_dir()
{
    if [ $# -lt 1 ]; then
        execho "usage: $0 {pathToExistenceCheck}" 1>&2
        return 1
    fi

    #init
    diris=""
    times="${retry}"

    #check existence of $1 as the specified directory
    if [ -e "$1" ]; then
        diris=$1
    else
        while true; do
            if [ "${times}" -le 0 ]; then
                diris=""
                break
            fi

            if [ "${times}" -eq "${retry}" ]; then
                dir_err=$1
            else
                dir_err="${newpath}"
            fi
            ask_inputvalue "specified directory \"${dir_err}\" is incorrect. try to specify the path again. : " newpath

            ((times--))

            if [ -e "${newpath}" ]; then
                diris="${newpath}"
                break
            fi
        done
    fi

    eval $2="\"${diris}\""
}


#
# 引数チェック
#

# 引数の数
if [ $# -gt 2 ]; then
    # エラー
    execho "usage: $0 {sourcePath} {destinationPath}" 1>&2
    exit 1
fi
flg_usedefaults=0
# 引数なしの場合デフォルト値を使用?
if [ $# -eq 0 ]; then
  if ask_yesno "has been specified no args. do you want process using defaults value?\n\
  source      : ${esc}${dir_SRC}${esc_off}\n\
  destination : ${esc}${dir_DST}${esc_off}\n\n"; then
    flg_usedefaults=1
  else
    execho "try to operate with specifing args again from the begining."
    exit 1
  fi
fi

#
# バックアップ対象(元)
#
if [ $flg_usedefaults -eq 0 ]; then
  check_existence_dir "$1" dir_checked
  if [ -z "${dir_checked}" ]; then
    execho "the sipecified \"${esc_uln}source${esc_off}\" path to backup does not exist or is  incorrect."
    if ask_yesno "do you want use the default source path \"${dir_SRC}\" ?"; then
      dir_checked="${dir_SRC}"
    else
      execho "check the path \"${esc_uln}source${esc_off}\". processing will be canceled."
      exit 1
    fi
  fi
  if [ "${dir_checked: -1}" != '/' ]; then
    dir_checked="${dir_checked}/"
  fi
else
  dir_checked="${dir_SRC}"
fi
dir_SRC="${dir_SRC}"
# ref. http://qiita.com/uasi/items/82b7708d5da213ba7c31


#
# バックアップ先
#
if [ $flg_usedefaults -eq 0 ]; then
  check_existence_dir "$2" dir_checked
  if [ -z "${dir_checked}" ]; then
    execho "the sipecified \"${esc_uln}destination${esc_off}\" path to backup does not exist or is  incorrect."
    if ask_yesno "do you want use the default source path \"${dir_DST}\" ?"; then
      dir_checked="${dir_DST}"
    else
      execho "check the path \"${esc_uln}destination${esc_off}\". processing will be canceled."
      exit 1
    fi
  fi
else
  dir_checked="${dir_DST}"
fi
dir_DST="${dir_checked}"


#
# 環境チェック
#

# rsync コマンドの存在チェック
if ! check_existence_command "rsync" dir_rsync ; then
  execho "there is not `${esc_uln}rsync${esc_off}` command. check your operating enviroment. processing will be canceled."  #'(just only to escape)
  exit 1
fi

# rsync コマンドのバージョンチェック (version 3.x を使わせる)
if [ "$(rsync --version | awk 'NR==1 {print $3}')" -le 3.0 2>/dev/null ]; then
  echo "the version of `rsync` is not 3.0 or later. processing will be canceled."
  exit 1
fi

# ~/Library/LaunchAgents の存在チェック
if [ -z $dir_launch ]; then
  execho "there is not \"${esc_uln}~/Library/LaunchAgents${esc_off}\". check your operating enviroment. processing will be canceled."   #'(just only to escape)
  exit 1
fi

# シェルスクリプト存在チェック
if [ ! -e "${file_process}" ]; then
    execho "there is not the script \"${file_process}\". processing will be canceled.\nstart again from the beginning"
    exit 1
fi

# 実行確認
if ! ask_yesno "are you sure want to set as follows;\n\
  source      : ${esc}${dir_SRC}${esc_off}\n\
  destination : ${esc}${dir_DST}${esc_off}\n "; then
    execho "processing will be canceled. try again first."
    exit 1
fi



#
# plist 作成
#
plist_label="$(hostname -s).backup.home"
plist_filepath="./${plist_label}.plist"
# 登録 job 存在チェック --> 同名jobがあったら重複とし削除
for job in $(launchctl list | awk '{print $3}'); do
  # remove job
  if [ "${job}" = "${plist_label}" ]; then
      launchctl remove "${job}"
  # remove plist file
      [ -e "${plist_filepath}" ] && rm "${plist_filepath}"
  fi
done

# plist 生成
cat << END >> "${plist_filepath}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${plist_label}</string>
  <key>ProgramArguments</key>
  <array>
    <string>${file_process}</string>
    <string>$dir_SRC</string>
    <string>$dir_DST</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>${sch_houris}</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>StandardErrorPath</key>
    <string>$(dirname $0)/${plist_label}_err.log</string>
  <key>StandardOutPath</key>
    <string>$(dirname $0)/${plist_label}.log</string>
</dict>
</plist>
END

#
# launchd ロード
#
if ask_yesno "load this job ?"; then
    mv "${plist_filepath}" "${dir_launch}"
    launchctl load "${dir_launch}/${plist_label}.plist"
else
    execho "processing will be canceled."
fi

#
# 終了
#

# 現在登録中のジョブ一覧表示
launchctl list | grep $(hostname -s) | \
while IFS= read item; do
    job=$(echo "${item}" | awk '{print $3}')
    if [ $(echo "${job}" | grep backup) ]; then
        echo -e ${esc}${job}${esc_off}
    else
        echo -e "${job}"
    fi
done

# ~/Library/LaunchAgents を見せとく
open "${dir_launch}"

execho "${esc_bld}Now it's done.${esc_off}"
