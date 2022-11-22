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

az connectedk8s connect --name "$aksclustername" --resource-group "$resourcegroupnameforarc" --location "$location" --custom-locations-oid "22cfa2da-1491-4abc-adb3-c31c8c74cefa"

echo "Create Service Account to see K8s resources"
echo "-------------------------------------------"
# 1
kubectl create serviceaccount arc-ui-user

# 2
kubectl create clusterrolebinding arc-ui-user-binding --clusterrole cluster-admin --serviceaccount default:arc-ui-user

# 3
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: arc-ui-user-secret
  annotations:
    kubernetes.io/service-account.name: arc-ui-user
type: kubernetes.io/service-account-token
EOF

# 4
TOKEN=$(kubectl get secret arc-ui-user-secret -o jsonpath='{$.data.token}' | base64 -d | sed 's/$/\n/g')

echo $TOKEN > token.txt