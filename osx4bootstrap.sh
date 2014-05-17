#!/bin/bash -u

set -e

#sudo -v
#while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

dir_current=$(dirname $0)
cd ${dir_current}

#
# check file configration
#
filename_conf="config.sh"
filename_func="functions.sh"

filename_check="check4running.sh"
if [ ! -e "${dir_current}/${filename_check}" ]; then
    echo -e "\033[1;32m$(basename $0)==>\033[0m Cannot run because some necessary information or files is missing. Check your execution enviroment. (Is there '${dir_current}/${filename_check}' ?)"
    exit 1
fi

${dir_current}/${filename_check} ${filename_conf} ${filename_func}

# read functions
source ${dir_current}/${filename_func}



#
# OSX Settings
#

# Trackpad
execho '  トラックパッドのナチュラル・スクロールを止める... '
defaults write -g com.apple.swipescrolldirection -bool false
# [システム環境設定 > トラックパッド > スクロールとズーム > スクロールの方向 : ナチュラル] = "OFF"

execho '  トラックパッドの副ボタン機能をアクティヴにし、右下端クリックに割り当てる... '
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
# [システム環境設定 > トラックパッド > ポイントオプションおよびクリックオプション > 副ボタンのクリック] = "ON"，[右下端をクリック]

execho '  マウスの副ボタン機能をアクティヴにし、右クリックに割り当てる... '
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode "TwoButton"
# [システム環境設定 > マウス > ポイントオプションおよびクリックオプション > 副ボタンのクリック] = "ON"，[右側をクリック]

# Dock
execho '  Dock を隠す... '
defaults write com.apple.dock autohide -bool true
# [システム環境設定 > Dock > Dock を自動的に隠す/表示] => "ON"

# Finder
execho '  ファイルの拡張子を表示する... '
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# [Finder の環境設定 > 詳細 > すべてのファイル名拡張子を表示] => "ON"

# Keyboard
keyboardid=$(ioreg -n IOHIDKeyboard -r | grep -E 'VendorID"|ProductID' | awk '{ print $4 }' | paste -s -d'-\n' -)'-0'
execho '  Caps Lock を Control キーにする... '
# CapsLock(2) -> Control(0)
defaults -currentHost write -g com.apple.keyboard.modifiermapping.${keyboardid} -array '<dict><key>HIDKeyboardModifierMappingDst</key><integer>2</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>'
# [システム環境設定 > キーボード > 修飾キー > Caps Lock キー] => [^ Control]

execho '  Fn キーのショートカットとホットコーナーをすべて無効にする... '
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0
# [システム環境設定]，[Mission Control] の [キーボードとマウスのショートカット] = "すべて無効"

execho '  すべての Fn (ファンクション) キーを標準にする... '
defaults write -g com.apple.keyboard.fnState -bool true
# [システム環境設定 > キーボード > キーボード > F1、F2 などのすべてのキーを標準ファンクションキーとして使用] => "ON"

execho '  すべてのコントロールを Tab キーで移動する... '
defaults write -g AppleKeyboardUIMode -int 3
# [システム環境設定 > キーボード > キーボードショートカット > フルキーボードアクセス : Tab キーを押してウィンドウやダイアログ内の操作対象を移動する機能の適用範囲] => [すべてのコントロール]

execho '  Dashbord を使わない... '
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 62 "<dict><key>enabled</key><false/></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 63 "<dict><key>enabled</key><false/></dict>"
# [システム環境設定 > キーボード > Mission Control > Dashboard を表示] => "OFF"

execho '  Mission Control を [F12] にマップする... '
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 32 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>111</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 34 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>111</integer><integer>131072</integer></array><key>type</key><string>standard</string></dict></dict>"
# [システム環境設定 > キーボード > Mission Control > Mission Control] = "ON"，[F12]

execho '  アプリケーションウィンドウの表示を [F11] にマップする... '
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 33 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>103</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 35 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>103</integer><integer>131072</integer></array><key>type</key><string>standard</string></dict></dict>"
# [システム環境設定 > キーボード > Mission Control > アプリケーションウィンドウ] = "ON"，[F11]

execho '  デスクトップの表示を [F10] にマップする... '
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 36 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>109</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 37 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>109</integer><integer>131072</integer></array><key>type</key><string>standard</string></dict></dict>"
# [システム環境設定 > キーボード > Mission Control > デスクトップを表示] = "ON"，[F10]

execho '  [F2] でメニューを操作する... '
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 7 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>120</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
# [システム環境設定 > キーボード > キーボードと文字入力 > メニューバーを操作対象にする] = "ON"，[F2]

execho '  [F3] でツールバーを操作する... '
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 10 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>99</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
# [システム環境設定 > キーボード > キーボードと文字入力 > ウィンドウのツールバーを操作対象にする] = "ON"，[F3]

# Inputmethod (Kotoeri)
execho '  言語切り替えは “US-ひらがな” のみ (カタカナなどは含まない)... '

if defaults read ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources >/dev/null 2>&1; then
    defaults delete ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources
fi
defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";"Input Mode" = "com.apple.inputmethod.Japanese"; InputSourceKind = "Input Mode";}'
defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";"Input Mode" = "com.apple.inputmethod.Japanese.placename";InputSourceKind = "Input Mode";}'
defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";"Input Mode" = "com.apple.inputmethod.Roman";InputSourceKind = "Input Mode";}'
defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";"Input Mode" = "com.apple.inputmethod.Japanese.firstname";InputSourceKind = "Input Mode";}'
defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";"Input Mode" = "com.apple.inputmethod.Japanese.lastname";InputSourceKind = "Input Mode";}'
defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";InputSourceKind = "Keyboard Input Method";}'

execho '  数字，記号はシングルバイトで入力する... '
# [ことえり環境設定 > 文字入力 > 数字を全角で入力]
#/usr/libexec/Plistbuddy -c "set :zhnm 0"  ~/Library/Preferences/com.apple.inputmethod.Kotoeri.plist
defaults write com.apple.inputmethod.Kotoeri 'zhnm' -int 0

#maverick で無くなった。っぽい?
#execho '記号への勝手な変換機能は要らない... '
#    /usr/libexec/Plistbuddy -c "set :NSUserReplacementItemsEnabled bool false" ~/Library/Preferences/.GlobalPreferences.plist
#    /usr/libexec/Plistbuddy -c "set :WebAutomaticTextReplacementEnabled bool false" ~/Library/Preferences/.GlobalPreferences.plist
#    # [システム環境設定 > 言語とテキスト > テキスト > 記号とテキストの置換を使用] = "OFF"

execho '  スペルチェック機能は要らない... '
defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"
# [システム環境設定 > 言語とテキスト > テキスト > 記号とテキストの置換を使用] = "OFF"

execho '  スペース、括弧は (できるものだけでも) シングルバイトで入力する... '
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

#fin
execho "${esc_ylw}DONE: MacOS X Defaults Settings${esc_off}"
