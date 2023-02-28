# Reference links:
# install extension for az-cli: https://learn.microsoft.com/en-us/cli/azure/azure-cli-extensions-overview#how-to-install-extensions
# Provide an identity to access the Azure Key Vault Provider for Secrets Store CSI Driver: https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-identity-access


#--------------------------------------------
# Install extension
#--------------------------------------------
az config set extension.use_dynamic_install=yes_without_prompt

echo "Checking if you have up-to-date Azure Arc AZ CLI 'aks-preview' extension..."
echo "--------------------------------------\n"
az extension show --name "aks-preview" &> extension_output
if cat extension_output | grep -q "not installed"; then
az extension add --name "aks-preview"
rm extension_output
else
az extension update --name "aks-preview"
rm extension_output
fi
echo ""

export USER_ASSIGNED_CLIENT_ID="$(az identity show -g $resourceGroupName --name $UAMI --query 'clientId' -o tsv)"

az keyvault set-policy -n $KEYVAULT_NAME --key-permissions get --spn $USER_ASSIGNED_CLIENT_ID
az keyvault set-policy -n $KEYVAULT_NAME --secret-permissions get --spn $USER_ASSIGNED_CLIENT_ID
az keyvault set-policy -n $KEYVAULT_NAME --certificate-permissions get --spn $USER_ASSIGNED_CLIENT_ID

export AKS_OIDC_ISSUER="$(az aks show --resource-group $resourceGroupName --name $clusterName --query "oidcIssuerProfile.issuerUrl" -o tsv)"
echo $AKS_OIDC_ISSUER
