### Notification
noti() {
  #osascript -e "display dialog \"${1:-なにか終わったよ}\" buttons {'OK'} default button \"OK\""
  osascript -e "display dialog \"${1:-処理が完了しました!}\" buttons {\"OK\"} default button \"OK\""
}

