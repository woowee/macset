#!/bin/bash -u

set -e
######################################################################
# This script been referred to ;
#  - [dotfiles .osx at master - mathiasbynens dotfiles](https://github.com/mathiasbynens/dotfiles/blob/master/.osx)
#  - [OSX For Hackers](https://gist.github.com/DAddYE/2108403)
# Thank you very much mathiasbynens, DAddYE
######################################################################

# Your Configration {{
# スクリーンショットの保存先
dir_screenshoots="${HOME}/Pictures/screenshoots"
# }} Your Configration


case $1 in
  "-s" | "-y" | "--silent" | "silent" )
    echo "Running in silent mode..."
    auto=Y
    shift 1
    ;;
  *)
    auto=N
    if [ ! -t 0 ]; then
      echo "Interactive mode needs terminal!" >&2
      exit 1
    fi
    ;;
esac

function ask {
  while true; do

    if [ "$2" == "Y" ]; then
      prompt="\033[1;32mY\033[0m/n"
      default=Y
    elif [ "$2" == "N" ]; then
      prompt="y/\033[1;32mN\033[0m"
      default=N
    else
      prompt="y/n"
      default=
    fi

    printf "$1 [$prompt] "

    yn=""
    if [ "$auto" == "Y" ]; then
        echo
    else
        read yn
    fi

    if [ -z "$yn" ]; then
        yn=$default
    fi

    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
    esac
  done
}


#
# PREPARE
#
filename_func=$(dirname $0)/functions.sh
if [ ! -e ${filename_func} ]; then
    echo -e "\033[1;32m$(basename $0)==>\033[0m Cannot run because some necessary information or files is missing. Check your execution enviroment. (Is there '${filename_func}' ?)"
    exit 1
fi
source ${filename_func}



#
# SET OSX DEFAULT
#

## Finder

if ask 'Finder: スクリーンショットでついてくるウィンドウの影を抑制．' Y; then
    defaults write com.apple.screencapture disable-shadow -bool true
    # (none)
fi

if ask 'Finder: スクリーンショットの保存先．' Y; then
    [ ! -e "${dir_screenshoots}" ] && mkdir "${dir_screenshoots}"
    defaults write com.apple.screencapture location -string "${dir_screenshoots}"
    # (none)
fi

if ask 'Finder: .DS_Store を作らない．' Y; then
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    # (none)
fi

if ask 'Finder: Finderのタイトルバーにフルパスを表示する．' Y; then
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    # (none)
fi

if ask 'Finder: 新規 Finder ウィンドウのデフォルトは `$HOME` ホームディレクトリ．' Y; then
    defaults write com.apple.finder NewWindowTarget -string "PfHm"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
    # Finder > 環境設定 > 一般 > 新規 Findoer ウィンドウを表示] = `$HOME`
fi


## Dock

if ask 'Dock: Dock の位置を下にする．' Y; then
    defaults write com.apple.dock orientation -string "bottom"
    # [システム環境設定 > Dock > 画面上の位置] => "下"
    #defaults write com.apple.dock pinning -string start
    # (none, osx yosemite になって無くなった様子．ref.https://discussions.apple.com/thread/6600902)
fi

if ask 'Dock: Dock を隠す．' Y; then
    defaults write com.apple.dock autohide -bool true
    # [システム環境設定 > Dock > Dock を自動的に隠す/表示] => "ON"
fi



## Input

# Input - Trackpad/Mouse
if ask 'Input: トラックパッドのナチュラル・スクロールを止める．' Y; then
    defaults write -g com.apple.swipescrolldirection -bool false
    # [システム環境設定 > トラックパッド > スクロールとズーム > スクロールの方向 : ナチュラル] => "OFF"
fi

if ask 'Input: トラックパッドの副ボタン機能をアクティヴにし、右下端クリックに割り当てる... ' Y; then
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
    # [システム環境設定 > トラックパッド > ポイントオプションおよびクリックオプション > 副ボタンのクリック] = "ON"，[右下端をクリック]
fi

if ask 'マウスの副ボタン機能をアクティヴにし、右クリックに割り当てる．' Y; then
    defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode "TwoButton"
    # [システム環境設定 > マウス > ポイントオプションおよびクリックオプション > 副ボタンのクリック] = "ON"，[右側をクリック]
fi

# Input - Keyboard
keyboard_vid=$(ioreg -n 'Apple Internal Keyboard' -r | grep -E 'idVendor' | awk '{ print $4 }')
keyboard_pid=$(ioreg -n 'Apple Internal Keyboard' -r | grep -E 'idProduct' | awk '{ print $4 }')
keyboardid="${keyboard_vid}-${keyboard_pid}-0"

# Input - Keyboard - Modified key
if ask 'Input: Caps Lock を Control キーにする．' Y; then
    # CapsLock(2) -> Control(0)
    # defaults -currentHost delete -g com.apple.keyboard.modifiermapping.${keyboardid}
    defaults -currentHost write -g com.apple.keyboard.modifiermapping.${keyboardid} -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>2</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>'
    # [システム環境設定 > キーボード > 修飾キー > Caps Lock キー] => [^ Control]
fi

# Input - Keyboard - Shortcut
if ask 'Input: Fn キーのショートカットとホットコーナーをすべて無効にする．' Y; then
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

if ask 'Input: すべての Fn キーを標準にする．' Y; then
    defaults write -g com.apple.keyboard.fnState -bool true
    # [システム環境設定 > キーボード > キーボード > F1，F2 などのすべてのキーを標準ファンクションキーとして使用] = "ON"
fi

if ask 'Input: すべてのコントロールを Tab キーで移動する．' Y; then
    defaults write -g AppleKeyboardUIMode -int 3
    # [システム環境設定 > キーボード > ショートカット > フルキーボードアクセス : Tab キーを押してウィンドウやダイアログ内の操作対象を移動する機能の適用範囲] = [すべてのコントロール]
fi

if ask 'Input: Dashbord を使わない．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 62 "<dict><key>enabled</key><false/></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 63 "<dict><key>enabled</key><false/></dict>"
    # [システム環境設定 > キーボード > ショートカット > Mission Control] の [Dashboard を表示] = "OFF"
fi

if ask 'Input: Mission Control を [F12] にマップする．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 32 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>111</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 34 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>111</integer><integer>131072</integer></array><key>type</key><string>standard</string></dict></dict>"
    # [システム環境設定 > キーボード > ショートカット > Mission Control] の [Mission Control] = "ON"，[F12]
fi

if ask 'Input: アプリケーションウィンドウの表示を [F11] にマップする．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 33 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>103</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 35 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>103</integer><integer>131072</integer></array><key>type</key><string>standard</string></dict></dict>"
    # [システム環境設定 > キーボード > ショートカット > Mission Control] の [アプリケーションウィンドウ] = "ON"，[F11]
fi

if ask 'Input: デスクトップの表示を [F10] にマップする．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 36 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>109</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 37 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>109</integer><integer>131072</integer></array><key>type</key><string>standard</string></dict></dict>"
    # [システム環境設定 > キーボード > ショートカット > Mission Control] の [デスクトップを表示] = "ON"，[F10]
fi

if ask 'Input: [F2] でメニューを操作する．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 7 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>120</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
    # [システム環境設定 > キーボード > ショートカット > キーボード] の [メニューバーを操作対象にする] = "ON"，[F2]
fi

if ask 'Input: [F3] でツールバーを操作する．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 10 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>99</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
    # [システム環境設定 > キーボード > ショートカット > キーボード] の [ウィンドウのツールバーを操作対象にする] = "ON"，[F3]
fi

if ask 'Input: Spotlight のショートカットを無効にする．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"
    # [システム環境設定 > キーボード > ショートカット > Spotlight] の [Spotlight 検索を表示] = "OFF"
fi

if ask 'Input: 入力ソースの切り替え “US-ひらがな”は command-space で行う．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60  "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>"
    # [システム環境設定 > キーボード > 入力ソース] の [前の入力ソースを選択] = "ON", [⌘スペース]
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "<dict><key>enabled</key><false/></dict>"
    # [システム環境設定 > キーボード > 入力ソース] の [入力メニューの次のソースを選択] = "OFF"
fi

# Input - Inputmethod JapaneseIM
if ask 'Input: バックスラッシュはバックスラッシュ．' Y; then
    defaults write com.apple.inputmethod.Kotoeri 'JIMPrefCharacterForYenKey' -int 1
    # [システム環境設定 > キーボード > 入力ソース > "\"キーで入力する文字] = "\ (バックスラッシュ)"
fi

if ask 'Input: 言語切り替えは “US-ひらがな” のみ (カタカナなどは含まない)' Y; then
    if defaults read ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources >/dev/null 2>&1; then
        defaults delete ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources
    fi
    defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";"Input Mode" = "com.apple.inputmethod.Japanese"; InputSourceKind = "Input Mode";}'
    defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";"Input Mode" = "com.apple.inputmethod.Roman";InputSourceKind = "Input Mode";}'
    defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";InputSourceKind = "Keyboard Input Method";}'
    defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.50onPaletteIM";InputSourceKind = "Non Keyboard Input Method";}'
    # [システム環境設定 > キーボード > 入力ソース > 入力モード > カタカナ] = "OFF"
fi

if ask 'Input: 数字，記号はシングルバイトでの入力にする．' Y; then
    execho "${esc_ylw}NOTE: rootless 設定を無効にしたうえで行う必要があります．\n `csrutil disable` して再起動し，System Integrity Protection を無効にしたうえで osx4input.sh を実行してください．${esc_off}"
fi

if ask 'Input: ライブ変換，要らないっ．' Y; then
    defaults write -g JIMPrefLiveConversionKey -bool false
    # [システム環境設定 > キーボード > 入力ソース > ライブ変換] => "OFF"
fi


#
# misc
#

## menubar
if ask 'Finder: メニューバー設定．' Y; then
    #TODO: wait, wait, wait... `com.apple.systemuiserver.*.〜` ?! a...aster is whaaaat ?!
    # for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
    #     defaults write "${domain}" dontAutoLoad -array \
    #     "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
    #     "/System/Library/CoreServices/Menu Extras/User.menu"
    # done
    defaults write com.apple.systemuiserver menuExtras -array \
        "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
        "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
        "/System/Library/CoreServices/Menu Extras/Volume.menu" \
        "/System/Library/CoreServices/Menu Extras/Battery.menu" \
        "/System/Library/CoreServices/Menu Extras/Clock.menu"
fi



#
# fin
#

execho "${esc_ylw}DONE: MacOS X Defaults Settings${esc_off}"
