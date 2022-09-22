# https://docs.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal?tabs=azure-cli

resourcegroupname=$1
aksclustername=$2

# az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# az aks update -g projn-rg-app-dev-weu -n projn-aks-app-dev-weu --enable-azure-rbac

# AKS_ID=$(az aks show -g projn-rg-app-dev-weu -n projn-aks-app-dev-weu --query id -o tsv)

# az role assignment create --role "Azure Kubernetes Service RBAC Admin" --assignee "07cea789-5bb0-4381-9255-17b9f6909aad" --scope $AKS_ID

export KUBECONFIG=~/.kube/config

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# az aks get-credentials --resource-group projn-rg-app-dev-weu --name projn-aks-app-dev-weu --overwrite-existing --file ~/.kube/config

echo "az aks get-credentials --overwrite-existing --resource-group $resourcegroupname --name $aksclustername"

az aks get-credentials --overwrite-existing --resource-group "$resourcegroupname" --name "$aksclustername" --file ~/.kube/config



# echo $ARM_CLIENT_ID
# echo $ARM_CLIENT_SECRET
# echo $KUBECONFIG

kubelogin convert-kubeconfig -l spn --client-id $ARM_CLIENT_ID --client-secret $ARM_CLIENT_SECRET

kubectl get node

# kubectl apply -f azure-vote.yaml

# kubectl get service azure-vote-front --watch
