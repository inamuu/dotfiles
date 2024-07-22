## require
require 'fileutils'

### Install directory that using installer files
cask_args appdir: "/Applications"

### Main
tap_list = [
  "homebrew/cask-fonts",
  "homebrew/bundle",
  "sanemat/font",
  "fujiwara/tap"
]

for i in tap_list
  tap i
end

### Install command line tools
#"automake"

brew_list = [
  "act",
  "ansible",
  "anyenv",
  "aws-sam-cli",
  "aws-vault",
  "awscli",
  "awslogs",
  "bat",
  "bitwarden-cli",
  "blueutil",
  "bzip2",
  "circleci",
  "cli53",
  "colordiff",
  "coreutils",
  "git-delta",
  "direnv",
  "easy-rsa",
  "envchain",
  "eza",
  "fcgi",
  "fontforge",
  "gawk",
  "gh",
  "ghq",
  "gnutls",
  "goreleaser/tap/goreleaser",
  "gsed",
  "gpg",
  "graphviz",
  "grep",
  "gron",
  "helix",
  "htop",
  "hub",
  "jnv",
  "jq",
  "k9s",
  "lambroll",
  "mysql",
  "nmap",
  "peco",
  "percona-toolkit",
  "php",  # for Alfred plugins
  "pinentry-mac",
  "pkg-config",
  "putty",
  "pwgen",
  "rclone",
  "redis",
  "s3cmd",
  "saml2aws",
  "shellcheck",
  "sleepwatcher",
  "telnet",
  "terraformer",
  "tflint",
  "tig",
  "tmux",
  "tree",
  "watch",
  "wget",
  "zsh",
  "zsh-autosuggestions",
  "zsh-completions",
  "zsh-syntax-highlighting"
]

for i in brew_list
  brew i
end

### Install fonts
cask "font-ricty-diminished"
brew "sanemat/font/ricty"


### Install desktop applications for macOS and Linux

cask_list = [
  "authy",
  "arc",
  "cyberduck",
  "commander-one",
  "google-chrome",
  "google-japanese-ime",
  "notion",
  "slack",
  "tunnelblick",
  "visual-studio-code",
  "wezterm"
]

for i in cask_list
  cask i
end

### Install desktop apps only private and macOS
if ENV['PCENV'] == 'private' and OS.mac?
  cask "microsoft-remote-desktop"
  cask "vnc-viewer"
  cask "rambox"
end

### Install desktop apps only work and macOS
if ENV['PCENV'] == 'work' and OS.mac?
  cask "around"
  cask "todoist"
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
    "powershell",
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

