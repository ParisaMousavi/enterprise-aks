output "acr_login_server" {
  value = module.acr.login_server
}

output "aks_cluster_id" {
  value = module.aks.id
}


output "aks_cluster_name" {
  value = module.aks.name
}

output "aks_cluster_resourcegroup_name" {
  value = module.resourcegroup.name
}


output "aks_http_application_routing_zone_name" {
  value = module.aks.http_application_routing_zone_name
}