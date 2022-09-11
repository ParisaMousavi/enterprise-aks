data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate"
    storage_account_name = "parisatfstateaziac"
    container_name       = "enterprise-network"
    key                  = "terraform.tfstate"
  }
}

data "terraform_remote_state" "monitoring" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate"
    storage_account_name = "parisatfstateaziac"
    container_name       = "enterprise-monitoring"
    key                  = "terraform.tfstate"
  }
}

output "jsdhsjdhajk" {
  value = data.terraform_remote_state.monitoring
}