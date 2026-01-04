## require
require 'fileutils'

### Install directory that using installer files
cask_args appdir: "/Applications"

### Main
tap_list = [
  "fluxcd/tap",
  "sanemat/font",
  "fujiwara/tap",
  "fluxcd/tap",
  "hashicorp/tap",
  "dotenvx/brew",
  "future-architect/tap"
]

for i in tap_list
  tap i
end

### Install command line tools
#"automake"

brew_list = [
  "act",
  "actionlint",
  "ansible",
  "anyenv",
  "argo",
  "aws-sam-cli",
  "aws-vault",
  "aws2-wrap",
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
  "direnv",
  "dotenvx/brew/dotenvx",
  "easy-rsa",
  "eksctl",
  "envchain",
  "eza",
  "fcgi",
  "fontforge",
  "future-architect/tap/tftarget",
  "fzf",
  "gawk",
  "gh",
  "ghostscript",
  "ghq",
  "ghr",
  "git-delta",
  "gitui",
  "gnutls",
  "go-task",
  "gpg",
  "graphviz",
  "grep",
  "gron",
  "gsed",
  "hadolint",
  "helix",
  "helm",
  "helmfile",
  "htop",
  "httping",
  "hub",
  "jless",
  "jnv",
  "jq",
  "k9s",
  "kind",
  "kube-linter",
  "kubectl",
  "kubectx",
  "lambroll",
  "minikube",
  "mise",
  "mysql",
  "nmap",
  "peco",
  "percona-toolkit",
  "pinentry-mac",
  "pkg-config",
  "putty",
  "pwgen",
  "pygments",
  "rclone",
  "redis",
  "ripgrep",
  "s3cmd",
  "saml2aws",
  "shellcheck",
  "sleepwatcher",
  "stern",
  "telnet",
  "terraformer",
  "tflint",
  "tig",
  "tmux",
  "tree",
  "uv",
  "vegeta",
  "watch",
  "wget",
  "yq",
  "zsh",
  "zsh-autosuggestions",
  "zsh-completions",
  "zsh-syntax-highlighting",
  "zx"
]

for i in brew_list
  brew i
end

### Install fonts
#cask "font-ricty-diminished"
#brew "sanemat/font/ricty"
#cask "font-udev-gothic"
#cask "font-udev-gothic-nf"


### Install desktop applications for macOS and Linux

#   "google-chrome",
#   "google-japanese-ime",
#   "tunnelblick",
cask_list = [
  "alt-tab",
  "codex",
  "kiro-cli",
  #"cursor",
  "font-udev-gothic",
  "font-udev-gothic-nf",
  "gcloud-cli",
  #"notion",
  "obsidian",
  "rar",
  "raycast",
  "slack",
  "visual-studio-code",
  "wezterm"
]

for i in cask_list
  cask i
end

### Install desktop apps only private and macOS
if ENV['PCENV'] == 'private' and OS.mac?
  cask "vnc-viewer"
  cask "rambox"
end

### Install desktop apps only work and macOS
if ENV['PCENV'] == 'work' and OS.mac?
  cask "todoist"
end

### Install desktop apps only macOS for private and work
if OS.mac?
  #"alfred"
  #"zoom" インストール時にエラーになるため
  cask_list = [
    #"alacritty",
    "bitwarden",
    "dbeaver-community",
    #"docker",
    "firefox",
    #"font-hack-nerd-font",
    #"iterm2",
    "karabiner-elements",
    "macvim",
    #"postman",
    #"rectangle",
    "session-manager-plugin",
    "the-unarchiver",
    #"xquartz"
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

