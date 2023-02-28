locals {
  repository = "github-actions"
}

data "github_actions_public_key" "example_public_key" {
  repository = local.repository 
}

resource "github_actions_secret" "aks_cluster_name" {
  repository       = local.repository 
  secret_name      = "aks_cluster_name"
  plaintext_value  = module.aks.name
}

resource "github_actions_secret" "aks_cluster_resourcegroup_name" {
  repository       = local.repository 
  secret_name      = "aks_cluster_resourcegroup_name"
  plaintext_value  = module.resourcegroup.name
}
