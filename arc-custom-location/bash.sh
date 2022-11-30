aksclustername=$1
resourcegroupnameforarc=$2
region=$3
# Arc Data Service Extension Name
adsExtensionName=$4
# Custom Location name is used for custom-location's and data-extension's namespace.
customLocationName=$5

echo "--------------------------------------"
echo "aksclustername="$aksclustername
echo "resourcegroupnameforarc="$resourcegroupnameforarc
echo "region="$region
echo "adsExtensionName="$adsExtensionName
echo "customLocationName="$customLocationName
echo "--------------------------------------"

aws eks update-kubeconfig --region $region --name $aksclustername

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

echo "Checking if you have up-to-date Azure Arc AZ CLI 'connectedk8s' extension..."
echo "--------------------------------------\n"
az extension show --name "connectedk8s" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "connectedk8s"
rm extension_output
else
az extension update --name "connectedk8s"
rm extension_output
fi
echo ""

echo "Checking if you have up-to-date Azure Arc AZ CLI 'k8s-extension' extension..."
echo "--------------------------------------\n"
az extension show --name "k8s-extension" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "k8s-extension"
rm extension_output
else
az extension update --name "k8s-extension"
rm extension_output
fi
echo ""

echo "Checking if you have up-to-date Azure Arc AZ CLI 'customlocation' extension..."
echo "--------------------------------------\n"
az extension show --name "customlocation" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "customlocation"
rm extension_output
else
az extension update --name "customlocation"
rm extension_output
fi
echo ""

echo "Checking if you have up-to-date Azure Arc AZ CLI 'k8s-configuration' extension..."
echo "--------------------------------------\n"
az extension show --name "k8s-configuration" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "k8s-configuration"
rm extension_output
else
az extension update --name "k8s-configuration"
rm extension_output
fi
echo ""

echo "Register Microsoft.ExtendedLocation provider"
echo "--------------------------------------\n"
az provider register --namespace Microsoft.ExtendedLocation

echo "Verification of Microsoft.ExtendedLocation provider installaion"
echo "--------------------------------------"
az provider show -n Microsoft.ExtendedLocation -o table

echo "Enable custom locations on your cluster"
echo "Get Custom Locations RP (Enterprise Application) Id"
echo "--------------------------------------"
# Custom Locations RP (Enterprise Application)
customLocationSpId=$(az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)

echo "Enable Custom Locations feature on projected cluster"
echo "--------------------------------------"
# az connectedk8s enable-features must be run on a machine where the kubeconfig file is pointing to the cluster on which the features are to be enabled.
az connectedk8s enable-features -n $aksclustername \
-g $resourcegroupnameforarc \
--features cluster-connect custom-locations \
--custom-locations-oid $customLocationSpId

# deploy the data controller / extension in direct connectivity mode 
echo "Create the Arc data services extension"
echo "--------------------------------------"
# dc's namespace must be the same as custom location's namespace
# reference link for creating a custom location : https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/custom-locations

az k8s-extension create \
--cluster-name ${aksclustername} \
--resource-group ${resourcegroupnameforarc} --name ${adsExtensionName} \
--cluster-type connectedClusters --extension-type microsoft.arcdataservices \
--auto-upgrade false --scope cluster --release-namespace ${customLocationName} \
--config Microsoft.CustomLocation.ServiceAccount=sa-arc-bootstrapper

# Get the Azure Resource Manager identifier of the Azure Arc-enabled Kubernetes cluster
provisionedClusterId=$(az connectedk8s show -n $aksclustername -g $resourcegroupnameforarc  --query id -o tsv)

# Get the Azure Resource Manager identifier of the cluster extension deployed on top of Azure Arc-enabled Kubernetes cluster
extensionId=$(az k8s-extension show --name ${adsExtensionName} --cluster-type connectedClusters -c ${aksclustername} -g ${resourcegroupnameforarc}   --query id -o tsv)

# reference link : https://github.com/fengzhou-msft/azure-cli/blob/ea149713de505fa0f8ae6bfa5d998e12fc8ff509/doc/use_cli_with_git_bash.md
# MSYS_NO_PATHCONV=1 because of Git bash auto translate
# Create the custom location
MSYS_NO_PATHCONV=1 az customlocation create -n ${customLocationName} -g ${resourcegroupnameforarc} \
    --namespace ${customLocationName} --host-resource-id ${provisionedClusterId} \
    --cluster-extension-ids ${extensionId} --assign-identity "SystemAssigned" \
    --location westeurope

az customlocation show -n ${customLocationName} -g ${resourcegroupnameforarc}

