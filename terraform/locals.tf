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
      "app"    = "com.apple.dock"
      "params" = "orientation"
      "type"   = "-string"
      "value"  = "left"
    },
    "com.apple.dock_2" = {
      "app"    = "com.apple.dock"
      "params" = "autohide"
      "type"   = "-bool"
      "value"  = "true"
    },
    "com.apple.finder" = {
      "app"    = "com.apple.finder"
      "params" = "ShowPathbar"
      "type"   = "-bool"
      "value"  = "true"
    },
    "com.apple.finder_2" = {
      "app"    = "com.apple.finder"
      "params" = "AppleShowAllFiles"
      "type"   = "-bool"
      "value"  = "true"
    },
    "com.apple.screencapture" = {
      "app"    = "com.apple.screencapture"
      "params" = "location"
      "type"   = "-string"
      "value"  = "~/Downloads"
    },
  }
}

output "deploy_dotfiles_list" {
  value = local.dotfiles_list
}

