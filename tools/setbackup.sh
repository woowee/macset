#!/bin/zsh -eu


# 処理内容；
#   バックアップ処理のスケジュール設定をする．
#
#
#   * バックアップ処理の周期は、1 日 1 回。
#   * 毎日 {BACKUP_TIME} 時に、スクリプトファイル {BACKUP_SCRIPT} を実行し，
#     {DIR_SOURCES} の内容を {DIR_DESTINATION} へバックアップする．
#   * スケジューリング制御は launchd/launchctl による．
#   * バックアップ処理の具体的な処理は，別途スクリプト {BACKUP_SCRIPT} に設けている．
#     本スクリプト内にはその処理自身の記述はない。
#
# 使い方；
#   setbackup.sh {DIR_SOURCES} {DIR_DESTINATION}
#
# 引数；
#   なし．
#

source "$HOME/macset/functions.sh"

#
# 初期値(defaults); これら値は，ユーザー任意で変更可．
#
# バックアップを録る場所
# readonly DIR_SOURCES="$HOME/"
readonly DIR_SOURCES="$HOME/Documents/"
# バックアップを置く場所
# readonly DIR_DESTINATION="/Volumes/sioccala/rsyncedTimeMachine"
readonly DIR_DESTINATION="$HOME/temp"

# launchd の plist
readonly DIR_LAUNCH="$HOME/Library/LaunchAgents"
# パスの指定、リトライ回数
readonly RETRY=3
# バックアップ処理を実行する時刻(0-24)
readonly BACKUP_TIME=3    # 03:00 am

# 実行するスクリプトファイル(実際のバックアップ処理が記述されている)
readonly BACKUP_SCRIPT="$HOME/macset/tools/dobackup.sh"

readonly SCRIPT_NAME=$(basename $0)

#
# Functions
#





#
# 環境チェック
#

# rsync コマンドの存在チェック
type rsync >/dev/null 2>&1; existence=$?
if [ ! $existence -eq 0 ]; then
  echo -e "$SCRIPT_NAME: there is not `${ESC_UNDR}rsync${ESC_OFF}` command. check your operating enviroment. processing will be canceled."  #'(just only to escape)
  exit 1
fi

# rsync コマンドのバージョンチェック (version 3.x を使わせる)
if [ "$(rsync --version | awk 'NR==1 {print $3}')" -le 3.0 2>/dev/null ]; then
  echo -e "$SCRIPT_NAME: the version of `rsync` is not 3.0 or later. processing will be canceled."
  exit 1
fi

# ~/Library/LaunchAgents の存在チェック
if [ -z $DIR_LAUNCH ]; then
  echo -e "$SCRIPT_NAME: there is not \"${ESC_UNDR}~/Library/LaunchAgents${ESC_OFF}\". check your operating enviroment. processing will be canceled."   #'(just only to escape)
  exit 1
fi

# シェルスクリプト存在チェック
if [ ! -e "${BACKUP_SCRIPT}" ]; then
  echo -e "$SCRIPT_NAME: there is not the script \"${BACKUP_SCRIPT}\". processing will be canceled.\nstart again from the beginning"
  exit 1
fi

# 実行確認
if ! ask_yesno "are you sure want to set as follows;\n\
  source      : ${ESC_OFF}${DIR_SOURCES}${ESC_OFF}\n\
  destination : ${ESC_OFF}${DIR_DESTINATION}${ESC_OFF}\n "; then
    echo -e "$SCRIPT_NAME: processing will be canceled. try again first."
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
    <string>${BACKUP_SCRIPT}</string>
    <string>${DIR_SOURCES}</string>
    <stritg>${DIR_DESTINATION}</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>${BACKUP_TIME}</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>StandardErrorPath</key>
    <string>${HOME}/${plist_label}_err.log</string>
  <key>StandardOutPath</key>
    <string>${HOME}/${plist_label}.log</string>
</dict>
</plist>
END

#
# launchd ロード
#
if ask_yesno "load this job ?"; then
    mv "${plist_filepath}" "${DIR_LAUNCH}"
    launchctl load "${DIR_LAUNCH}/${plist_label}.plist"
else
    myecho "processing will be canceled."
fi


#
# 終了
#

# 現在登録中のジョブ一覧表示
launchctl list | grep $(hostname -s) | \
while IFS= read item; do
    job=$(echo "${item}" | awk '{print $3}')
    if [ $(echo "${job}" | grep backup) ]; then
        echo -e ${ESC_OFF}${job}${ESC_OFF}
    else
        echo -e "${job}"
    fi
done

# ~/Library/LaunchAgents を見せとく
open "${DIR_LAUNCH}"

echo -e "${ESC_BOLD}Now it's done.${ESC_OFF}"

