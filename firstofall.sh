#!/bin/bash -u

set -e

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

dir_current=$(dirname $0)
cd ${dir_current}

# tmp (as a work dir)
dir_tmp="${HOME}/tmp"
[ -e ${dir_tmp} ] || mkdir -p ${dir_tmp}

# config.sh
file_conf="${dir_tmp}/config.sh"
if [ ! -e "${file_conf}" ]; then
    cp -f ${dir_current}/config.sh.tmp ${dir_tmp}/config.sh
fi

if [ ! -e "${file_conf}" -o ! -s "${file_conf}" ]; then
    echo -e "there is not your config file. exit this process.\ncheck your configration file; ${file_conf}" 1>&2

    cp -i ${dir_current}/config.sh.tmp ${dir_tmp}/config.sh
    exit 1
fi

source "${file_conf}"

MyCOMPUTERNAME="${COMPUTERNAME}"
MyHOSTNAME="${HOSTNAME}"
MyLOCALHOSTNAME="${LOCALHOSTNAME}"

MyGITHUB_EMAIL="${GITHUB_USERNAME}"
MyGITHUB_USERNAME="${GITHUB_EMAIL}"

# functions.sh
if [ -e ${dir_current}/functions.sh ]; then
    source ${dir_current}/functions.sh
else
    echo "there is no function.sh. check it." 1>&2
    exit 1
fi

#
# FUNCTIONS {
#

## Computer Account
set_systeminfo()
{
    ask_inputvalue "  Enter your computer name   : " MyCOMPUTERNAME
    ask_inputvalue "  Enter your hostname        : " MyHOSTNAME
    ask_inputvalue "  Enter your local host name : " MyLOCALHOSTNAME
    echo ""
}
confirm_systeminfo()
{
    choice="[a(Apply)/r(Redo)/x(eXit this work.)] : "
    msg="$1 ${choice}"

    while true; do
        printf "${msg}"
        read res

        case "${res}" in
            a) return 0;;
            r)
                echo "Set your system information."
                set_systeminfo

                echo "Check the contents ..."
                echo "  - Computer Name   : ${MyCOMPUTERNAME}"
                echo "  - Hostname        : ${MyHOSTNAME}.local"
                echo "  - Local Host Name : ${MyLOCALHOSTNAME}"
                echo ""
                confirm_systeminfo "${msg}"
                return 0;;
            x)
                return 1;;
            *)
                echo "I can not read your input..."
                confirm_systeminfo "${msg}"
        esac
    done
}

## GitHub account
set_githubaccountinfo()
{
    ask_inputvalue "  Enter your email address registered with Github : " MyGITHUB_EMAIL
    ask_inputvalue "  Enter your Github user name                     : " MyGITHUB_USERNAME
    echo ""
}
confirm_githubaccountinfo()
{
    choice="[a(Apply)/r(Redo)/x(eXit this work.)] : "
    msg="$1 ${choice}"

    while true; do
        printf "${msg}"
        read res

        case "${res}" in
            a) return 0;;
            r)
                echo "Tell me your information of Github."
                set_githubaccountinfo

                echo "Check the contents ..."
                echo "  - E-mail address  : ${MyGITHUB_EMAIL}"
                echo "  - User Name       : ${MyGITHUB_USERNAME}"
                echo ""
                confirm_githubaccountinfo "${msg}"
                return 0;;
            x)
                return 1;;
            *)
                echo "I can note read your input..."
                confirm_githubaccountinfo "${msg}"
        esac
    done
}

#
# } FUNCTIONS
#



#
# Read info
#
if [ -e "${file_conf}" ] && [ -s "${file_conf}" ]; then
    source "${file_conf}"

    MyCOMPUTERNAME=${COMPUTERNAME}
    MyHOSTNAME=${HOSTNAME}
    MyLOCALHOSTNAME=${LOCALHOSTNAME}

    MyGITHUB_USERNAME=${GITHUB_USERNAME}
    MyGITHUB_EMAIL=${GITHUB_EMAIL}

else
    echo -e "there is not your config file. exit this process.\ncheck your configration file; ${file_conf}" 1>&2

    # this case "No", exit the process...
    cat << EOF > "${file_conf}"
#!/bin/bash

# Computer Account Settings
COMPUTERNAME=
HOSTNAME=
LOCALHOSTNAME=
# GitHub Account Settings
GITHUB_USERNAME=
GITHUB_EMAIL=
EOF
    exit 1
fi



#
# Systen Settings
#
echo -e "\033[1m######################### System Information #########################\033[0m"
if ask_yesno "Do you want to set the system information ?"; then

    cat << DATA
Check the contents ... ;
  - Computer Name   : ${MyCOMPUTERNAME}
  - Hostname        : ${MyHOSTNAME}.local
  - Local Host Name : ${MyLOCALHOSTNAME}

DATA
    confirm_systeminfo "Are you sure want to set using above infomation?"

    sudo scutil --set ComputerName "${MyCOMPUTERNAME}"
    sudo scutil --set HostName "${MyHOSTNAME}.local"
    sudo scutil --set LocalHostName "${MyLOCALHOSTNAME}"

fi



#
# Generating SSH Keys for Github
#
echo -e "\033[1m############################### GitHub ###############################\033[0m"
if ask_yesno "Do you generate a SSH key for GitHub ?"; then
    MySSH_KEYNAME="github_rsa"
    MySSH_FILE="${HOME}/.ssh/${MySSH_KEYNAME}"

    cat << DATA
Check the contents ...
  - E-mail address  : ${MyGITHUB_EMAIL}
  - User Name       : ${MyGITHUB_USERNAME}

DATA

    # generating
    ssh-keygen -t rsa -f ${MySSH_FILE} -C "${MyGITHUB_EMAIL}"
    # save the key (/c/Users/you/.ssh/id_rsa): ${HOME}/.ssh/github_rsa

    # % Enter passphrase (empty for no passphrase): *****
    # % Enter same passphrase again: *****

    # add your new key to the ssh-agent
    ssh-add ${MySSH_FILE}

    # Copies the contents of the id_rsa.pub file to your clipboard
    pbcopy < "${MySSH_FILE}.pub"
    sudo chmod 600 "${MySSH_FILE}.pub"    # just in case...'

    confirm_githubaccountinfo "Are you sure want to set using above infomation for your GitHub?"

    echo ""
    echo -e "ok, now open browser, \033[1;4;32m\"Safari\"\033[0m just now ?"
    ask_confirm "you should register your ssh pub key to your account settings of github.\n"

    open -a Safari "https://github.com/settings/ssh"

    echo -e "when you finish settings it, then type '\033[1;4mdone\033[0m'."
    while true; do
        read res
        if [ "${res}" == "done" ]; then
            break
        else
            echo "finish settings? so type 'done'."
        fi
    done

    # make config file
    cat << EOF > "${HOME}/.ssh/config"
Host github.com
Hostname github.com
Identityfile ${MySSH_FILE}
EOF

    #
    ssh -T git@github.com &&:

    # Are you sure you want to continue connecting (yes/no)?
    #
    # Hi username! You've successfully authenticated, but GitHub does not provide shell access.

    # to set your account's default identity.
    # Omit --global to set the identity only in this repository.
    git config --global user.name "${MyGITHUB_USERNAME}"
    git config --global user.email "${MyGITHUB_EMAIL}"
fi



#
# Dotfiles
#
echo -e "\033[1m############################## Dotfiles ##############################\033[0m"
if ask_yesno "Do you want to clone dotfiles ?"; then
    dotfiles="${HOME}/dots"

    if [ -e "${dotfiles}" ]; then
        mv "${dotfiles}" "${dotfiles}~$(date '+%Y%m%d%H%M')"
    fi
    mkdir -p ${dotfiles}

    git clone https://github.com/woowee/dots.git "${dotfiles}"

    ln -fs ${dotfiles}/.vimrc ${HOME}/.vimrc
    ln -fs ${dotfiles}/.gvimrc ${HOME}/.gvimrc
    ln -fs ${dotfiles}/.zshrc ${HOME}/.zshrc
fi



#
# OSX Settings
#
echo -e "\033[1m############################ OSX Settings ############################\033[0m"
# Trackpad
echo '  トラックパッドのナチュラル・スクロールを止める... '
defaults write -g com.apple.swipescrolldirection -bool false
# [システム環境設定 > トラックパッド > スクロールとズーム > スクロールの方向 : ナチュラル] = "OFF"

echo '  トラックパッドの副ボタン機能をアクティヴにし、右下端クリックに割り当てる... '
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
# [システム環境設定 > トラックパッド > ポイントオプションおよびクリックオプション > 副ボタンのクリック] = "ON"，[右下端をクリック]

echo '  マウスの副ボタン機能をアクティヴにし、右クリックに割り当てる... '
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode "TwoButton"
# [システム環境設定 > マウス > ポイントオプションおよびクリックオプション > 副ボタンのクリック] = "ON"，[右側をクリック]

# Dock
echo '  Dock を隠す... '
defaults write com.apple.dock autohide -bool true
# [システム環境設定 > Dock > Dock を自動的に隠す/表示] => "ON"

# Finder
echo '  ファイルの拡張子を表示する... '
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# [Finder の環境設定 > 詳細 > すべてのファイル名拡張子を表示] => "ON"

# Keyboard
keyboardid=$(ioreg -n IOHIDKeyboard -r | grep -E 'VendorID"|ProductID' | awk '{ print $4 }' | paste -s -d'-\n' -)'-0'
echo '  Caps Lock を Control キーにする... '
# CapsLock(2) -> Control(0)
defaults -currentHost write -g com.apple.keyboard.modifiermapping.${keyboardid} -array '<dict><key>HIDKeyboardModifierMappingDst</key><integer>2</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>'
# [システム環境設定 > キーボード > 修飾キー > Caps Lock キー] => [^ Control]

echo '  Fn キーのショートカットとホットコーナーをすべて無効にする... '
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0
# [システム環境設定]，[Mission Control] の [キーボードとマウスのショートカット] = "すべて無効"

echo '  すべての Fn (ファンクション) キーを標準にする... '
defaults write -g com.apple.keyboard.fnState -bool true
# [システム環境設定 > キーボード > キーボード > F1、F2 などのすべてのキーを標準ファンクションキーとして使用] => "ON"

echo '  すべてのコントロールを Tab キーで移動する... '
defaults write -g AppleKeyboardUIMode -int 3
# [システム環境設定 > キーボード > キーボードショートカット > フルキーボードアクセス : Tab キーを押してウィンドウやダイアログ内の操作対象を移動する機能の適用範囲] => [すべてのコントロール]

echo '  Dashbord を使わない... '
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 62 "<dict><key>enabled</key><false/></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 63 "<dict><key>enabled</key><false/></dict>"
# [システム環境設定 > キーボード > Mission Control > Dashboard を表示] => "OFF"

echo '  Mission Control を [F12] にマップする... '
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 32 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>111</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 34 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>111</integer><integer>131072</integer></array><key>type</key><string>standard</string></dict></dict>"
# [システム環境設定 > キーボード > Mission Control > Mission Control] = "ON"，[F12]

echo '  アプリケーションウィンドウの表示を [F11] にマップする... '
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 33 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>103</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 35 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>103</integer><integer>131072</integer></array><key>type</key><string>standard</string></dict></dict>"
# [システム環境設定 > キーボード > Mission Control > アプリケーションウィンドウ] = "ON"，[F11]

echo '  デスクトップの表示を [F10] にマップする... '
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 36 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>109</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 37 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>109</integer><integer>131072</integer></array><key>type</key><string>standard</string></dict></dict>"
# [システム環境設定 > キーボード > Mission Control > デスクトップを表示] = "ON"，[F10]

echo '  [F2] でメニューを操作する... '
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 7 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>120</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
# [システム環境設定 > キーボード > キーボードと文字入力 > メニューバーを操作対象にする] = "ON"，[F2]

echo '  [F3] でツールバーを操作する... '
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 10 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>99</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>"
# [システム環境設定 > キーボード > キーボードと文字入力 > ウィンドウのツールバーを操作対象にする] = "ON"，[F3]

# Inputmethod (Kotoeri)
echo '  言語切り替えは “US-ひらがな” のみ (カタカナなどは含まない)... '

if defaults read ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources >/dev/null 2>&1; then
    defaults delete ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources
fi
defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";"Input Mode" = "com.apple.inputmethod.Japanese"; InputSourceKind = "Input Mode";}'
defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";"Input Mode" = "com.apple.inputmethod.Japanese.placename";InputSourceKind = "Input Mode";}'
defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";"Input Mode" = "com.apple.inputmethod.Roman";InputSourceKind = "Input Mode";}'
defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";"Input Mode" = "com.apple.inputmethod.Japanese.firstname";InputSourceKind = "Input Mode";}'
defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";"Input Mode" = "com.apple.inputmethod.Japanese.lastname";InputSourceKind = "Input Mode";}'
defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array-add '{"Bundle ID" = "com.apple.inputmethod.Kotoeri";InputSourceKind = "Keyboard Input Method";}'

echo '  数字，記号はシングルバイトで入力する... '
# [ことえり環境設定 > 文字入力 > 数字を全角で入力]
#/usr/libexec/Plistbuddy -c "set :zhnm 0"  ~/Library/Preferences/com.apple.inputmethod.Kotoeri.plist
defaults write com.apple.inputmethod.Kotoeri 'zhnm' -int 0

#maverick で無くなった。っぽい?
#echo '記号への勝手な変換機能は要らない... '
#    /usr/libexec/Plistbuddy -c "set :NSUserReplacementItemsEnabled bool false" ~/Library/Preferences/.GlobalPreferences.plist
#    /usr/libexec/Plistbuddy -c "set :WebAutomaticTextReplacementEnabled bool false" ~/Library/Preferences/.GlobalPreferences.plist
#    # [システム環境設定 > 言語とテキスト > テキスト > 記号とテキストの置換を使用] = "OFF"

echo '  スペルチェック機能は要らない... '
#/usr/libexec/Plistbuddy -c "set :NSAutomaticSpellingCorrectionEnabled bool false" ~/Library/Preferences/.GlobalPreferences.plist
#/usr/libexec/Plistbuddy -c "set :WebAutomaticSpellingCorrectionEnabled bool false" ~/Library/Preferences/.GlobalPreferences.plist
# [システム環境設定 > 言語とテキスト > テキスト > 記号とテキストの置換を使用] = "OFF"

echo '  スペース、括弧は (できるものだけでも) シングルバイトで入力する... '
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

#
# Applications
#
echo ""
echo -e "\033[1m######################## Install Applications ########################\033[0m"
app_macvim_name='MacVim-KaoriYa'
app_macvim_filename='MacVim.app'
app_macvim_url='https://github.com/splhack/macvim/releases/download/20140107/macvim-kaoriya-20140107.dmg'

app_alfred_name="Alfred 2"
app_alfred_filename="Alfred 2.app"
app_alfred_url='http://cachefly.alfredapp.com/Alfred_2.2_243b.zip'

app_chrome_name='Google Chrome'
app_chrome_filename='Google Chrome.app'
app_chrome_url='https://dl.google.com/chrome/mac/stable/GGRM/googlechrome.dmg'

## access, download, and install
function install_application() {
    # arguments.check
    if [ $# -lt 3 ]; then
        echo -e "usage: \033[1minstall_application\033[0m \033[4mapp_name\033[0m \033[4mapp_filename(*.app)\033[0m \033[4murl\033[0m [\033[4mdir\033[0m]" 1>&2
        return 1
    fi
    # arguments.set
    app_name=$1
    app_filename=$2
    app_url=$3
    if [ $# -eq 4 ]; then
        dir_tmp=$4
    else
        dir_tmp="${HOME}/tmp_installation"
        mkdir -p ${dir_tmp}
    fi

    echo -e "Installing \033[1;32m${app_name}\033[0m..."

    # get
    cd "${dir_tmp}"
    curl --location --remote-name "${app_url}"
    app_filepath="${HOME}/${dir_tmp}/${app_url##*/}"
    echo ${app_filepath}
    # expansion & install
    case "${app_url##*.}" in
    'zip')
        unzip -q "${app_filepath}"
        cp -a "${app_filename}" "/Applications"
        ;;
    'dmg')
        app_mount="/Volumes/${app_name}"
        hdiutil attach "${app_filepath}" -noidmereveal
        cp -a "${app_mount}/${app_filename}" "/Applications"
        hdiutil detach -force "${app_mount}"
        ;;
    esac
}

if ask_yesno "Do you want to install applications, alfred, chrome, and macvim-kaoriya ?"; then

    type brew >/dev/null 2>&1 || ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    brew update && brew upgrade

    brew tap phinze/cask
    brew tap woowee/mycask

    brew upgrade brew-cask || true
    brew upgrade brew-cask && brew cask update

    brew cask install alfred
    brew cask install google-chrome
    brew cask install macvim-kaoriya    # woowee/mycask

#    ## install
#    install_application "${app_macvim_name}" "${app_macvim_filename}" "${app_macvim_url}" "${dir_tmp}"
#    install_application "${app_alfred_name}" "${app_alfred_filename}" "${app_alfred_url}" "${dir_tmp}"
#    install_application "${app_chrome_name}" "${app_chrome_filename}" "${app_chrome_url}" "${dir_tmp}"

    ## Each application settings
    # Terminal
    defaults write com.apple.terminal "Default Window Settings" -string "Pro"
    defaults write com.apple.terminal "Startup Window Settings" -string "Pro"

    # MacVim
    if check_existence_app "${app_macvim_filename}"; then
        defaults write org.vim.MacVim "MMNativeFullScreen" -bool false

        # MacVim > Neobundle
        if ask_yesno "\033[1;32mMacVim\033[0m, Install the plugins by using 'NeoBundleInstall'?"; then
            vimbundle="~/.vim/bundle"
            if [ -e ${HOME}/.vim ]; then
                mv ${HOME}/.vim "${HOME}/.vim~$(date '+%Y%m%d%H%M')"
            fi
            mkdir -p ~/.vim/bundle
            git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim

            vim -u ~/.vimrc -i NONE -c "try | NeoBundleUpdate! | finally | q! | endtry" -e -s -V1 &&:
            echo ""
        fi
    fi

    # Alfred
    brew cask alfred link

fi

## Please restart
cat << END


**************************************************
               NOW IT'S DONE.

   You Should RESTART to activate the settings.
     (c.g., [Command] + [Control] + [EJECT])
**************************************************


END
