#!/bin/bash -eu
#
# @(#) macos.sh ver.0.0.0 2014.05.18
#
# Usage:
#   macos.sh [mode]
#     arg1 - 処理のモード．
#            0: $MODE_MINIMAL  必要最小限 "minimal" の設定処理を行う．
#            1: $MODE_COMPLETE すべての "complete" 設定処理を行う．
#            mode を設定しない場合は，"1" としてのモードで処理を行う．
#            定数 $MODE_MINIMAL，$MODE_COMPLETE は，functions.sh で定義され
#            ており，`source functions.sh` により取り込まれるもの．
#
# Description:
#   macOS の各種設定を行う．
#
# This script been referred to ;
#  - [mathiasbynens/dotfiles - mathiasbynens dotfiles](https://github.com/mathiasbynens/dotfiles/blob/master/.macos)
#  - [OSX For Hackers](https://gist.github.com/DAddYE/2108403)
# Thank you very much mathiasbynens, DAddYE
###########################################################################

#
# PREPARE
#

# Check the files required for this process
readonly FILE_FUNC="$(dirname $0)/functions.sh"
readonly FILE_CONF="$(dirname $0)/configurations.sh"

function check_files() {
  local esc_red='\033[0;31m'
  local esc_reset='\033[0m'
  # local esc_reset=`tput sgr0`

  local file_is=$1

  # existense check
  if [ ! -e $1 ]; then
    # error message
    echo -e $(basename $0)\)  ${esc_red}ERROR: ${esc_reset} \
      There is not the file \"$1\". \
      Check the file \"${1##*/}\". \
      Process will be canceled.
      exit 1
  fi

  # read
  if ! source ${file_is}; then
    echo -e $(basename $0)\)  ${esc_red}ERROR: ${esc_reset} \
      Couldnot read the file \"$(basename $1)\". \
      The file itself or the content may be incurrect. \
      Process will be canceled.
    exit 1
  fi
}

check_files $FILE_FUNC
check_files $FILE_CONF


# Check mode minimal or complete
# -> The constants been defined in `function.sh` ;
#    MODE_MINIMAL  (0)
#    MODE_COMPLETE (1)

get_mode $@
# echo "Mode is $MODE_IS."


#
# Confirmation start
#
echo -e "
                        macOS System Settings
----------------------------------------------------------------------
"

if ! ask_yesno "Do you want to set macOS system ?" ; then
  myecho "This process been canceled."
  exit 1
fi


# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


#
# FUNCTIONS
#
function do_set() {
  if [ $MODE_IS -eq $MODE_MINIMAL ]; then
    case $# in
     1) return 1 ;;
     2)
       if [ $2 -eq $MODE_COMPLETE ]; then
         return 1
       fi
       ;;
     *) return 1 ;;
    esac
  fi

  echo -e ${PREFIX} - $1
}



#
# SET MACOS DEFAULTS
#

## Finder

if do_set 'Finder: ファイルの拡張子を表示する．'; then
    defaults write -g AppleShowAllExtensions -bool true
    # [Finder の環境設定 > 詳細 > すべてのファイル名拡張子を表示] => "ON"
fi

if do_set 'Finder: スクリーンショットでついてくるウィンドウの影を抑制．' $MODE_MINIMAL; then
    defaults write com.apple.screencapture disable-shadow -bool true
    # (none)
fi

if do_set 'Finder: スクリーンショットの保存先．' $MODE_MINIMAL; then
    [ ! -e "$DIR_SCREENSHOOTS" ] && mkdir "$DIR_SCREENSHOOTS"
    defaults write com.apple.screencapture location -string "$DIR_SCREENSHOOTS"
    # (none)
fi

if do_set 'Finder: 保存ダイアログの拡張．'; then
    defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
    defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true
    # (none)
fi

if do_set 'Finder: .DS_Store を作らない．' $MODE_MINIMAL; then
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    # (none)
fi

if do_set 'Finder: Finderのタイトルバーにフルパスを表示する．' $MODE_MINIMAL; then
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    # (none)
fi

if do_set 'Finder: QuickLook のコンテンツを選択できるようにする．'; then
    defaults write com.apple.finder QLEnableTextSelection -bool true
    # (none)
fi

if do_set 'Finder: ダイアログ表示やウィンドウリサイズ速度を速くする．'; then
    defaults write -g NSWindowResizeTime -float 0.001
    # (none)
fi

if do_set 'Finder: Finderのアニメーション効果を全て無効にする．'; then
    defaults write com.apple.finder DisableAllAnimations -bool true
    # (none)
fi

if do_set 'Finder: ファイルを開くときのアニメーションを無効にする．'; then
    defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
    # (none)
fi

if do_set 'Finder: ダウンロードアプリケーションを開く際の警告ダイアログを無効にする．'; then
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    # (none)
fi

#if do_set 'Finder: クラッシュリポーターを無効にする．'; then
#    defaults write com.apple.CrashReporter DialogType -string "none"
#    # (none)
#fi

if do_set 'Finder: ヘルプを non-floating mode にする．'; then
    defaults write com.apple.helpviewer DevMode -bool true
    # (none)
fi

if do_set 'Finder: ファイル保存先のデフォルトはローカルに(icloudではない)．'; then
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
    # (none)
fi

if do_set 'Finder: 拡張子変更時のアラートを抑制する．'; then
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    # (none)
fi

if do_set 'Finder: 外付けメディアをセットしたら、その中身を表示する．'; then
    defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
    defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
    defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
    # (none)
fi

if do_set 'Finder: Finder ウィンドウは、リスト形式でデフォルト表示する．'; then
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    # (none)
    # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
fi

if do_set 'Finder: 新規 Finder ウィンドウのデフォルトは `$HOME` ホームディレクトリ．' $MODE_MINIMAL; then
    defaults write com.apple.finder NewWindowTarget -string "PfHm"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
    # Finder > 環境設定 > 一般 > 新規 Findoer ウィンドウを表示] = `$HOME`
fi

if do_set 'Finder: メニューバー設定．' $MODE_MINIMAL; then
    for domain in "~/Library/Preferences/ByHost/com.apple.systemuiserver.*"; do
        defaults write "${domain}" dontAutoLoad -array \
        "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
        "/System/Library/CoreServices/Menu Extras/User.menu"
    done
    defaults write com.apple.systemuiserver menuExtras -array \
        "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
        "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
        "/System/Library/CoreServices/Menu Extras/Volume.menu" \
        "/System/Library/CoreServices/Menu Extras/Battery.menu" \
        "/System/Library/CoreServices/Menu Extras/Clock.menu"
fi

if do_set 'Finder: 各 UI の透明度を下げる．(メニューバーはじめ他のパーツの半透明を無効にする)'; then
   defaults write com.apple.universalaccess reduceTransparency -bool true
fi

if do_set 'Finder: デスクトップを変更する．'; then
    osascript -e 'tell application "Finder" to set desktop picture to POSIX file "'"$FILE_DESKTOPPICTURE"'"'
    # [システム環境設定 > デスクトップとスクリーンセーバ] = [デスクトップ > Apple > 無地の色 > ソリッドグレイ・プロ・ウルトラダーク]
fi



## Dock

if do_set 'Dock   : Dock の位置を下にする．' $MODE_MINIMAL; then
    defaults write com.apple.dock orientation -string "bottom"
    # [システム環境設定 > Dock > 画面上の位置] => "下"
    #defaults write com.apple.dock pinning -string start
    # (none, osx yosemite になって無くなった様子．ref.https://discussions.apple.com/thread/6600902)
fi

if do_set 'Dock   : Dock を隠す．' $MODE_MINIMAL; then
    defaults write com.apple.dock autohide -bool true
    # [システム環境設定 > Dock > Dock を自動的に隠す/表示] => "ON"
fi

if do_set 'Dock   : Dock の大きさをセットする．(36)'; then
    defaults write com.apple.dock tilesize -int 36
    # [システム環境設定 > Dock > 大きさ] = sld[サイズ] 1/8 くらい
fi

if do_set 'Dock   : グリッド表示時の Dock のスタック上のマウスオーバー時，ハイライトする．'; then
    defaults write com.apple.dock mouse-over-hilite-stack -bool true
    # (none)
fi

if do_set 'Dock   : Dock への drag & drop で起動/開く機能 (スプリングフォルダの dock 版) を利用する．'; then
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
    # (none)
fi

if do_set 'Dock   : Dock の起動しているアプリケーションにインジケータ・ランプを表示する．'; then
    defaults write com.apple.dock show-process-indicators -bool true
    # [システム環境設定 > Dock > 起動済みのアプリケーションにインジケータ・ランプを表示] => "オン"
fi

if do_set 'Dock   : Dock のコンテンツを真っ新にする．'; then
    defaults write com.apple.dock persistent-apps -array ""
    # (none)
fi

if do_set 'Dock   : 起動中，またはステータスが変わった Dock のアプリケーションをアニメーションさせない．'; then
    defaults write com.apple.dock launchanim -bool false
    # [システム環境設定 > Dock > 起動中のアプリケーションをアニメーションで表示] => "OFF"
fi

if do_set 'Dock   : mission control への移行アニメーション速度 を 0.1 秒にする．'; then
    defaults write com.apple.dock expose-animation-duration -float 0.1
    # (none)
fi

if do_set 'Dock   : dashboard を無効にする'; then
    defaults write com.apple.dashboard mcx-disabled -bool true
    # (none)
fi

if do_set 'Dock   : Dashboard を操作スペースとして表示しない．'; then
    defaults write com.apple.dock dashboard-in-overlay -bool true
    # [システム環境設定 > Mission Control > Dashboard を操作スペースとして表示] => "ON"
fi

if do_set 'Dock   : Mission Control の操作スペースを自動的に並べ替えない．'; then
    defaults write com.apple.dock mru-spaces -bool false
    # [システム環境設定 > Mission Control > 最新の使用状況に基づいて操作スペースを自動的に並び替える] => "OFF"
fi

if do_set 'Dock   : Dock の表示/表示速度を 0 秒にする．'; then
    defaults write com.apple.dock autohide-delay -float 0
    # (none)
fi

if do_set 'Dock   : Dock の表示/非表示のアニメーション速度を 0 秒にする．'; then
    defaults write com.apple.dock autohide-time-modifier -float 0
    # (none)
fi

if do_set 'Dock   : launchpad をリセット'; then
    find ~/Library/Application\ Support/Dock -name "*.db" -maxdepth 1 -delete
    # (none)
fi

if do_set 'Dock   : 隠したアプリのDockアイコンを透過にする．'; then
    defaults write com.apple.dock showhidden -bool true
    # (none)
fi

if do_set 'Dock   : Dockにしまう時のアニメーションを「suck」にする．'; then
    defaults write com.apple.dock mineffect -string "suck"
    # (none)
fi

#if do_set 'Dock   : 起動中のアプリケーションのみ表示する．'; then
#    defaults write com.apple.dock static-only -boolean true
#    # (none)
#fi

#if do_set 'Dock   : 起動中，通知がある時のアイコンの跳ねるアニメーションを無効にする．'; then
#    defaults write com.apple.dock no-bouncing -bool true
#    # (none)
#fi



## Input

# Input - Trackpad/Mouse
if do_set 'Input : トラックパッドのナチュラル・スクロールを止める．' $MODE_MINIMAL; then
    defaults write -g com.apple.swipescrolldirection -bool false
    # [システム環境設定 > トラックパッド > スクロールとズーム > スクロールの方向 : ナチュラル] => "OFF"
fi

if do_set 'Input : トラックパッドの副ボタン機能をアクティヴにし、右下端クリックに割り当てる． ' $MODE_MINIMAL; then
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
    # [システム環境設定 > トラックパッド > ポイントオプションおよびクリックオプション > 副ボタンのクリック] = "ON"，[右下端をクリック]
fi

if do_set 'Input : マウスの副ボタン機能をアクティヴにし、右クリックに割り当てる．' $MODE_MINIMAL; then
    defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode "TwoButton"
    # [システム環境設定 > マウス > ポイントオプションおよびクリックオプション > 副ボタンのクリック] = "ON"，[右側をクリック]
fi

# Input - Keyboard
keyboard_vid=$(ioreg -n 'Apple Internal Keyboard' -r | grep -E 'idVendor' | awk '{ print $4 }')
keyboard_pid=$(ioreg -n 'Apple Internal Keyboard' -r | grep -E 'idProduct' | awk '{ print $4 }')
keyboardid="${keyboard_vid}-${keyboard_pid}-0"

#CHECK:
# Input - Keyboard - Modified key
if do_set 'Input : Caps Lock を Control キーにする．' $MODE_MINIMAL; then
  # CapsLock(30064771129) -> Control(30064771296)
  # defaults -currentHost read -g com.apple.keyboard.modifiermapping.${keyboardid}

#defaults -currentHost write -g com.apple.keyboard.modifiermapping.${keyboardid} '({HIDKeyboardModifierMappingDst = 30064771296; HIDKeyboardModifierMappingSrc = 30064771129;})'
  #ref: http://apple.stackexchange.com/questions/266665/how-to-define-an-array-with-a-single-defaults-command/266667#266667
  # [システム環境設定 > キーボード > 修飾キー > Caps Lock キー] => [^ Control]
  defaults -currentHost write -g com.apple.keyboard.modifiermapping.${keyboardid} -array-add "
    <dict>
      <key>HIDKeyboardModifierMappingDst</key>\
      <integer>30064771296</integer>\
      <key>HIDKeyboardModifierMappingSrc</key>\
      <integer>30064771129</integer>\
    </dict>
    "
fi

# Input - Keyboard - Shortcut
if do_set 'Input : Fn キーのショートカットとホットコーナーをすべて無効にする．' $MODE_MINIMAL; then
    defaults write com.apple.dock wvous-tl-corner -int 0
    defaults write com.apple.dock wvous-tl-modifier -int 0
    defaults write com.apple.dock wvous-tr-corner -int 0
    defaults write com.apple.dock wvous-tr-modifier -int 0
    defaults write com.apple.dock wvous-bl-corner -int 0
    defaults write com.apple.dock wvous-bl-modifier -int 0
    defaults write com.apple.dock wvous-br-corner -int 0
    defaults write com.apple.dock wvous-br-modifier -int 0
    # [システム環境設定]，[Mission Control] の [キーボードとマウスのショートカット] = "すべて無効"
fi

if do_set 'Input : すべての Fn キーを標準にする．' $MODE_MINIMAL; then
    defaults write -g com.apple.keyboard.fnState -bool true
    # [システム環境設定 > キーボード > キーボード > F1，F2 などのすべてのキーを標準ファンクションキーとして使用] = "ON"
fi

if do_set 'Input : すべてのコントロールを Tab キーで移動する．' $MODE_MINIMAL; then
    defaults write -g AppleKeyboardUIMode -int 3
    # [システム環境設定 > キーボード > ショートカット > フルキーボードアクセス : Tab キーを押してウィンドウやダイアログ内の操作対象を移動する機能の適用範囲] = [すべてのコントロール]
fi

if do_set 'Input : Dashbord を使わない．' $MODE_MINIMAL; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 62 "<dict><key>enabled</key><false/></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 63 "<dict><key>enabled</key><false/></dict>"
    # [システム環境設定 > キーボード > ショートカット > Mission Control] の [Dashboard を表示] = "OFF"
fi

if do_set 'Input : Mission Control を [F12] にマップする．' $MODE_MINIMAL; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 32 "
      <dict>
        <key>enabled</key>
        <true/>
        <key>value</key>
        <dict>
          <key>parameters</key>
          <array>
            <integer>65535</integer>
            <integer>111</integer>
            <integer>0</integer>
          </array>
          <key>type</key>
          <string>standard</string>
        </dict>
      </dict>
      "
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 34 "
      <dict>
        <key>enabled</key>
        <true/>
        <key>value</key>
        <dict>
          <key>parameters</key>
          <array>
            <integer>65535</integer>
            <integer>111</integer>
            <integer>131072</integer>
          </array>
          <key>type</key>
          <string>standard</string>
        </dict>
      </dict>
      "
    # [システム環境設定 > キーボード > ショートカット > Mission Control] の [Mission Control] = "ON"，[F12]
fi
# ref. https://github.com/diimdeep/dotfiles/blob/master/osx/configure/hotkeys.sh#L58

if do_set 'Input : アプリケーションウィンドウの表示を [F11] にマップする．' $MODE_MINIMAL; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 33 "
      <dict>
        <key>enabled</key>
        <true/>
        <key>value</key>
        <dict>
          <key>parameters</key>
          <array>
            <integer>65535</integer>
            <integer>103</integer>
            <integer>0</integer>
          </array>
          <key>type</key>
          <string>standard</string>
        </dict>
      </dict>
      "
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 35 "
      <dict>
        <key>enabled</key>
        <true/>
        <key>value</key>
        <dict>
          <key>parameters</key>
          <array>
            <integer>65535</integer>
            <integer>103</integer>
            <integer>131072</integer>
          </array>
          <key>type</key>
          <string>standard</string>
        </dict>
      </dict>
      "
    # [システム環境設定 > キーボード > ショートカット > Mission Control] の [アプリケーションウィンドウ] = "ON"，[F11]
fi

if do_set 'Input : デスクトップの表示を [F10] にマップする．' $MODE_MINIMAL; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 36 "
      <dict>
        <key>enabled</key>
        <true/>
        <key>value</key>
        <dict>
          <key>parameters</key>
          <array>
            <integer>65535</integer>
            <integer>109</integer>
            <integer>0</integer>
          </array>
          <key>type</key>
          <string>standard</string>
        </dict>
      </dict>
      "
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 37 "
      <dict>
        <key>enabled</key>
        <true/>
        <key>value</key>
        <dict>
          <key>parameters</key>
          <array>
            <integer>65535</integer>
            <integer>109</integer>
            <integer>131072</integer>
          </array>
          <key>type</key>
          <string>standard</string>
        </dict>
      </dict>
      "
    # [システム環境設定 > キーボード > ショートカット > Mission Control] の [デスクトップを表示] = "ON"，[F10]
fi

if do_set 'Input : [F2] でメニューを操作する．' $MODE_MINIMAL; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 7 "
      <dict>
        <key>enabled</key>
        <true/>
        <key>value</key>
        <dict>
          <key>parameters</key>
          <array>
            <integer>65535</integer>
            <integer>120</integer>
            <integer>0</integer>
          </array>
          <key>type</key>
          <string>standard</string>
        </dict>
      </dict>
      "
    # [システム環境設定 > キーボード > ショートカット > キーボード] の [メニューバーを操作対象にする] = "ON"，[F2]
fi

if do_set 'Input : [F3] でツールバーを操作する．' $MODE_MINIMAL; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 10 "
      <dict>
        <key>enabled</key>
        <true/>
        <key>value</key>
        <dict>
          <key>parameters</key>
          <array>
            <integer>65535</integer>
            <integer>99</integer>
            <integer>0</integer>
          </array>
          <key>type</key>
          <string>standard</string>
        </dict>
      </dict>
      "
    # [システム環境設定 > キーボード > ショートカット > キーボード] の [ウィンドウのツールバーを操作対象にする] = "ON"，[F3]
fi

if do_set 'Input : Spotlight のショートカットを無効にする．' $MODE_MINIMAL; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "
      <dict>
        <key>enabled</key>
        <false/>
      </dict>
      "
    # [システム環境設定 > キーボード > ショートカット > Spotlight] の [Spotlight 検索を表示] = "OFF"
fi

if do_set 'Input : 入力ソースの切り替え “US-ひらがな”は command-space で行う．' $MODE_MINIMAL; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60  "
      <dict>
        <key>enabled</key>
        <true/>
        <key>value</key>
        <dict>
          <key>parameters</key>
          <array>
            <integer>65535</integer>
            <integer>49</integer>
            <integer>1048576</integer>
          </array>
          <key>type</key>
          <string>standard</string>
        </dict>
      </dict>
      "
    # [システム環境設定 > キーボード > 入力ソース] の [前の入力ソースを選択] = "ON", [⌘スペース]
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "
      <dict>
        <key>enabled</key>
        <false/>
      </dict>
      "
    # [システム環境設定 > キーボード > 入力ソース] の [入力メニューの次のソースを選択] = "OFF"
fi

# Input - Inputmethod JapaneseIM
if do_set 'Input : 句読点は "．" と "，" を使う．'; then
    defaults write com.apple.inputmethod.Kotoeri JIMPrefPunctuationTypeKey -int 3
    # [システム環境設定 > キーボード > 入力ソース > 句読点の種類] = "．と，"
fi

if do_set 'Input : スラッシュはスラッシュ．' $MODE_MINIMAL; then
    defaults write com.apple.inputmethod.Kotoeri JIMPrefCharacterForSlashKey -int 0
    # [システム環境設定 > キーボード > 入力ソース > "/"キーで入力する文字] = "/ (スラッシュ)"
fi

if do_set 'Input : バックスラッシュはバックスラッシュ．' $MODE_MINIMAL; then
    defaults write com.apple.inputmethod.Kotoeri 'JIMPrefCharacterForYenKey' -int 1
    # [システム環境設定 > キーボード > 入力ソース > "\"キーで入力する文字] = "\ (バックスラッシュ)"
fi

if do_set 'Input : 数字は常に半角．' $MODE_MINIMAL; then
    defaults write com.apple.inputmethod.Kotoeri 'JIMPrefFullWidthNumeralCharactersKey' -bool false
    # [システム環境設定 > キーボード > 入力ソース > 数字を全角入力] = "オフ"
fi

if do_set 'Input : 言語切り替えは “US-ひらがな” のみ (カタカナなどは含まない)' $MODE_MINIMAL; then
    if defaults read ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources >/dev/null 2>&1; then
        defaults delete ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources
    fi
    defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '
      {"Bundle ID" = "com.apple.inputmethod.Kotoeri"; "Input Mode" = "com.apple.inputmethod.Japanese"; InputSourceKind = "Input Mode";}'
    defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '
      {"Bundle ID" = "com.apple.inputmethod.Kotoeri"; "Input Mode" = "com.apple.inputmethod.Roman";InputSourceKind = "Input Mode";}'
    defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '
      {"Bundle ID" = "com.apple.inputmethod.Kotoeri"; InputSourceKind = "Keyboard Input Method";}'
    defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '
      {"Bundle ID" = "com.apple.50onPaletteIM"; InputSourceKind = "Non Keyboard Input Method";}'
    # [システム環境設定 > キーボード > 入力ソース > 入力モード > カタカナ] = "OFF"
fi

# if do_set 'Input : 記号はシングルバイトでの入力にする．'; then
#     myecho "${ESC_YLW}NOTE: この設定は rootless 設定を無効にした上で行う費用があります．\nSystem Integrity Protection を無効にしたうえで osx4input.sh を実行してください．${ESC_OFF}"
# fi

if do_set 'Input : ライブ変換，要らないっ．' $MODE_MINIMAL; then
    defaults write -g JIMPrefLiveConversionKey -bool false
    # [システム環境設定 > キーボード > 入力ソース > ライブ変換] => "OFF"
fi


#
# misc
#

if do_set 'Time Machine: ローカルスナップショットを無効にする．'; then
    sudo tmutil disablelocal
    # (none)
fi

if do_set 'Time Machine: 「Time Machine でバックアップを作成するために “(HD Name)” を使用しますか?」を出さない．'; then
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
    # (none)
fi

if do_set 'Time Machine: ローカルスナップショットを無効にする．'; then
    hash tmutil &> /dev/null && sudo tmutil disablelocal
    # (none)
fi

#if do_set 'Time Machine: バッテリー電源が繋がっている時．'; then
#    defaults write com.apple.TimeMachine RequiresACPower 0
#    # (none)
#fi


## spotlight
if do_set 'Spotlight: 検索対象のデフォルトは、カレントフォルダ．'; then
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    # (none)
fi


## updater
if do_set 'Updater: アップデートチェックは毎日．'; then
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
    # (none)
fi


#
# Fin
#

#TODO:
echo -e "${ESC_BOLD}設定を有効にするために各コントロールを再起動する．${ESC_OFF}"
for app in cfprefsd Finder Dock SystemUIServer JapaneseIM; do
  killall "$app" >/dev/null 2>&1
done


## fin & Please restart
echo -e "

----------------------------------------------------------------------
                     Process has been completed.
"

if [ $MODE_IS -eq $MODE_MINIMAL ]; then
  echo -e "${ESC_BOLD}
             You should RESTART to activate the settings.
               (c.g., [Command] + [Control] + [EJECT])
           ${ESC_OFF}


"
fi

