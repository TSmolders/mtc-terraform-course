output "clone-urls" {
  value = { for i in github_repository.mtc_repo : i.name => {
    ssh_clone_url  = i.ssh_clone_url,
    http_clone_url = i.http_clone_url,
    page_url       = try(i.pages[0].html_url, "no page")
    }
  }
  description = "Repository names and URL"
  sensitive   = false
}