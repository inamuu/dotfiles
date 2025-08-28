resource "terraform_data" "brew_bundle" {
  provisioner "local-exec" {
    command = "brew bundle --file ../Brewfile"
  }
  triggers_replace = {
    filesha256 = fileexists("../Brewfile") ? filesha256("../Brewfile") : "absent"
  }
}

resource "local_file" "copy_dotfiles" {
  for_each        = toset(local.dotfiles)
  content         = file("../${each.value}")
  filename        = pathexpand("~/${each.value}")
  file_permission = "0644"
}
