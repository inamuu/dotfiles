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
}

output "deploy_dotfiles_list" {
  value = local.dotfiles_list
}

