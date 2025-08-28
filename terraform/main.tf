resource "terraform_data" "brew_bundle" {
  provisioner "local-exec" {
    command = "brew bundle --file ../Brewfile"
  }
  triggers_replace = {
    filesha256 = fileexists("../Brewfile") ? filesha256("../Brewfile") : "absent"
  }
}
