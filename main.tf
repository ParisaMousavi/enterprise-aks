module "rg_name" {
  source             = "github.com/ParisaMousavi/az-naming//rg?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "resourcegroup" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source   = "github.com/ParisaMousavi/az-resourcegroup?ref=2022.10.07"
  location = var.location
  name     = module.rg_name.result
  tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

module "acr_name" {
  source             = "github.com/ParisaMousavi/az-naming//acr?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "acr" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source              = "github.com/ParisaMousavi/az-acr?ref=2022.10.07"
  resource_group_name = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = module.acr_name.result
  sku                 = "Premium"
  admin_enabled       = "true"
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

module "aks_cluster_m_id_name" {
  source             = "github.com/ParisaMousavi/az-naming//mid?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  assembly           = "aks-cluster"
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "aks_cluster_m_id" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source              = "github.com/ParisaMousavi/az-managed-identity?ref=2022.10.24"
  resource_group_name = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = module.aks_cluster_m_id_name.result
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

module "aks_kubelet_m_id_name" {
  source             = "github.com/ParisaMousavi/az-naming//mid?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  assembly           = "aks-kubelet"
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "aks_kubelet_m_id" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source              = "github.com/ParisaMousavi/az-managed-identity?ref=2022.10.24"
  resource_group_name = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = module.aks_kubelet_m_id_name.result
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

module "aks_name" {
  source             = "github.com/ParisaMousavi/az-naming//aks?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "aks_node_rg_name" {
  source             = "github.com/ParisaMousavi/az-naming//rg?ref=2022.10.07"
  prefix             = var.prefix
  name               = "aks-node"
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "aks" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source                           = "github.com/ParisaMousavi/az-aks-v2?ref=2022.10.24"
  resource_group_name              = module.resourcegroup.name
  node_resource_group              = module.aks_node_rg_name.result
  location                         = module.resourcegroup.location
  name                             = module.aks_name.result
  dns_prefix                       = "${var.stage}-${var.prefix}-${var.name}"
  kubernetes_version               = "1.23.8"
  private_cluster_enabled          = false
  oidc_issuer_enabled              = false
  http_application_routing_enabled = false
  kubelet_identity = {
    client_id                 = module.aks_kubelet_m_id.client_id
    object_id                 = module.aks_kubelet_m_id.principal_id # Object (principal) ID
    user_assigned_identity_id = module.aks_kubelet_m_id.id
  }
  # log_analytics_workspace_id = data.terraform_remote_state.monitoring.outputs.log_analytics_workspace_id
  identity_ids = [module.aks_cluster_m_id.id]
  aad_config = {
    managed                = true
    admin_group_object_ids = ["3c2e87ec-e9c0-4683-a97c-c6cbe2a5ccbd"]
    azure_rbac_enabled     = false
    tenant_id              = var.tenant_id
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
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

resource "azurerm_role_assignment" "this" {
  principal_id                     = module.aks.principal_id
  role_definition_name             = "AcrPull"
  scope                            = module.acr.id
  skip_service_principal_aad_check = true
}

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

#----------------------------------------------------------
# Based on this document I have noticed that I have to
# give this role to the Cluster User-Assigned Managed Identity
# https://learn.microsoft.com/en-us/azure/aks/use-managed-identity#add-role-assignment
#
# After this role assignment I could user the kubelet_identity for my AKS
#----------------------------------------------------------
resource "azurerm_role_assignment" "aks_cluster_m_id_mio_on_cluster_rg" {
  principal_id                     = module.aks_cluster_m_id.principal_id
  role_definition_name             = "Managed Identity Operator"
  scope                            = module.resourcegroup.id
  skip_service_principal_aad_check = true
}


# #----------------------------------------------------------
# # Use it to deploy linux user node pool 
# #----------------------------------------------------------
# module "aks_pool" {
#   # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
#   source                = "github.com/ParisaMousavi/az-aks-node-pool?ref=2022.10.24"
#   name                  = "mypool"
#   kubernetes_cluster_id = module.aks.id
#   vm_size               = "Standard_B2s"
#   enable_auto_scaling   = true
#   node_count            = 1
#   min_count             = 1
#   max_count             = 2
#   vnet_subnet_id        = data.terraform_remote_state.network.outputs.subnets["aks"].id
#   zones                 = []
#   additional_tags = {
#     CostCenter = "ABC000CBA"
#     By         = "parisamoosavinezhad@hotmail.com"
#   }
# }

# #----------------------------------------------------------
# # Use it to deploy windows user node pool 
# #----------------------------------------------------------
# module "aks_pool_win" {
#   # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
#   source                = "github.com/ParisaMousavi/az-aks-node-pool?ref=2022.10.24"
#   name                  = "mypwin"
#   kubernetes_cluster_id = module.aks.id
#   vm_size               = "Standard_B2s"
#   enable_auto_scaling   = true
#   node_count            = 1
#   min_count             = 1
#   max_count             = 2
#   vnet_subnet_id        = data.terraform_remote_state.network.outputs.subnets["aks"].id
#   zones                 = []
#   os_type               = "Windows"
#   additional_tags = {
#     CostCenter = "ABC000CBA"
#     By         = "parisamoosavinezhad@hotmail.com"
#   }
# }

resource "null_resource" "non_interactive_call" {
  depends_on = [module.aks]
  triggers   = { always_run = timestamp() }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/non-interactive.sh ;${path.module}/non-interactive.sh ${module.resourcegroup.name} ${module.aks_name.result}"
    interpreter = ["bash", "-c"]
  }
}

