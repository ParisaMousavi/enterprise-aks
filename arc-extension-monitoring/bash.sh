aksclustername=$1
resourcegroupnameforarc=$2
logAnalyticsWorkspaceResourceID=$3

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

echo "Checking if you have up-to-date Azure Arc AZ CLI 'k8s-extension' extension..."
echo "--------------------------------------------"
az extension show --name "k8s-extension" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "k8s-extension"
rm extension_output
else
az extension update --name "k8s-extension"
rm extension_output
fi
echo ""

echo "Make config with Log Analytics Workspace ID"
echo "--------------------------------------------"
logAnalyticsWorkspaceResourceID="logAnalyticsWorkspaceResourceID="$logAnalyticsWorkspaceResourceID
echo $logAnalyticsWorkspaceResourceID

echo "Install monitoring extension on kubernetes"
echo "--------------------------------------------"
MSYS_NO_PATHCONV=1 az k8s-extension create --name azuremonitor-containers \
--cluster-name $aksclustername \
--resource-group $resourcegroupnameforarc \
--cluster-type connectedClusters \
--extension-type Microsoft.AzureMonitor.Containers \
--configuration-settings $logAnalyticsWorkspaceResourceID
