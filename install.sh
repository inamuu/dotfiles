#!/bin/bash

set -u
DOT_DIRECTORY="${HOME}/dotfiles"
DOT_CONFIG_DIRECTORY=".config"

OSTYPE=$(uname -s)

ubuntu () {
sudo apt update
sudo apt install -y \
  make \
  gcc \
  git \
  unzip \
  zlib1g-dev

## To install Python using pyenv
sudo apt install -y \
  curl \
  llvm \
  sqlite3 \
  libssl-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  libncurses5-dev \
  libncursesw5-dev \
  python-tk \
  python3-tk \
  tk-dev \
  aria2

chsh -s /usr/bin/zsh
}

if [ "${OSTYPE}" = "Linux" ];then
  BREWCMDSTATUS=$(which brew)
  if [ "${BREWCMDSTATUS}" -ne 0 ];then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
  fi 
  echo "Install packages" 
  ubuntu
fi

if [ "${OSTYPE}" = "Darwin" ];then
  #echo "Install brew"
  #/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  
  echo "Install brew files"
  brew bundle
fi

## Install zprezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

echo "link home directory dotfiles"
cd ${DOT_DIRECTORY}
for f in .??*
do
    #無視したいファイルやディレクトリ
    [ "$f" = ".git" ] && continue
    [ "$f" = ".config" ] && continue
    ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
done

echo "link .config directory dotfiles"
cd ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}
for file in `\find . -maxdepth 8 -type f`; do
#./の2文字を削除するためにfile:2としている
    ln -snfv ${DOT_DIRECTORY}/${DOT_CONFIG_DIRECTORY}/${file:2} ${HOME}/${DOT_CONFIG_DIRECTORY}/${file:2}
done

echo "linked dotfiles complete!"

