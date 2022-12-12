data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate"
    storage_account_name = var.remote_state_storage_account_name
    container_name       = "enterprise-network"
    key                  = "terraform.tfstate"
  }
}

data "terraform_remote_state" "monitoring" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate"
    storage_account_name = var.remote_state_storage_account_name
    container_name       = "enterprise-monitoring"
    key                  = "terraform.tfstate"
  }
}


data "azuread_service_principal" "deployment_sp" {
  display_name = "technical-user-for-devops"
}

data "azuread_group" "aks_cluster_admin" {
  display_name     = "AKS Cluster Admin"
  security_enabled = true
}
