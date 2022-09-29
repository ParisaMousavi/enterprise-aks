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
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
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
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
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
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
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
  identity_ids = [module.aks_m_id.id]
  aad_config = {
    managed                = true
    admin_group_object_ids = ["5aaba3a6-2f36-4e4e-9f02-5cd94dfd639d"]
    azure_rbac_enabled     = false
    tenant_id              = "0f912e8a-5f68-43ec-9075-1533aaa80442"
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

module "aks_pool" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source                = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-aks-node-pool?ref=main"
  name                  = "mypool"
  kubernetes_cluster_id = module.aks.id
  vm_size               = "Standard_B2s"
  enable_auto_scaling   = true
  node_count            = 1
  min_count             = 1
  max_count             = 1
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

resource "null_resource" "non_interactive_call" {
  depends_on = [module.aks]
  triggers   = { always_run = timestamp() }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/non-interactive.sh ;${path.module}/non-interactive.sh ${module.resourcegroup.name} ${module.aks_name.result}"
    interpreter = ["bash", "-c"]
  }
}

