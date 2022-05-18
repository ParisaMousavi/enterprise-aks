locals {
  repetation = ["dummyaks"]
  subscription = "dev"
  region_short = "we"
  environment = "dev"
}

module "resourcegroup" {
  for_each = toset(local.repetation)
  source = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-resourcegroup?ref=main"
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}

  region             = "westeurope"
  resource_long_name = each.value
  tags = {
    Service         = "network"
    AssetName       = "Asset Name"
    AssetID         = "AB00CD"
    BusinessUnit    = "Network Team"
    Confidentiality = "C1"
    Integrity       = "I1"
    Availability    = "A1"
    Criticality     = "Low"
    Owner           = "parisamoosavinezhad@hotmail.com"
    CostCenter      = ""
  }

}

output "rg_output" {
  value = module.resourcegroup
}


module "identity" {
  source = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-managed-identity?ref=main"
  
}

# module "aks" {
#   source = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-aks?ref=main"

#   resource_group_name                 = module.resourcegroup.name
#   resource_group_location             = module.resourcegroup.location
#   resource_group_id                   = module.resourcegroup.id
#   kubernetes_version                  = "1.19.11"
#   aks_cluster_identity_id             = dependency.identities.outputs.identities["aks-cluster"].id
#   subnets                             = dependency.vnet.outputs.subnets
#   privatelink_private_zone_id         = dependency.dns_zones.outputs.private_zone_ids["privatelink.westeurope.azmk8s.io"]
#   disk_encryption_set_id              = dependency.disk_encryption_set.outputs.disk_encryption_set_id
#   elk_eventhub_name                   = dependency.event_hub_observability.outputs.name
#   elk_eventhub_namespace_auth_rule_id = dependency.event_hub_namespace_observability.outputs.diagnostic_settings_auth_rule_id

#   pool_aks = {
#     node_count = 1
#     min_count  = 1
#     max_count  = 2
#   }
#   pool_ingress1 = {
#     enabled    = true
#     node_count = 2
#     min_count  = 2
#     max_count  = 3
#     vm_size    = "Standard_F2s_v2"
#   }
#   pool_system1 = {
#     enabled    = true
#     node_count = 1
#     min_count  = 1
#     max_count  = 3
#     vm_size    = "Standard_B4ms"
#   }
#   pool_workload1 = {
#     enabled    = true
#     node_count = 0
#     min_count  = 0
#     max_count  = 3
#   }  
# }



# dependency "dns_zones" {
#   config_path                             = "${get_parent_terragrunt_dir()}/dev/west-europe/dev/dns/zones/privatezones"
#   mock_outputs_allowed_terraform_commands = ["validate", "plan"]
#   mock_outputs = {
#     private_zones    = ["privatelink.westeurope.azmk8s.io"]
#     private_zone_ids = { "privatelink.westeurope.azmk8s.io" = "/subscription/00000000-0000-0000-0000-000000000000/mock-name/privatelink.westeurope.azmk8s.io" }
#   }
# }


# dependency "vnet" {
#   config_path                             = "${dirname(find_in_parent_folders("product.hcl"))}/shared/network/vnet"
#   mock_outputs_allowed_terraform_commands = ["validate", "plan"]
#   mock_outputs = {
#     vnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-name/providers/Microsoft.Network/virtualNetworks/mock-name"
#     subnets = {
#       lb-intern = {
#         id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-name/providers/Microsoft.Network/virtualNetworks/mock-name/subnets/mock-name"
#       }
#       nodepool = {
#         id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-name/providers/Microsoft.Network/virtualNetworks/mock-name/subnets/mock-name"
#       }
#     }
#   }
# }


# dependency "identities" {
#   config_path                             = "${dirname(find_in_parent_folders("service.hcl"))}/identities"
#   mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
#   mock_outputs = {
#     identities = {
#       aks-cluster = {
#         id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-name/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mock-name"
#         principal_id = "0000-deadbeef-2face-0000"
#       }
#     }
#   }
# }

# dependency "event_hub_observability" {
#   config_path                             = "${dirname(find_in_parent_folders("product.hcl"))}/observability/eventhub/application-eventhub"
#   mock_outputs_allowed_terraform_commands = ["validate", "plan"]
#   mock_outputs = {
#     name = "mock-name"
#   }
# }

# dependency "event_hub_namespace_observability" {
#   config_path                             = "${dirname(find_in_parent_folders("product.hcl"))}/observability/eventhub/namespace"
#   mock_outputs_allowed_terraform_commands = ["validate", "plan"]
#   mock_outputs = {
#     diagnostic_settings_auth_rule_id = "/subscriptions/00000000-0000-00000-0000-0000000000/resourceGroups/mock-name/providers/Microsoft.EventHub/namespaces/mock-name/authorizationRules/mock-name"
#   }
# }
# dependency "disk_encryption_set" {
#   config_path = "../encryption/disk-encryption-set"

#   mock_outputs = {
#     disk_encryption_set_id = "asdfqwetrz"
#   }
#   mock_outputs_allowed_terraform_commands = ["validate", "plan"]
# }

# dependencies {
#   paths = [
#     "../role_assign/network",
#     "../encryption/disk-encryption-access"
#   ]
# }
