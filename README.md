概要  
---  
Mac OSX マシンの作業環境を構築するのに使う。

使い方として、目的により2つの使用方法を想定。

1. **とりあえず作業が行える程度の "必要最小限 minimal" な環境を**作りたい時用
2. **いつもの "完全 complete" な作業環境を**作りたい時用

前者は、新しいマシンを購入した時や、OS のインストール直後等において、"とりあえず"の環境があれば良い、と言った場面で使うことを考えて設けている。  
これは `bootstrap.sh` を使う。

後者は、環境設定のために十分な時間を準備できるような、余裕のある場面での利用を想定。  
この場合では、`osx.sh` と `app.sh` を使う。


やる事  
---  
* OSX のデフォルト設定。
* GitHub との接続設定。(現時点 `bootstrap.sh` のみ)
* アプリケーションソフトウェアのインストール(要 Homebrew)、必要に応じ各アプリ設定。


動作条件  
---  
00. OSX (10.10 Yosemite)
00. [Command Line Tools for Xcode][30]

[30]: https://developer.apple.com/downloads/index.action?=xcode "Downloads for Apple Developers"


導入方法
---

``` sh
git clone https://github.com/woowee/macset.git
cd macset
```

以下の config ファイルの設定について、任意で構わない。  
設定用ファイル `config.sh` を用意し、予め各アカウント情報等を指定。

``` sh
cp config.sh.tmp config.sh
vi config.sh
```
これをしなくても動作する。

使い方 1 -- "必要最小限 minimal" な環境を作る
---

``` sh
./bootstrap.sh
```

システム情報の重要な設定作業が絡むので、対話形式で行うようにしている。

ここでやることのアウトライン ;

* システム情報の設定  
この処理は、`bootstrap.sh` でのみ。  
    - コンピュータ名
    - ホスト名
    - ローカルホスト名
* GitHub アクセス設定  
注) ここで、SSH Key 登録のためWebブラウザ Safari を起動する。  
* dotfiles の導入 (`git clone ...`)
* OSX デフォルト設定
* アプリケーションソフトウェアのインストール([Homebrew][40]、そして [Homebrew Cask][41])
    - [Homebrew][40]
    - [Homebrew Cask][41]
    - [Alfred 2.app][42]
    - [Google Chrome.app][43]
    - [iTerm.app (iTerm2)][44]
    - [MacVim.app (MacVim-KaoriYa)][45]
* 各アプリケーションの設定  
注) ここで、MacVim のプラグインのインストールも行う。

処理終了後は、各種設定反映のため、再起動を推奨。

[40]: http://brew.sh/ "Homebrew — The missing package manager for OS X"  
[41]: http://caskroom.io/ "Homebrew Cask"  
[42]: http://www.alfredapp.com/ "Alfred App - Productivity App for Mac OS X"  
[43]: https://www.google.co.jp/chrome/?platform=mac "Chrome ブラウザ"  
[44]: http://iterm2.com/ "iTerm2 - Mac OS Terminal Replacement"  
[45]: https://github.com/splhack/homebrew-splhack "splhack homebrew-splhack"


使い方 2 -- いつもの "完全 complete" な環境を作る
---

設定する項目やインストールするアプリケーションの詳細については、全て述べると長くなるので、ここでは割愛。  
以下、注意点のみ記載。


### OSX のデフォルト設定

``` sh
./osx.sh [-s]
```

* 各処理は、対話形式で行う。
* **オプション `s` **を指定してやると、サイレントモードで処理を行う。(推奨)
* 処理終了後は、再起動推奨。


### アプリケーションのインストール

``` sh
./app.sh [-s]
```

* こちらは対話形式ではない。
* [Homebrew][40] および [Homebrew Cask][41] の導入を前提にしているので、もし導入されていなければインストール作業を行う。  
また導入済みでも、パッケージの更新は行う。  
* [XQuartz(X11)][46] をインストールしている。  
X11 コンポネントを利用するアイテムがあるため(ex. `fontforge`)。インストールは、[Homebrew Cask][41] によるもの。  
* シェルは、OS 標準の bash から zsh に変更している。
* `rsync` は、OS 標準の vresion 2.x から vresion 3.x に変更している。  
これは Homebrew で [homebrew/dupes][47] を tap することでインストールし、変更している。  
* フォント [Ricty][48] のインストールも行っている。

[46]: https://xquartz.macosforge.org/landing/ "XQuartz"  
[47]: https://github.com/Homebrew/homebrew-dupes "Homebrew/homebrew-dupes"  
[48]: https://github.com/yascentur/Ricty.git "yascentur/Ricty"


参考・謝辞
---

* mathiasbynens "[mathiasbynens/dotfiles][50]"
* DAddYE "[OSX For Hackers][51]"
* bkuhlmann  "[bkuhlmann/osx][52]"

Thank to all very much.

[50]: https://github.com/mathiasbynens/dotfiles "mathiasbynens/dotfiles"  
[51]: https://gist.github.com/DAddYE/2108403 "OSX For Hackers"  
[52]: https://github.com/bkuhlmann/osx "bkuhlmann/osx"

