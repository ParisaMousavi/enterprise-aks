

module "pip_lb_name" {
  source             = "github.com/ParisaMousavi/az-naming//pip?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "pip_lb" {
  count = local.with_customized_lb == true ? 1 : 0
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  depends_on = [
    module.aks
  ]
  source              = "github.com/ParisaMousavi/az-publicip?ref=main"
  resource_group_name = module.aks_node_rg_name.result
  location            = module.resourcegroup.location
  name                = module.pip_lb_name.result
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
  reverse_fqdn        = null
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

# output "loadBalancerIP" {
#   value = module.pip_lb[0].id
# }

# output "NodeResourcegroupName" {
#   value = module.aks_node_rg_name.result
# }

# resource "null_resource" "azure_load_balancer" {
#   count      = local.with_customized_lb == true ? 1 : 0
#   depends_on = [module.aks, module.aks_pool, null_resource.non_interactive_call, module.pip_lb]
#   triggers   = { always_run = timestamp() }
#   provisioner "local-exec" {
#     command     = "kubectl apply -f ./customized-lb/load-balancer-service.yaml "
#     interpreter = ["bash", "-c"]
#     environment = {
#       loadBalancerIP        = module.pip_lb[0].id
#       NodeResourcegroupName = module.aks_node_rg_name.result
#       KUBECONFIG            = "./config"
#     }
#   }
# }
