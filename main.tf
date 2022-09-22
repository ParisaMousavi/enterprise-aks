module "rg_name" {
  source             = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-naming//rg?ref=main"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "resourcegroup" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source   = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-resourcegroup?ref=main"
  location = var.location
  name     = module.rg_name.result
  tags = {
    Service         = "Plat. netexc"
    AssetName       = "Asset Name"
    AssetID         = "AB00CD"
    BusinessUnit    = "Plat. netexc Team"
    Confidentiality = "C1"
    Integrity       = "I1"
    Availability    = "A1"
    Criticality     = "Low"
    Owner           = "parisamoosavinezhad@hotmail.com"
    CostCenter      = ""
  }
}

module "acr_name" {
  source             = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-naming//acr?ref=main"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "acr" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source              = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-acr?ref=main"
  resource_group_name = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = module.acr_name.result
  sku                 = "Premium"
  admin_enabled       = "true"
  additional_tags     = {}
}


module "aks_m_id_name" {
  source             = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-naming//mid?ref=main"
  prefix             = var.prefix
  name               = "aks"
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "aks_m_id" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source              = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-managed-identity?ref=main"
  resource_group_name = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = module.aks_m_id_name.result
  additional_tags     = {}
}

module "aks_name" {
  source             = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-naming//aks?ref=main"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "aks_node_rg_name" {
  source             = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-naming//rg?ref=main"
  prefix             = var.prefix
  name               = "aks-node"
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "aks" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source                  = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-aks-v2?ref=main"
  resource_group_name     = module.resourcegroup.name
  node_resource_group     = module.aks_node_rg_name.result
  location                = module.resourcegroup.location
  name                    = module.aks_name.result
  dns_prefix              = "${var.stage}-${var.prefix}-${var.name}"
  kubernetes_version      = "1.23.8"
  private_cluster_enabled = false
  # log_analytics_workspace_id = data.terraform_remote_state.monitoring.outputs.log_analytics_workspace_id
  identity_ids           = [module.aks_m_id.id]
  aad_config = {
    managed                = true
    admin_group_object_ids = ["36863794-54ba-4bfd-8622-67dd214c21dd"]
    azure_rbac_enabled     = false
    tenant_id = "0f912e8a-5f68-43ec-9075-1533aaa80442"
  }
  network_profile = {
    network_plugin     = "azure"
    network_policy     = "azure"
    docker_bridge_cidr = "10.50.0.1/18"
    service_cidr       = "10.50.64.0/18"
    dns_service_ip     = "10.50.64.10"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
  }
  default_node_pool = {
    enable_auto_scaling = true
    node_count          = 1
    max_count           = 1
    min_count           = 1
    max_pods            = 30
    name                = "default"
    os_sku              = "Ubuntu"
    type                = "VirtualMachineScaleSets"
    vnet_subnet_id      = data.terraform_remote_state.network.outputs.subnets["aks"].id
    vm_size             = "Standard_B2s"
  }
  additional_tags = {}
}

resource "azurerm_role_assignment" "this" {
  principal_id                     = module.aks.principal_id
  role_definition_name             = "AcrPull"
  scope                            = module.acr.id
  skip_service_principal_aad_check = true
}

# resource "azurerm_role_assignment" "aks_admin_sp" {
#   principal_id                     = "07cea789-5bb0-4381-9255-17b9f6909aad"
#   role_definition_name             = "Azure Kubernetes Service Cluster Admin Role"
#   scope                            = module.aks.id
#   skip_service_principal_aad_check = true
# }

data "azurerm_resource_group" "aks_node_rg" {
  name = module.aks_node_rg_name.result
  depends_on = [
    module.aks
  ]
}

resource "azurerm_role_assignment" "aks_node_rg" {
  principal_id         = module.aks.principal_id
  scope                = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name = "Virtual Machine Contributor"
  depends_on = [
    module.aks
  ]
}

# resource "null_resource" "aks_arc" {
#   depends_on = [module.aks]
#   triggers   = { always_run = timestamp() }
#   // The order of input values are important for bash
#   provisioner "local-exec" {
#     command     = "chmod +x ${path.module}/bash-arc.sh ;${path.module}/bash-arc.sh ${module.resourcegroup.name} ${module.aks_name.result}"
#     interpreter = ["bash", "-c"]
#   }
# }



# resource "null_resource" "get_cluster_credentials" {
#   depends_on = [module.aks]
#   triggers   = { always_run = timestamp() }
#   provisioner "local-exec" {
#     command     = "az aks get-credentials --overwrite-existing --resource-group ${module.resourcegroup.name} --name ${module.aks_name.result}"
#   }
# }

resource "null_resource" "run_vote_app" {
  depends_on = [module.aks]
  triggers   = { always_run = timestamp() }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/bash-vote.sh ;${path.module}/bash-vote.sh ${module.resourcegroup.name} ${module.aks_name.result}"
    interpreter = ["bash", "-c"]
  }
}

# resource "null_resource" "run_cna_express_app" {
#   depends_on = [module.aks]
#   triggers   = { always_run = timestamp() }
#   // The order of input values are important for bash
#   provisioner "local-exec" {
#     command     = "chmod +x ${path.module}/cna-express/bash-cna-express.sh ;${path.module}/cna-express/bash-cna-express.sh ${module.acr_name.result} ${module.aks_name.result}  ${module.resourcegroup.name}"
#     interpreter = ["bash", "-c"]
#   }
# }


# az aks get-credentials --overwrite-existing --resource-group projn-rg-app-dev-weu --name projn-aks-app-dev-weu

# az aks update -g projn-rg-app-dev-weu -n projn-aks-app-dev-weu --enable-azure-rbac

# AKS_ID=$(az aks show -g projn-rg-app-dev-weu -n projn-aks-app-dev-weu --query id -o tsv)

# az role assignment create --role "Azure Kubernetes Service RBAC Admin" --assignee "07cea789-5bb0-4381-9255-17b9f6909aad" --scope $AKS_ID

# az role assignment create --role "Azure Kubernetes Service RBAC Admin" --assignee "692bcb4d-3198-46c3-9b85-c8eff3fbb90f" --scope $AKS_ID
