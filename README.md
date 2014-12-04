Overview
---

These scripts might help to build your working enviroment of OSX machine.

It is made with imagining it has two way to use. ;

1. To make the "minimal" enviroment enough to temporary work.
2. To make the usual "complete" enviroment.

The former is provided with the intention of using under the situation in which you will hardly spend time to perform the setting work, for example in purchasing a new Mac or right after OSX installation and so on.  
Can use the `bootstrap.sh`.

In comparison, the latter is assumed to be used when there is enogh time to set up your Mac.  
Use `osx.sh` and `app.sh` in this case.


Features
---

* Defaults settings for OSX.
* Access settings of GitHub (Only in `bootstrap.sh`)
* Application softwares installation (Need Homebrew), and some settings.


Requirements
---

00. OSX (10.10 Yosemite)
00. [Command Line Tools for Xcode][30]

[30]: https://developer.apple.com/downloads/index.action?=xcode "Downloads for Apple Developers"


Setup
---

``` sh
git clone https://github.com/woowee/macset.git
cd macset
```

The setting about `config.sh` file show below is not required.  
You can also get `config.sh` from included `config.sh.tmp` as template.  
You can define your account infrmation required for setting by using `config.sh` in advance.  

``` sh
cp config.sh.tmp config.sh
vi config.sh
```

Usage 1 Â» To Prepare "Minimal" Enviroment
---

``` sh
./bootstrap.sh
```

This process operates interactively because it must deal with important informatin of system.

A brief outline of this processing is ;

* System information settings  
`bootstrap.sh` only.  
    - Computer Name
    - Host Name
    - Local Host Name
* GitHub account settings  
Note that Safari is going to open to regist SSH key in GitHub.  
* Dotfile settings
* OSX defaults settings
* Applications installation
    - [Homebrew][40]
    - [Homebrew Cask][41]
    - [Alfred 2.app][42]
    - [Google Chrome.app][43]
    - [iTerm.app (iTerm2)][44]
    - [MacVim.app (MacVim-KaoriYa)][45]
* Some applications settings

[40]: http://brew.sh/ "Homebrew â€” The missing package manager for OS X"  
[41]: http://caskroom.io/ "Homebrew Cask"  
[42]: http://www.alfredapp.com/ "Alfred App - Productivity App for Mac OS X"  
[43]: https://www.google.co.jp/chrome/?platform=mac "Chrome ãƒ–ãƒ©ã‚¦ã‚¶"  
[44]: http://iterm2.com/ "iTerm2 - Mac OS Terminal Replacement"  
[45]: https://github.com/splhack/homebrew-splhack "splhack homebrew-splhack"


Usage 2 Â» To Build "Complete" Enviroment
---

The scripts to set the defautls for OSX and install applications software are provided for each other because I think it will be the requirement to do separately.

### Settings of Defaults for OSX

``` sh
./osx.sh [-s]
```
* This process also operates interactively.
* It runs in the silent mode with `-s` option is specified
* You need to restart the machine to apply the settings.

### Installing of Applications

``` sh
./app.sh
```

* This is not interactively.
* Install [Homebrew][40] and [Homebrew-Cask][41]. If they have been already installed they would be updated.
* Install [XQuartz(X11)][46] because there are some items that utilizes X11 components.
* Change the shell from bash as default of OSX to zsh.
* `rsync` uses version 3.x, not 2.x as default.
* Install [Ricty][48] font.

[46]: https://xquartz.macosforge.org/landing/ "XQuartz"  
[47]: https://github.com/Homebrew/homebrew-dupes "Homebrew/homebrew-dupes"  
[48]: https://github.com/yascentur/Ricty.git "yascentur/Ricty"



References
---

* mathiasbynens "[mathiasbynens/dotfiles][50]"
* DAddYE "[OSX For Hackers][51]"
* bkuhlmann  "[bkuhlmann/osx][52]"

Thank to all very much.


[50]: https://github.com/mathiasbynens/dotfiles "mathiasbynens/dotfiles"  
[51]: https://gist.github.com/DAddYE/2108403 "OSX For Hackers"  
[52]: https://github.com/bkuhlmann/osx "bkuhlmann/osx"


<p>&nbsp;</p>

.....

Thank you for reading it through.  
By now, I guess you get used to my funny English writing. Appreciate any suggestions you can make.:wink:
