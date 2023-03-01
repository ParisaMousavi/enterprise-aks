module "acr_name" {
  source             = "github.com/ParisaMousavi/az-naming//acr?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

# private link: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-private-link
module "acr" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source                        = "github.com/ParisaMousavi/az-acr?ref=main"
  resource_group_name           = module.resourcegroup.name
  location                      = module.resourcegroup.location
  name                          = module.acr_name.result
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = true # use case: for development
  private_endpoint_config = {
    subnet_id           = data.terraform_remote_state.network.outputs.subnets["acr"].id
    private_dns_zone_id = data.terraform_remote_state.network.outputs.privatelink_azurecr_io.id
  }
  network_rule_set = {
    allow_ip_ranges  = [data.external.myipaddr.result.ip] # use case: for development
    allow_subnet_ids = []
    default_action   = "Deny"
  }
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

# az acr import  -n projacrappdevweu --source docker.io/library/nginx:latest --image nginx:v1

# az acr import  -n projacrappdevweu --source mcr.microsoft.com/azuredocs/aks-helloworld:v1 --image aks-helloworld:v1