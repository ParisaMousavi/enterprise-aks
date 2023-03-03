# locals {
#   repository = "github-actions"
# }

# data "github_actions_public_key" "example_public_key" {
#   repository = local.repository
# }

# resource "github_actions_secret" "aks_cluster_name" {
#   repository      = local.repository
#   secret_name     = "aks_cluster_name"
#   plaintext_value = module.aks.name
# }

# resource "github_actions_secret" "aks_cluster_resourcegroup_name" {
#   repository      = local.repository
#   secret_name     = "aks_cluster_resourcegroup_name"
#   plaintext_value = module.resourcegroup.name
# }

# Pass the namespace to github to deploy workload identity demo via GitHub action.
# GitHub Action Name: https://github.com/ParisaMousavi/github-actions/actions/workflows/az-aks-workload-identity-sample.yml
# resource "github_actions_secret" "Workload_Identity_Sample_Namespace" {
#   depends_on = [
#     azurerm_federated_identity_credential.this
#   ]
#   repository      = local.repository
#   secret_name     = "Workload_Identity_Sample_Namespace"
#   plaintext_value = local.aks_service_account_namespace
# }

# resource "github_actions_secret" "KEYVAULT_URL" {
#   depends_on = [
#     azurerm_federated_identity_credential.this
#   ]
#   repository      = local.repository
#   secret_name     = "KEYVAULT_URL"
#   plaintext_value = module.keyvault.vault_uri
# }