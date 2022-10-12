resourcegroupname=$1
aksclustername=$2
location=$3
resourcegroupnameforarc=$4

export KUBECONFIG=./config

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# Registering Azure Arc providers
echo "Registering Azure Arc providers"
az provider register --namespace Microsoft.Kubernetes --wait
az provider register --namespace Microsoft.KubernetesConfiguration --wait
az provider register --namespace Microsoft.ExtendedLocation --wait

az provider show -n Microsoft.Kubernetes -o table
az provider show -n Microsoft.KubernetesConfiguration -o table
az provider show -n Microsoft.ExtendedLocation -o table

# Getting AKS credentials
echo "Getting AKS credentials (kubeconfig)"
echo "az aks get-credentials --overwrite-existing --resource-group $resourcegroupname --name $aksclustername" --file ./config
# az aks get-credentials --overwrite-existing --resource-group proja-rg-app-dev-weu --name proja-aks-app-dev-weu --file ./config
az aks get-credentials --overwrite-existing --resource-group "$resourcegroupname" --name "$aksclustername" --file ./config
kubelogin convert-kubeconfig -l spn --client-id $ARM_CLIENT_ID --client-secret $ARM_CLIENT_SECRET

echo "Clear cached helm Azure Arc Helm Charts"
rm -rf ~/.azure/AzureArcCharts

# Installing Azure Arc k8s CLI extensions
echo "Checking if you have up-to-date Azure Arc AZ CLI 'connectedk8s' extension..."
az extension show --name "connectedk8s" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "connectedk8s"
rm extension_output
else
az extension update --name "connectedk8s"
rm extension_output
fi
echo ""

echo "Checking if you have up-to-date Azure Arc AZ CLI 'k8s-configuration' extension..."
az extension show --name "k8s-configuration" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "k8s-configuration"
rm extension_output
else
az extension update --name "k8s-configuration"
rm extension_output
fi
echo ""

echo "Connecting the cluster to Azure Arc"
# https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/troubleshooting#enable-custom-locations-using-service-principal
# Sign in into Azure CLI using the service principal. Use the Object ID of the Azure AD application used by Azure Arc service for custom location.
# resourcegroupnameforarc=proja-rg-app-dev-weu 
# aksclustername=proja-aks-app-dev-weu
# location=westeurope

az connectedk8s connect --name "$aksclustername" --resource-group "$resourcegroupnameforarc" --location "$location" --custom-locations-oid "22cfa2da-1491-4abc-adb3-c31c8c74cefa"

az connectedk8s enable-features --name "$aksclustername" --resource-group "$resourcegroupnameforarc" --features cluster-connect custom-locations --custom-locations-oid "22cfa2da-1491-4abc-adb3-c31c8c74cefa"

# ARM_ID_CLUSTER=$(az connectedk8s show -n "$aksclustername" -g "$resourcegroupnameforarc" --query id -o tsv)

# AAD_ENTITY_OBJECT_ID=$(az ad sp show --id 07cea789-5bb0-4381-9255-17b9f6909aad --query id -o tsv)

# az role assignment create --role "Azure Arc Kubernetes Viewer" --assignee 3c2e87ec-e9c0-4683-a97c-c6cbe2a5ccbd --scope $ARM_ID_CLUSTER
# az role assignment create --role "Azure Arc Enabled Kubernetes Cluster User Role" --assignee 3c2e87ec-e9c0-4683-a97c-c6cbe2a5ccbd --scope $ARM_ID_CLUSTER

# az connectedk8s proxy -n "$aksclustername" -g "$resourcegroupnameforarc"