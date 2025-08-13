# resource "random_id" "random" {
#   byte_length = 2
#   count       = var.repo_count
# }

resource "github_repository" "mtc_repo" {
  for_each    = var.repos
  name        = "mtc-${each.key}-${var.env}"
  description = "${each.value.lang} Code for MTC tutorial"
  visibility  = var.env == "dev" ? "private" : "public"
  auto_init   = true
  dynamic "pages" {
    for_each = each.value.pages ? [1] : []
    content {
      source {
        branch = "main"
        path   = "/"
      }
    }

  }

  provisioner "local-exec" {
    command = "gh repo view ${self.name} --web"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${self.name}"
  }
}

resource "terraform_data" "repo-clone" {
  depends_on = [github_repository_file.main, github_repository_file.readme]
  for_each   = var.repos
  provisioner "local-exec" {
    command = "gh repo clone ${github_repository.mtc_repo[each.key].name}"
  }
}

resource "github_repository_file" "readme" {
  for_each   = var.repos
  repository = github_repository.mtc_repo[each.key].name
  branch     = "main"
  file       = "README.md"
  # Example content using EOT:
  # content             = <<-EOT
  #                       # This is a ${var.env} ${each.value.lang} repository for ${each.key} developers.
  #                       The infra was last modified by: ${data.github_user.current.name}
  #                       EOT
  # Example content using templatefile()
  content = templatefile("${path.module}/templates/readme.tftpl", {
    env        = var.env,
    lang       = each.value.lang,
    repo       = each.key
    authorname = data.github_user.current.name
  })
  overwrite_on_create = true
}

resource "github_repository_file" "main" {
  for_each            = var.repos
  repository          = github_repository.mtc_repo[each.key].name
  branch              = "main"
  file                = each.value.filename
  content             = "Hello ${each.value.lang}!"
  overwrite_on_create = true
  lifecycle {
    ignore_changes = [
      content,
    ]
  }
}

# Moving/renaming resource in state without destroying:
# moved {
#   from = github_repository_file.index
#   to = github_repository_file.main
# }


