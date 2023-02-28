module "aks_kv_sec_prov_m_id_name" {
  source             = "github.com/ParisaMousavi/az-naming//mid?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  assembly           = "kv_sec_prov"
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "aks_kv_sec_prov_m_id" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source              = "github.com/ParisaMousavi/az-managed-identity?ref=2022.10.24"
  resource_group_name = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = module.aks_kv_sec_prov_m_id_name.result
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

resource "random_string" "assembly" {
  length  = 2
  lower   = false
  upper   = false
  numeric = true
  special = false
}

module "keyvault_name" {
  source             = "github.com/ParisaMousavi/az-naming//kv?ref=2022.11.30"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  assembly           = random_string.assembly.result
  location_shortname = var.location_shortname
}

# https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = module.resourcegroup.name
  tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

module "keyvault" {
  depends_on = [
    module.aks,
    azurerm_private_dns_zone.this
  ]
  source                          = "github.com/ParisaMousavi/az-key-vault?ref=main"
  resource_group_name             = module.resourcegroup.name
  location                        = module.resourcegroup.location
  name                            = module.keyvault_name.result
  tenant_id                       = var.tenant_id
  stage                           = var.stage
  enabled_for_disk_encryption     = false
  sku_name                        = "standard"
  public_network_access_enabled   = true
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = false
  object_ids                      = [data.azuread_group.aks_cluster_admin.object_id] # module.aks.principal_id
  private_endpoint_config = {
    subnet_id             = data.terraform_remote_state.network.outputs.subnets["key-vault"].id
    virtual_network_id    = data.terraform_remote_state.network.outputs.network_id
    private_dns_zone_id   = azurerm_private_dns_zone.this.id
    private_dns_zone_name = azurerm_private_dns_zone.this.name
  }
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = [data.external.myipaddr.result.ip] # e.g. 95.117.53.15
    virtual_network_subnet_ids = []
  }
}

# Configure workload identity
# https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-identity-access#configure-workload-identity
resource "azurerm_key_vault_access_policy" "this" {
  count                   = local.with_workload_identity == true ? 1 : 0
  key_vault_id            = module.keyvault.id
  tenant_id               = var.tenant_id
  object_id               = module.aks_workload_m_id[0].principal_id
  certificate_permissions = ["Get"]
  key_permissions         = ["Get"]
  secret_permissions      = ["Get"]
}

# self-info
resource "azurerm_key_vault_access_policy" "for_kv_secret_provider" {
  count = local.with_keyvault_secret_store_csi_driver == true ? 1 : 0
  depends_on = [
    module.aks
  ]
  key_vault_id            = module.keyvault.id
  tenant_id               = var.tenant_id
  object_id               = module.aks.key_vault_secrets_provider[0].secret_identity[0].client_id
  certificate_permissions = ["Get"]
  key_permissions         = ["Get"]
  secret_permissions      = ["Get"]
}

# module "keyvault_key_name" {
#   source   = "github.com/ParisaMousavi/az-naming//kv-key?ref=main"
#   prefix   = var.prefix
#   name     = var.name
#   stage    = var.stage
#   assembly = "kms"
# }

# module "keyvault_key_kms" {
#   depends_on = [
#     module.keyvault
#   ]
#   source       = "github.com/ParisaMousavi/az-key-vault//key?ref=main"
#   name         = module.keyvault_key_name.result
#   key_vault_id = module.keyvault.id
# }

resource "azurerm_key_vault_secret" "this" {
  depends_on = [
    module.keyvault
  ]
  name         = "secret-sauce"
  value        = "'Hello!'"
  key_vault_id = module.keyvault.id
}
