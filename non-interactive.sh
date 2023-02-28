# https://docs.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal?tabs=azure-cli

resourcegroupname=$1
aksclustername=$2

export KUBECONFIG=./config

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

echo "az aks get-credentials --overwrite-existing --resource-group $resourcegroupname --name $aksclustername"
# az aks get-credentials --overwrite-existing --resource-group projn-rg-app-dev-weu --name projn-aks-app-dev-weu

az aks get-credentials --overwrite-existing --resource-group "$resourcegroupname" --name "$aksclustername" --file ./config

kubelogin convert-kubeconfig -l spn --client-id $ARM_CLIENT_ID --client-secret $ARM_CLIENT_SECRET

# Azure CNI provides the capability to monitor IP subnet usage. https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni#apply-the-config
kubectl apply -f https://raw.githubusercontent.com/microsoft/Docker-Provider/ci_prod/kubernetes/container-azm-ms-agentconfig.yaml

kubectl get node

