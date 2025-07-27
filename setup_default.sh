#!/bin/bash

### Dock
defaults write com.apple.dock orientation -string "left" # Dockの配置
defaults write com.apple.dock autohide -bool true # 自動的にDockが隠れるように
defaults write com.apple.finder AppleShowAllFiles true # 隠しファイルの表示


## Mouse & TrackPad
defaults write -g com.apple.mouse.scaling 2
defaults write -g com.apple.trackpad.scaling 5

## Key Repeat
defaults write -g InitialKeyRepeat -int 12
defaults write -g KeyRepeat -int 1

## Screenshot save location
defaults write com.apple.screencapture location ~/Downloads # スクリーンショットの保存先


### Mission Control
defaults write com.apple.dock mru-spaces -bool false # 最新の使用状況に基づいて操作スペースを自動的に並び替える
defaults write com.apple.dock expose-group-apps -bool true # ウィンドウをアプリケーションごとにグループ化

killall Dock
echo "Please Reboot"

