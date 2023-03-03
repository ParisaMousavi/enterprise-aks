# This code is based on
# https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-identity-access
locals {
  aks_servive_account_name      = "workload-identity-sa"
  aks_service_account_namespace = "az-aks-workload-identity-sample"
  # for verifying
  # kubectl get serviceaccounts/workload-identity-sa -n workload-demo  -o yaml
}


module "aks_workload_m_id_name" {
  source             = "github.com/ParisaMousavi/az-naming//mid?ref=2022.10.07"
  prefix             = var.prefix
  name               = var.name
  assembly           = "workload"
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "aks_workload_m_id" {
  count = local.with_workload_identity == true ? 1 : 0
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source              = "github.com/ParisaMousavi/az-managed-identity?ref=2022.10.24"
  resource_group_name = module.resourcegroup.name
  location            = module.resourcegroup.location
  name                = module.aks_workload_m_id_name.result
  additional_tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

resource "null_resource" "create_service_account" {
  count = local.with_workload_identity == true ? 1 : 0
  depends_on = [
    module.aks,
    module.aks_pool,
    null_resource.non_interactive_call
  ]
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/workload-identity/create_service_account.sh; ${path.module}/workload-identity/create_service_account.sh "
    interpreter = ["bash", "-c"]
    environment = {
      ServiceAccountName      = local.aks_servive_account_name
      ServiceAccountNamespace = local.aks_service_account_namespace
      WorkloadClientId        = module.aks_workload_m_id[0].client_id
      KUBECONFIG              = "./config"
    }
  }
}

# Establish a federated identity credential between the Azure AD application and the service account issuer and subject.
# https://azure.github.io/azure-workload-identity/docs/topics/federated-identity-credential.html
resource "azurerm_federated_identity_credential" "this" {
  count = local.with_workload_identity == true ? 1 : 0
  depends_on = [
    null_resource.create_service_account
  ]
  name                = "kubernetes-federated-identity"
  resource_group_name = module.resourcegroup.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  parent_id           = module.aks_workload_m_id[0].id
  subject             = "system:serviceaccount:${local.aks_service_account_namespace}:${local.aks_servive_account_name}"
}
