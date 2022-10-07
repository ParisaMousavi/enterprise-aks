output "acr_login_server" {
  value = module.acr.login_server
}

output "aks_cluster_id" {
  value = module.aks.id
}

output "aks_cluster_resourcegroup_name" {
  value = module.resourcegroup.name
}
