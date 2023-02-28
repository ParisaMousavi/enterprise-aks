
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

echo "create name space ${ServiceAccountNamespace}"
echo "--------------------------------------"
kubectl create namespace ${ServiceAccountNamespace}

# Establish a federated identity credential between the Azure AD application and the service account issuer and subject. Get the object ID of the Azure AD application. 
echo "create service account"
echo "--------------------------------------"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ${APPLICATION_CLIENT_ID:-${WorkloadClientId}}
  labels:
    azure.workload.identity/use: "true"
  name: ${ServiceAccountName}
  namespace: ${ServiceAccountNamespace}
EOF
