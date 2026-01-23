---
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(npm:*), Bash(ls:*), Bash(cp:*), Bash(mkdir:*), Bash(find:*)
description: "DailyNoteを作成します"
---

### 概要

1. 最初に今日のデイリーファイルがあるかチェック、なければ作成する
  - 「テンプレートファイル」をコピーして「参照先ディレクトリ」配下にyyyy/mm/yyyymmdd.md 形式で作成する
2. すでにある、または作成が完了したら、「ToDoファイル」を参照し、「## InPregss」と「## InReview」のタスクをデイリーファイルの「Tasks」にコピーする
  - コピー後、「---」で囲われたプロパティを更新する
    - 更新する際は「プロパティ形式」のサンプルを参考にする
3. コピーされたTasksをプロジェクトごとにまとめてインデントする
  - インデントの仕方は「Tasks形式」のサンプルを参考にする
  - 前日、または前週金曜日にプロジェクトタイトルがあればそれをコピーして使用する
  - 前日、または前週金曜日にプロジェクトタイトルの記載がなければ、下記フローでタイトルを取得して設定する
    - 「プロジェクト一覧」配下にプロジェクトごとにディレクトリが存在する
    - プロジェクトのディレクトリ名には「日本語_タグ名」となっているので、タグ名を確認する
    - タグ名が付与されたTask群は上記ディレクトリの「日本語」部分をTasksのタイトルとして使用する
  - タスク一覧のプロジェクトのタグは削除する
4. Gcal概要 以下を実行して本日の予定を追記する

### テンプレートファイル

- ${HOME}/ghq/github.com/inamuu/obsidian/Vaults/Works/01.Configs/Templates/DailyFormat.md
 
### 参照先ディレクトリ

- ${HOME}/ghq/github.com/inamuu/obsidian/Vaults/Works/02.Daily/ 

### ToDoファイル

- ${HOME}/ghq/github.com/inamuu/obsidian/Vaults/Works/20.ToDo/MyToDo.md

### プロパティ形式 

サンプル
```
---
id: 20250925T09000000
aliases: [2025/09/25, 2025年9月25日]
tags: [daily/2025/09/25]
created: 2025-09-25T09:00:00
updated: 2025-09-25T09:00:00
---
```

### Tasks形式

サンプル
```
# Tasks
- AWSアカウント分割
    - [-] [jm-sandbox] CLIENT_IDを更新 #42996
    - [-] [jm-sandbox] CIDRが変わるのでヘルスチェックのCIDR置換 #5300
    - [-] jm-sandbox環境に向けて.devで受けられるように
- ElastiCacheバージョンアップ
    - [-] Op:コンテナイメージをValkeyへ変更 #5296 #waiting 
    - [-] Jm: コンテナイメージをValkeyへ変更 #42513 #waiting 
- その他
    - [ ] 1on1
```

### プロジェクト一覧

- ${HOME}/ghq/github.com/inamuu/obsidian/Vaults/Works/04.Projects/


---

重要なメモ: 以下はテストで追加したがあまりカレンダーの予定を参照することは無いので、実行しなくて良い

### Gcal概要
Googleカレンダーから今日の予定を取得し、DailyNoteに追記します

## 手順

1. ICSファイルのダウンロード
```bash
curl -o /tmp/basic.ics "https://calendar.google.com/calendar/ical/kazuma.inamura%40medley.jp/private-47b15f438ce71603c7ee1c5bc0b0df64/basic.ics"
```

2. 今日の予定を抽出（Pythonスクリプト）
import re
from datetime import datetime

with open('/tmp/basic.ics', 'r') as f:
    content = f.read()

events = re.findall(r'BEGIN:VEVENT.*?END:VEVENT', content, re.DOTALL)

# 今日の日付を取得（YYYYMMDD形式）
today = datetime.now().strftime('%Y%m%d')

today_events = []
for event in events:
    if re.search(rf'DTSTART[^:]*:{today}', event):
        summary_match = re.search(r'SUMMARY:(.+?)(?:\r?\n(?! ))', event)
        summary = summary_match.group(1) if summary_match else 'No title'

        dtstart_match = re.search(r'DTSTART[^:]*:(\S+)', event)
        dtstart = dtstart_match.group(1) if dtstart_match else ''

        dtend_match = re.search(r'DTEND[^:]*:(\S+)', event)
        dtend = dtend_match.group(1) if dtend_match else ''

        # タイムゾーン処理
        if 'T' in dtstart and 'Z' in dtstart:
            # UTCの場合、JSTに変換
            time_part = dtstart.replace('Z', '').split('T')[1]
            hour = int(time_part[:2])
            minute = time_part[2:4]
            jst_hour = (hour + 9) % 24
            jst_minute = int(minute)

            # 終了時刻も変換
            if 'T' in dtend and 'Z' in dtend:
                end_time_part = dtend.replace('Z', '').split('T')[1]
                end_hour = int(end_time_part[:2])
                end_minute = end_time_part[2:4]
                end_jst_hour = (end_hour + 9) % 24
                display_time = f"{jst_hour:02d}:{minute}-{end_jst_hour:02d}:{end_minute}"
            else:
                display_time = f"{jst_hour:02d}:{minute}"
        elif 'T' in dtstart:
            # Asia/Tokyoの場合
            time_part = dtstart.split('T')[1]
            hour = int(time_part[:2])
            minute = time_part[2:4]

            if 'T' in dtend:
                end_time_part = dtend.split('T')[1]
                end_hour = int(end_time_part[:2])
                end_minute = end_time_part[2:4]
                display_time = f"{hour:02d}:{minute}-{end_hour:02d}:{end_minute}"
            else:
                display_time = f"{hour:02d}:{minute}"
        else:
            display_time = "終日"

        today_events.append({
            'start': dtstart,
            'display_time': display_time,
            'summary': summary
        })

today_events.sort(key=lambda x: x['start'])

print("## 📅 今日の予定\n")
if today_events:
    for event in today_events:
        print(f"- [ ] {event['display_time']}: {event['summary']}")
else:
    print("- 予定はありません")


3. いつもある「SREグループ朝会」周知の事実のため予定を削除 

4. ICSファイルの削除
rm -f /tmp/basic.ics

## DailyNoteテンプレート

抽出した予定を以下のフォーマットでDailyNoteに挿入してください
記載するときは時系列に並べ直してください

## Mtg
  - [ ] 11:30-12:30: test schedule
  - [ ] 14:30-15:00: 下期振り返り面談・稲村さん


