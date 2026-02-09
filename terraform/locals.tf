locals {
  # ファイル一覧を生成
  all_dotfiles = fileset("${abspath(path.module)}/..", ".*")

  # 除外ファイル一覧
  exclude_files = [
    ".DS_Store",
    ".gitignore",
    ".sleep",
    ".wakeup",
    ".gitignore"
  ]

  # 除外ファイルを除外したファイル一覧
  dotfiles_list = [for f in local.all_dotfiles : f if !contains(local.exclude_files, f)]

  defaults_apps = {
    "com.apple.dock" = {
      # Dockの配置は左
      "app"    = "com.apple.dock"
      "params" = "orientation"
      "type"   = "-string"
      "value"  = "left"
      "global" = false
    },
    # Dockが自動的に隠れるようにする
    "com.apple.dock_2" = {
      "app"    = "com.apple.dock"
      "params" = "autohide"
      "type"   = "-bool"
      "value"  = "true"
      "global" = false
    },
    "com.apple.dock_3" = {
      # ミッションコントロールのアプリケーションウィンドウをグループ化
      "app"    = "com.apple.dock"
      "params" = "expose-group-apps"
      "type"   = "-bool"
      "value"  = "true"
      "global" = false
    },
    "com.apple.finder" = {
      # Finderにパスを表示
      "app"    = "com.apple.finder"
      "params" = "ShowPathbar"
      "type"   = "-bool"
      "value"  = "true"
      "global" = false
    },
    "com.apple.finder_2" = {
      # Finderでも隠しファイルを表示
      "app"    = "com.apple.finder"
      "params" = "AppleShowAllFiles"
      "type"   = "-bool"
      "value"  = "true"
      "global" = false
    },
    "com.apple.finder_3" = {
      # 拡張子変更時にWarningは出さない
      "app"    = "com.apple.finder"
      "params" = "FXEnableExtensionChangeWarning"
      "type"   = "-bool"
      "value"  = "false"
      "global" = false
    },
    "com.apple.finder_4" = {
      # フォルダーを先頭に表示
      "app"    = "com.apple.finder"
      "params" = "_FXSortFoldersFirst"
      "type"   = "-bool"
      "value"  = "true"
      "global" = false
    },
    "com.apple.screencapture" = {
      # スクリーンショットの保存先
      "app"    = "com.apple.screencapture"
      "params" = "location"
      "type"   = "-string"
      "value"  = "~/Downloads"
      "global" = false
    },
    "InitialKeyRepeat" = {
      "app"    = "InitialKeyRepeat"
      "params" = ""
      "type"   = "-int"
      "value"  = "12"
      "global" = true
    },
    "KeyRepeat" = {
      "app"    = "KeyRepeat"
      "params" = ""
      "type"   = "-int"
      "value"  = "1"
      "global" = true
    },
    "com.apple.mouse.scaling" = {
      "app"    = "com.apple.mouse.scaling"
      "params" = ""
      "type"   = "-int"
      "value"  = "2"
      "global" = true
    },
    "com.apple.trackpad.scaling" = {
      "app"    = "com.apple.trackpad.scaling"
      "params" = ""
      "type"   = "-int"
      "value"  = "5"
      "global" = true
    },
    "ApplePressAndHoldEnabled" = {
      # Mac標準IMEを連続入力した際に表示される特殊文字を無効化
      "app"    = "ApplePressAndHoldEnabled"
      "params" = ""
      "type"   = "-bool"
      "value"  = "false"
      "global" = true
    }
  }
}

output "deploy_dotfiles_list" {
  value = local.dotfiles_list
}
