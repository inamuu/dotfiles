### require
require 'fileutils'

### Install directory that using installer files
cask_args appdir: "/Applications"

### Main
tap_list = [
  "homebrew/cask",
  "homebrew/cask-fonts",
  "homebrew/bundle",
  "homebrew/core",
  "sanemat/font",
  "aws/tap",
  "fujiwara/tap"
]

for i in tap_list
  tap i
end

### Install command line tools
#"automake"

brew_list = [
  "ansible",
  "anyenv",
  "aws-sam-cli",
  "aws-sam-cli-beta-cdk",
  "aws-vault",
  "awscli",
  "bat",
  "bitwarden-cli",
  "blueutil",
  "bzip2",
  "circleci",
  "cli53",
  "colordiff",
  "coreutils",
  "direnv",
  "envchain",
  "exa",
  "fcgi",
  "fontforge",
  "gh",
  "ghq",
  "gnutls",
  "grep",
  "gron",
  "htop",
  "hub",
  "jq",
  "lambroll",
  "mysql",
  "nmap",
  "peco",
  "php",  # for Alfred plugins
  "pkg-config",
  "pwgen",
  "redis",
  "s3cmd",
  "saml2aws",
  "shellcheck",
  "sleepwatcher",
  "tig",
  "tmux",
  "tree",
  "wget",
  "zsh",
  "zsh-completions"
]

for i in brew_list
  brew install i
end

### Install fonts
cask "font-ricty-diminished"
brew "sanemat/font/ricty"


### Install desktop applications for macOS and Linux

cask_list = [
  "authy",
  "google-chrome",
  "google-japanese-ime",
  "notion",
  "slack",
  "visual-studio-code"
]

for i in cask_list
  brew install --cask i
end

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
  #"alfred"
  cask_list = [
    "alacritty",
    "bitwarden",
    "dbeaver-community",
    "docker",
    "firefox",
    "font-hack-nerd-font",
    "iterm2",
    "karabiner-elements",
    "macvim",
    "postman",
    "rectangle",
    "sequel-ace",
    "session-manager-plugin",
    "skitch",
    "the-unarchiver",
    "warp",
    "xquartz",
    "zoom"
  ]
  for i in cask_list
    cask i
  end
end

### Alacritty theme
repository_url = "https://github.com/eendroroy/alacritty-theme.git"
clone_dir = File.expand_path("~/.alacritty-colorshme")

unless File.directory?(clone_dir)
  system("git clone #{repository_url} #{clone_dir}")
end

