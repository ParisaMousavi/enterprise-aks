aksclustername=$1
resourcegroupnameforarc=$2
logAnalyticsWorkspaceResourceID=$3

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# Installing Azure Arc k8s CLI extensions
echo "Checking if you have up-to-date Azure Arc AZ CLI 'connectedk8s' extension..."
echo "--------------------------------------------"
az extension show --name "connectedk8s" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "connectedk8s"
rm extension_output
else
az extension update --name "connectedk8s"
rm extension_output
fi
echo ""

echo "Make config with Log Analytics Workspace ID"
echo "--------------------------------------------"
# logAnalyticsWorkspaceResourceID=$(az monitor log-analytics workspace show --resource-group projn-rg-monitoring-dev-weu --workspace-name projn-log-monitoring-dev-weu --query id -o tsv)
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
