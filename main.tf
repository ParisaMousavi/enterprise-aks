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
  source             = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-naming//ac?ref=main"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

# module "acr" {
#   # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
#   source   = "git::https://eh4amjsb2v7ke7yzqzkviryninjny3urbbq3pbkor25hhdbo5kea@dev.azure.com/p-moosavinezhad/az-iac/_git/az-acr?ref=main"
#   location = var.location
#   name     = module.rg_name.result
#   tags = {
#     Service         = "Plat. netexc"
#     AssetName       = "Asset Name"
#     AssetID         = "AB00CD"
#     BusinessUnit    = "Plat. netexc Team"
#     Confidentiality = "C1"
#     Integrity       = "I1"
#     Availability    = "A1"
#     Criticality     = "Low"
#     Owner           = "parisamoosavinezhad@hotmail.com"
#     CostCenter      = ""
#   }
# }