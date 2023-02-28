locals {
  acr_private_dns_zone_name = "privatelink.azurecr.io"
}
module "acr_name" {
  source             = "github.com/ParisaMousavi/az-naming//acr?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

resource "azurerm_private_dns_zone" "this_azurecr" {
  name                = local.acr_private_dns_zone_name
  resource_group_name = module.resourcegroup.name
  tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${var.name}-vnet2dns"
  resource_group_name   = module.resourcegroup.name
  private_dns_zone_name = azurerm_private_dns_zone.this_azurecr.name
  virtual_network_id    = data.terraform_remote_state.network.outputs.network_id
}


module "acr" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source                        = "github.com/ParisaMousavi/az-acr?ref=main"
  resource_group_name           = module.resourcegroup.name
  location                      = module.resourcegroup.location
  name                          = module.acr_name.result
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
  private_endpoint_config = {
    subnet_id           = data.terraform_remote_state.network.outputs.subnets["acr"].id
    private_dns_zone_id = azurerm_private_dns_zone.this_azurecr.id
  }
  network_rule_set = {
    allow_ip_ranges  = [data.external.myipaddr.result.ip]
    allow_subnet_ids = []
    default_action   = "Deny"
  }
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}