terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "parisatfstateaziac"
    container_name       = "enterprise-aks"
    key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}