#--------------------------------------------
# Install extension
#--------------------------------------------
echo "Install extension aks-preview"
az config set extension.use_dynamic_install=yes_without_prompt

echo "Checking if you have up-to-date Azure Arc AZ CLI 'aks-preview' extension..."
echo "--------------------------------------"
az extension show --name "aks-preview" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "aks-preview"
rm extension_output
else
az extension update --name "aks-preview"
rm extension_output
fi
echo ""

# az aks show -g "proja-rg-app-dev-aks-w-aad-weu" -n "proja-aks-app-dev-aad-weu" | grep -i "logAnalyticsWorkspaceResourceID"

# az aks disable-addons -a monitoring -g "proja-rg-app-dev-aks-w-aad-weu" -n "proja-aks-app-dev-aad-weu"

# az aks update -g "proja-rg-app-dev-aks-w-aad-weu" -n "proja-aks-app-dev-aad-weu" --enable-managed-identity

# MSYS_NO_PATHCONV=1 az aks enable-addons -a monitoring --enable-msi-auth-for-monitoring -g ${ResourcegroupName} -n ${AksClusterName} --workspace-resource-id ${WorkspaceId}
