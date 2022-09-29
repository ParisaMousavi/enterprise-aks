output "acr_login_server" {
  value = module.acr.others.login_server
}

output "aks_cluster_id" {
  value = module.aks.id
}

output "aks_cluster_resourcegroup" {
  value = module.resourcegroup.name
}
