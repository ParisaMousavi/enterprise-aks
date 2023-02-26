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

# output "ingress_ip_address" {
#   value = module.pip.ip_address
# }

output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}

output "aks_workload_identity" {
  value = local.with_workload_identity == true ? {
    name         = module.aks_workload_m_id_name.result,
    id           = module.aks_workload_m_id[0].id,
    principal_id = module.aks_workload_m_id[0].principal_id,
    client_id    = module.aks_workload_m_id[0].client_id
  } : null
}


output "aks_key_vault_secrets_provider" {
  value = local.with_keyvault_secret_store_csi_driver == true ? module.aks.key_vault_secrets_provider : null
}

output "vault_uri" {
  value = module.keyvault.vault_uri
}