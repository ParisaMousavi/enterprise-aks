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

module "aks" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source                  = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-aks-v2?ref=main"
  resource_group_name     = module.resourcegroup.name
  location                = module.resourcegroup.location
  name                    = module.aks_name.result
  dns_prefix              = "${var.stage}-${var.prefix}-${var.name}"
  kubernetes_version      = "1.23.8"
  private_cluster_enabled = false
  identity_ids = [module.aks_m_id.id]
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