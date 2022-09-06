#!/bin/bash

### Dock
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock autohide -bool true

killall Dock

## Mouse & TrackPad
defaults write -g com.apple.mouse.scaling
defaults write -g com.apple.trackpad.scaling 5

## Key Repeat
defaults write -g InitialKeyRepeat -int 12
defaults write -g KeyRepeat -int 1

## Screenshot save location
defaults write com.apple.screencapture location ~/Downloads

echo "Please Reboot"
