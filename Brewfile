## require
require 'fileutils'

### Install directory that using installer files
cask_args appdir: "/Applications"

### Main
tap_list = [
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
  "argo",
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
  "direnv",
  "duckdb",
  "easy-rsa",
  "eksctl",
  "envchain",
  "eza",
  "fcgi",
  "flux",
  "fontforge",
  "gawk",
  "gh",
  "ghq",
  "ghostscript",
  "gitui",
  "git-delta",
  "gnutls",
  "goreleaser/tap/goreleaser",
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
  "watch",
  "wget",
  "yq",
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
cask "font-udev-gothic"
cask "font-udev-gothic-nf"


### Install desktop applications for macOS and Linux

cask_list = [
  "google-chrome",
  "google-japanese-ime",
  "notion",
  "rar",
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
    "session-manager-plugin",
    "the-unarchiver",
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

