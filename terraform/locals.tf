locals {
  # ファイル一覧を生成
  all_dotfiles = fileset("${abspath(path.module)}/..", ".*")

  # 除外ファイル一覧
  exclude_files = [
    ".DS_Store",
    ".gitignore"
  ]
  # 除外ファイルを除外したファイル一覧
  dotfiles = [ for f in local.all_dotfiles : f if !contains(local.exclude_files, f)]

  # デプロイ対象のdotfiles
  dotfiles_json = jsonencode(local.dotfiles)
}

output "deploy_dotfiles_list" {
  value = local.dotfiles_json
}

