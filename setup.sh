#!/bin/bash

BREWCMDSTATUS=$(which brew)
if [ $? -ne 0 ]; then
  msg "Install homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

MISECMDSTATUS=$(which mise)
if [ $? -ne 0 ]; then
  msg "Install mise"
  brew install mise
fi
# zpreztoからstarshipにしたのでコメントアウト
#if [ ! -d "${HOME}/.zprezto" ]; then
#  msg "Install zprezto"
#  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
#fi

echo "Finished!!"
