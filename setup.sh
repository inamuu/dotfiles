#!/bin/bash

BREWCMDSTATUS=$(which brew)
if [ $? -ne 0 ]; then
  echo "Install homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

MISECMDSTATUS=$(which mise)
if [ $? -ne 0 ]; then
  echo "Install mise"
  brew install mise
fi

echo "Finished!!"
