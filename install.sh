#!/bin/bash

set -u
DOT_DIRECTORY="${PWD}"
DOT_CONFIG_DIRECTORY=".config"

OSTYPE=$(uname -s)

msg () {
  echo "\n########################"
  echo "# $1"
  echo "########################\n"
  sleep 1
}

ubuntu () {
sudo apt update
sudo apt install -y \
  aria2 \
  curl \
  gcc \
  git \
  libbz2-dev \
  libncurses5-dev \
  libncursesw5-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  llvm \
  make \
  python-tk \
  python3-tk \
  sqlite3 \
  tk-dev \
  unzip \
  zlib1g-dev

chsh -s /usr/bin/zsh
}

if [ "${OSTYPE}" = "Linux" ];then
  BREWCMDSTATUS=$(which brew)
  if [ $? -ne 0 ];then
    msg "Install linuxbrew"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
  fi 
  msg "Install Packages"
  ubuntu
fi

if [ "${OSTYPE}" = "Darwin" ];then
  BREWCMDSTATUS=$(which brew)
  if [ $? -ne 0 ];then
    msg "Install homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  msg "Install brew files"
  brew bundle
fi

if [ ! -d "${HOME}/.zprezto" ];then
  msg "Install zprezto"
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi

msg "link home directory dotfiles"
cd ${DOT_DIRECTORY}
for f in .??*
do
    #無視したいファイルやディレクトリ
    [ "$f" = ".git" ] && continue
    [ "$f" = ".config" ] && continue
    ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
done

msg "link .config directory dotfiles"
cd ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}
for file in `\find . -maxdepth 8 -type f`; do
#./の2文字を削除するためにfile:2としている
    #ln -snfv ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}/${file:2} ${HOME}/${DOT_CONFIG_DIRECTORY}/${file:2}
    echo $file
done

msg "linked dotfiles complete!"

if which blueutil;then
  if which sleepwatcher;then
    brew services start sleepwatcher
  fi
fi

