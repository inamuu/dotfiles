### ref: https://qiita.com/vochicong/items/f20afc89a6847cd58f0f

### Install directory that using installer file
cask_args appdir: "/Applications"

### Main
tap "homebrew/cask"
tap "homebrew/cask-fonts"
tap "homebrew/bundle"
tap "homebrew/core"
tap "sanemat/font"
tap "aws/tap"
tap "fujiwara/tap"

### Install command line tools
#brew "automake"
brew "anyenv"
brew "ansible"
brew "awscli"
brew "aws-sam-cli"
brew "aws-sam-cli-beta-cdk"
brew "aws-vault"
brew "bat"
brew "blueutil"
brew "bitwarden-cli"
brew "bzip2"
brew "circleci"
brew "cli53"
brew "coreutils"
brew "direnv"
brew "envchain"
brew "exa"
brew "fcgi"
brew "fontforge"
brew "gh"
brew "ghq"
brew "gnutls"
brew "grep"
brew "gron"
brew "htop"
brew "hub"
brew "jq"
brew "lambroll"
brew "nmap"
brew "mysql"
brew "peco"
brew "php"  # for Alfred plugins
brew "pkg-config"
brew "pwgen"
brew "redis"
brew "s3cmd"
brew "saml2aws"
brew "shellcheck"
brew "sleepwatcher"
brew "tig"
brew "tmux"
brew "tree"
brew "wget"
brew "zsh"
brew "zsh-completions"

### Install fonts
cask "font-ricty-diminished"
brew "sanemat/font/ricty"


### Install desktop applications for macOS and Linux
cask "authy"
cask "google-chrome"
cask "google-japanese-ime"
cask "notion"
cask "slack"
cask "visual-studio-code"

### Install desktop apps only private for macOS and Linux
if ENV['PCENV'] == 'private'
  cask "rambox"
end

### Install desktop apps only private and macOS
if ENV['PCENV'] == 'private' and OS.mac?
  cask "microsoft-remote-desktop"
  cask "vnc-viewer"
end

### Install desktop apps only work and macOS
if ENV['PCENV'] == 'work' and OS.mac?
  cask "gather"
end

### Install desktop apps only macOS for private and work
if OS.mac?
  #cask "alfred"
  cask "alacritty"
  cask "bitwarden"
  cask "dbeaver-community"
  cask "docker"
  cask "firefox"
  cask "font-hack-nerd-font"
  cask "iterm2"
  cask "karabiner-elements"
  cask "macvim"
  cask "postman"
  cask "rectangle"
  cask "sequel-ace"
  cask "session-manager-plugin"
  cask "skitch"
  cask "the-unarchiver"
  cask "warp"
  cask "xquartz"
  cask "zoom"
end

