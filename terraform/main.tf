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

# Link directories to home directory
resource "terraform_data" "link_dirs" {
  for_each = toset(local.link_dirs)

  provisioner "local-exec" {
    command = "ln -s ${abspath("${path.module}/../${each.value}")} ${pathexpand("~/${each.value}")}"
  }
}

