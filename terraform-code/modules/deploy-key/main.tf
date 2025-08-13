variable "repo_name" {
  type        = string
  description = "Name of the repository."
}

resource "tls_private_key" "ed25519_key" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "repo_deploy_key" {
  title      = "${var.repo_name}-key"
  repository = var.repo_name
  key        = tls_private_key.ed25519_key.public_key_openssh
  read_only  = false
}

resource "local_file" "key_file" {
  content  = tls_private_key.ed25519_key.private_key_openssh
  filename = "${path.cwd}/${github_repository_deploy_key.repo_deploy_key.title}.pem"
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${self.filename}"
  }
} # delete file when destroyed. Create in root directory