resource "local_file" "test_copy_dotfiles" {
  content         = file("${path.module}/.terraform-version")
  filename        = "/tmp/.terraform-version"
  file_permission = "0644"
}

resource "terraform_data" "brew_bundle" {
  provisioner "local-exec" {
    command = "brew bundle --file ../.config/homebrew/Brewfile"
  }
  triggers_replace = {
    filesha256 = fileexists("../.config/homebrew/Brewfile") ? filesha256("../.config/homebrew/Brewfile") : "absent"
  }
}

# Copy dotfiles to home directory
#resource "local_file" "copy_dotfiles" {
#  for_each        = toset(local.dotfiles_list)
#  content         = file("../${each.value}")
#  filename        = pathexpand("~/${each.value}")
#  file_permission = "0644"
#}

### 差分取り込み
#resource "terraform_data" "check_and_copy_dotfiles" {
#  for_each = var.sync ? toset(local.dotfiles_list) : []
#
#  provisioner "local-exec" {
#    command = <<-EOT
#      if ! /usr/bin/diff -q "${pathexpand("~/${each.value}")}" "${path.module}/../${each.value}" >/dev/null 2>&1; then
#          cp -f "${pathexpand("~/${each.value}")}" "${path.module}/../${each.value}"
#          echo "コピー完了: ${each.value}"
#      else
#        echo "差分なし: ${each.value}"
#      fi
#    EOT
#  }

#triggers_replace = {
#  # ファイルのハッシュが変更された場合に再実行
#  file_hash = fileexists("../${each.value}") ? filesha256("../${each.value}") : "absent"
#  # ホームディレクトリのファイルハッシュも含める
#  home_file_hash = fileexists(pathexpand("~/${each.value}")) ? filesha256(pathexpand("~/${each.value}")) : "absent"
#}
#}

#data "external" "sig" {
#  for_each = local.defaults_apps
#  program = ["bash", "-lc", <<-EOF
#VALUE=$(defaults read ${each.value.app} ${each.value.params} 2>/dev/null || true)
#if [ -z "$VALUE" ]; then
#  printf "{ \"value\": \"${each.value.value}\" }"
#else
#  printf '%s' "$VALUE" | jq -Rs "{ \"${each.value.value}\": .}"
#fi
#EOF
#  ]
#  query = {
#    timestamp = timestamp()
#  }
#}

resource "terraform_data" "defaults_app" {
  for_each = local.defaults_apps
  provisioner "local-exec" {
    command = "defaults write ${try(each.value.global, true) ? "-g" : ""} ${each.value.app} ${each.value.params} ${each.value.type} ${each.value.value}"
  }
  triggers_replace = {
    keys = keys(local.defaults_apps)
  }
}

resource "terraform_data" "killall" {
  provisioner "local-exec" {
    command = "killall Dock; killall Finder"
  }

  triggers_replace = {
    "killall" = keys(resource.terraform_data.defaults_app)
  }
}

# Link dotfiles to home directory if not exists
resource "terraform_data" "link_dotfiles" {
  for_each = {
    for f in tolist(local.dotfiles_list) : f => f
  }

  provisioner "local-exec" {
    command = "ln -s ${abspath("${path.module}/../${each.value}")} ${pathexpand("~/${each.value}")}"
  }
}

# Link .config directory to home directory
resource "terraform_data" "link_config" {
  provisioner "local-exec" {
    command = "ln -s ${abspath("${path.module}/../.config")} ${pathexpand("~/.config")}"
  }
}

