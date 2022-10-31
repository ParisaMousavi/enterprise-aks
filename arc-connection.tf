module "rg_name_for_arc" {
  source             = "github.com/ParisaMousavi/az-naming//rg?ref=2022.10.07"
  prefix             = var.prefix
  name               = "for-arc"
  stage              = var.stage
  location_shortname = var.location_shortname
}

module "resourcegroup_for_arc" {
  # https://{PAT}@dev.azure.com/{organization}/{project}/_git/{repo-name}
  source   = "github.com/ParisaMousavi/az-resourcegroup?ref=2022.10.07"
  count    = var.connect_to_arc == false ? 0 : 1
  location = var.location
  name     = module.rg_name_for_arc.result
  tags = {
    CostCenter = "ABC000CBA"
    By         = "parisamoosavinezhad@hotmail.com"
  }
}

resource "null_resource" "arc-connection" {
  depends_on = [module.aks]
  count      = var.connect_to_arc == false ? 0 : 1
  triggers = {
    always_run = timestamp()
    hash       = sha256(file("${path.module}/arc-connection/bash.sh"))
  }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/arc-connection/bash.sh ;${path.module}/arc-connection/bash.sh ${module.resourcegroup.name} ${module.aks_name.result} ${var.location} ${module.resourcegroup_for_arc[0].name}"
    interpreter = ["bash", "-c"]
  }
}

output "aks_cluster_admin_object_id" {
  value = data.azuread_group.aks_cluster_admin.object_id
}

output "aks_cluster_admin_id" {
  value = data.azuread_group.aks_cluster_admin.id
}

resource "azurerm_role_assignment" "one" {
  depends_on = [
    null_resource.arc-connection
  ]
  count                = var.connect_to_arc == false ? 0 : 1
  principal_id         = data.azuread_group.aks_cluster_admin.object_id
  role_definition_name = "Azure Arc Kubernetes Viewer"
  scope                = "/subscriptions/e75710b2-d656-4ee7-bc64-d1b371656208/resourceGroups/proja-rg-for-arc-dev-weu/providers/Microsoft.Kubernetes/connectedClusters/proja-aks-app-dev-aad-weu"
}

resource "azurerm_role_assignment" "two" {
  depends_on = [
    null_resource.arc-connection
  ]
  count                = var.connect_to_arc == false ? 0 : 1
  principal_id         = data.azuread_group.aks_cluster_admin.object_id
  role_definition_name = "Azure Arc Enabled Kubernetes Cluster User Role"
  scope                = "/subscriptions/e75710b2-d656-4ee7-bc64-d1b371656208/resourceGroups/proja-rg-for-arc-dev-weu/providers/Microsoft.Kubernetes/connectedClusters/proja-aks-app-dev-aad-weu"
}
