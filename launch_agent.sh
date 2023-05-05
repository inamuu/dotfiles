#!/bin/bash

plist_list=(
files/launch_agents/brew_update.plist
)

for i in ${plist_list[@]};do
  launchctl unload $i
  plutil -lint $i
  launchctl load $i
done

printf "\n### List my launch plist ###\n"
launchctl list | grep com.users

