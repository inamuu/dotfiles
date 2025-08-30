resource "local_file" "test_copy_dotfiles" {
  content         = file("${path.module}/.terraform-version")
  filename        = "/tmp/.terraform-version"
  file_permission = "0644"
}

resource "terraform_data" "brew_bundle" {
  provisioner "local-exec" {
    command = "brew bundle --file ../Brewfile"
  }
  triggers_replace = {
    filesha256 = fileexists("../Brewfile") ? filesha256("../Brewfile") : "absent"
  }
}

resource "local_file" "copy_dotfiles" {
  for_each        = toset(local.dotfiles_list)
  content         = file("../${each.value}")
  filename        = pathexpand("~/${each.value}")
  file_permission = "0644"
}

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

### 毎回動かない
data "external" "sig" {
  for_each = local.defaults_apps
  program = ["bash", "-lc", <<-EOF
VALUE=$(defaults read ${each.value.app} ${each.value.params} 2>/dev/null || true)
if [ -z "$VALUE" ]; then
  printf "{\"${each.value.params}\": \"null\" }"
else
  printf '%s' "$VALUE" | jq -Rs "{ \"${each.value.params}\": .}"
fi
EOF
  ]
}

resource "terraform_data" "defaults_app" {
  for_each = local.defaults_apps
  provisioner "local-exec" {
    command = "defaults write ${try(each.value.global, true) ? "-g" : ""} ${each.value.app} ${each.value.params} ${each.value.type} ${each.value.value}"
  }
  #triggers_replace = {
  #  "${each.value.params}" = data.external.sig[each.key].result[each.value.value]
  #}
}

resource "terraform_data" "killall" {
  provisioner "local-exec" {
    command = "killall Dock; killall Finder"
  }

  triggers_replace = {
    "killall" = keys(resource.terraform_data.defaults_app)
  }
}
