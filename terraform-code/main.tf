locals {
  repos = {
    infra = {
      lang     = "terraform",
      filename = "main.py"
      pages    = true
    },
    backend = {
      lang     = "python",
      filename = "main.py"
      pages    = false
    },
    frontend = {
      lang     = "javascript",
      filename = "main.js"
      pages    = true
    }
  }
  environments = toset(["dev", "prod"])
}

module "repos" {
  source   = "./modules/dev-repos"
  for_each = local.environments
  repo_max = 10
  env      = each.key
  repos    = local.repos
}

# Commenting this out because putting the current repo on public (Keys would be in state)
# module "deploy-key" {
#   for_each  = toset(flatten([for k, v in module.repos : keys(v.clone-urls) if k == "dev"]))
#   source    = "./modules/deploy-key"
#   repo_name = each.key
# }

module "info-page" {
  source = "./modules/info-page"
  repos  = { for k, v in module.repos["prod"].clone-urls : k => v }
}

output "repo-info" {
  value = { for k, v in module.repos : k => v.clone-urls }
}

output "repo-list" {
  value = flatten([for k, v in module.repos : keys(v.clone-urls) if k == "dev"])
}