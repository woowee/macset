#!/bin/sh

######################################################################
# This script been referred to ;
#  - [dotfiles .osx at master - mathiasbynens dotfiles](https://github.com/mathiasbynens/dotfiles/blob/master/.osx)
#  - [OSX For Hackers](https://gist.github.com/DAddYE/2108403)
# Thank you very much mathiasbynens, DAddYE
######################################################################

### Reference # https://github.com/mathiasbynens/dotfiles/blob/master/.osx
# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

### Reference # https://gist.github.com/DAddYE/2108403
# This is a script with usefull tips taken from:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.osx
#
# Run in interactive mode with:
#   $ sh -c "$(curl -sL https://raw.github.com/gist/2108403/hack.sh)"
#
# or run it without prompt questions:
#   $ sh -c "$(curl -sL https://raw.github.com/gist/2108403/hack.sh)" -s silent
#
# Please, share your tips commenting here:
#   https://gist.github.com/2108403
#
# Author: @DAddYE
# Thanks to: @mathiasbynens
#
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

    if [ "$auto" == "Y" ]; then
      echo
    else
      read yn
    fi

    if [ -z "$yz" ]; then
      yn=$default
    fi

    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
    esac
  done
}


## Trackpad
if ask 'トラックパッドのナチュラル・スクロールを止める．' Y; then
    defaults write -g com.apple.swipescrolldirection -bool false
    # [システム環境設定 > トラックパッド > スクロールとズーム > スクロールの方向 : ナチュラル] => "OFF"
fi


## Finder
if ask 'ファイルの拡張子を表示する．' Y; then
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    # [Finder の環境設定 > 詳細 > すべてのファイル名拡張子を表示] => "ON"
fi

if ask 'スクリーンショットでついてくるウィンドウの影を抑制．' Y; then
    defaults write com.apple.screencapture disable-shadow -bool true
    # (none)
fi

if ask 'スクリーンショットの保存先．' Y; then
    dir_screenshoots="~/Pictures/screenshoots"
    [ ! -e "${dir_screenshoots}" ] && mkdir "${dir_screenshoots}"
    defaults write com.apple.screencapture location -string "${dir_screenshoots}"
    # (none)
fi

if ask '保存ダイアログの拡張．' Y; then
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    # (none)
fi

if ask '.DS_Store を作らない．' Y; then
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    # (none)
fi


## Dock
if ask 'グリッド表示時の Dock のスタック上のマウスオーバー時、ハイライトする．' Y; then
    defaults write com.apple.dock mouse-over-hilite-stack -bool true
    # (none)
fi

if ask 'Dock の大きさをセットする。(36)' Y; then
    defaults write com.apple.dock tilesize -int 36
    # [システム環境設定 > Dock > 大きさ] = sld[サイズ] 1/8 くらい
fi

if 'Dock への drag & drop で起動/開く機能 (スプリングフォルダの dock 版) を利用する．' Y; then
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
    # (none)
fi

if 'Dock の起動しているアプリケーションにインジケータ・ランプを表示する' Y; then
    defaults write com.apple.dock show-process-indicators -bool true
    # [システム環境設定 > Dock > 起動済みのアプリケーションにインジケータ・ランプを表示] => "オン"
fi

if ask 'Dock のコンテンツを真っ新にする．' Y; then
    defaults write com.apple.dock persistent-apps -array ""
    # (none)
fi

if ask '起動中、またはステータスが変わった Dock のアプリケーションをアニメーションさせない．' Y; then
    defaults write com.apple.dock launchanim -bool false
    # [システム環境設定 > Dock > 起動中のアプリケーションをアニメーションで表示] => "OFF"
fi

if ask 'mission control への移行アニメーション速度 を 0.1 秒にする．' Y; then
    defaults write com.apple.dock expose-animation-duration -float 0.1
    # (none)
fi

if ask 'dashboard を無効にする' Y; then
    defaults write com.apple.dashboard mcx-disabled -bool true
    # (none)
fi

if ask 'Dashboard を操作スペースとして表示しない．' Y; then
    defaults write com.apple.dock dashboard-in-overlay -bool true
    # [システム環境設定 > Mission Control > Dashboard を操作スペースとして表示] => "ON"
fi

if ask 'Mission Control の操作スペースを自動的に並べ替えない．' Y; then
    defaults write com.apple.dock mru-spaces -bool false
    # [システム環境設定 > Mission Control > 最新の使用状況に基づいて操作スペースを自動的に並び替える] => "OFF"
fi

if ask 'Dock の表示/表示速度を 0 秒にする．' Y; then
    defaults write com.apple.dock autohide-delay -float 0
    # (none)
fi

if ask 'Dock の表示/非表示のアニメーション速度を 0 秒にする．' Y; then
    defaults write com.apple.dock autohide-time-modifier -float 0
    # (none)
fi

if ask 'Dock を隠す．' Y; then
    defaults write com.apple.dock autohide -bool true
    # [システム環境設定 > Dock > Dock を自動的に隠す/表示] => "ON"
fi

if ask 'launchpad をリセット' Y; then
    find ~/Library/Application\ Support/Dock -name "*.db" -maxdepth 1 -delete
    # (none)
fi


## Keyboard
keyboardid=$(ioreg -n IOHIDKeyboard -r | grep -E 'VendorID"|ProductID' | awk '{ print $4 }' | paste -s -d'-\n' -)'-0'
# Modified key
if ask 'Caps Lock を Control キーにする．' Y; then
    # CapsLock(2) -> Control(0)
    defaults -currentHost delete -g com.apple.keyboard.modifiermapping.${keyboardid}
    defaults -currentHost write -g com.apple.keyboard.modifiermapping.${keyboardid} -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>2</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>'
    # [システム環境設定 > キーボード > 修飾キー > Caps Lock キー] => [^ Control]
fi

# Shortcut
if ask 'Fn キーのショートカットとホットコーナーをすべて無効にする．' Y; then
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

if ask 'すべての Fn キーを標準にする．' Y; then
    defaults write -g com.apple.keyboard.fnState -bool true
    # [システム環境設定 > キーボード > キーボード > F1、F2 などのすべてのキーを標準ファンクションキーとして使用] => "ON"
fi

if ask 'すべてのコントロールを Tab キーで移動する．' Y; then
    defaults write -g AppleKeyboardUIMode -int 3
    # [システム環境設定 > キーボード > キーボードショートカット > フルキーボードアクセス : Tab キーを押してウィンドウやダイアログ内の操作対象を移動する機能の適用範囲] => [すべてのコントロール]
fi

if ask 'Dashbord を使わない．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 62 "<dict><key>enabled</key><false/></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 63 "<dict><key>enabled</key><false/></dict>"
    # [システム環境設定 > キーボード > Mission Control > Dashboard を表示] => "OFF"
fi

if ask 'Mission Control を [F12] にマップする．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 32 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>111</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 34 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>111</integer><integer>131072</integer></array><key>type</key><string>standard</string></dict></dict>"
    # [システム環境設定 > キーボード > Mission Control > Mission Control] = "ON"，[F12]
fi

if ask 'アプリケーションウィンドウの表示を [F11] にマップする．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 33 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>103</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 35 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>103</integer><integer>131072</integer></array><key>type</key><string>standard</string></dict></dict>"
    # [システム環境設定 > キーボード > Mission Control > アプリケーションウィンドウ] = "ON"，[F11]
fi

if ask 'デスクトップの表示を [F10] にマップする．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 36 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>109</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 37 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>109</integer><integer>131072</integer></array><key>type</key><string>standard</string></dict></dict>"
    # [システム環境設定 > キーボード > Mission Control > デスクトップを表示] = "ON"，[F10]
fi

if ask '[F2] でメニューを操作する．' Y; then
e   defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 7 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>120</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
    # [システム環境設定 > キーボード > キーボードと文字入力 > メニューバーを操作対象にする] = "ON"，[F2]
fi

if ask '[F3] でツールバーを操作する．' Y; then
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 10 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>99</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
    # [システム環境設定 > キーボード > キーボードと文字入力 > ウィンドウのツールバーを操作対象にする] = "ON"，[F3]
fi

## Inputmethod (Kotoeri)
if ask '数字，記号はシングルバイトで入力する．' Y; then
    # [ことえり環境設定 > 文字入力 > 数字を全角で入力]
    /usr/libexec/Plistbuddy -c "set :zhnm 0"  ~/Library/Preferences/com.apple.inputmethod.Kotoeri.plist
    # ブランク(スペース)，記号
    # can't set by plistbuddy command, why?
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '" "' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"("' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '")"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"["' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"]"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"{"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"}"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"!"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"\\"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"#"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"$"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"%"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"&"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"*"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"+"' -bool FALSE
    # defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '","' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"-"' -bool FALSE
    # defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"."' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"/"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '":"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '";"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"<"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"="' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '">"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"?"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"@"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"^"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"_"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"`"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"|"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"~"' -bool FALSE
    defaults write com.apple.inputmethod.Kotoeri 'zhsy' -dict-add '"\U00a5"' -bool FALSE
fi

## sc

### Shell (Zsh)
# -> manifest file @ boxen

### Fin
if ask "Kill affected applications" Y; then
  for app in Safari Finder Dock Mail SystemUIServer Kotoeri; do
    killall "$app" >/dev/null 2>&1
  done
  echo
  echo "** \033[33mSome changes needs a reboot to take effect\033[0m **"
  echo
fi
