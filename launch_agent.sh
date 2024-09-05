#!/bin/bash

#plist_list=(
#files/launch_agents/brew_update.plist
#)
#
#for i in ${plist_list[@]};do
#  launchctl unload $i
#  plutil -lint $i
#  launchctl load $i
#done

### Applu Music を起動させない
# 下記だとダメそう
#launchctl disable gui/"$(id -u)"/com.apple.rcd 
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist

printf "\n### List my launch plist ###\n"
launchctl list

