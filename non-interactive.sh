# https://docs.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal?tabs=azure-cli

resourcegroupname=$1
aksclustername=$2

export KUBECONFIG=./config

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

echo "az aks get-credentials --overwrite-existing --resource-group $resourcegroupname --name $aksclustername"
# az aks get-credentials --overwrite-existing --resource-group projn-rg-app-dev-weu --name projn-aks-app-dev-weu

az aks get-credentials --overwrite-existing --resource-group "$resourcegroupname" --name "$aksclustername" --file ./config

kubelogin convert-kubeconfig -l spn --client-id $ARM_CLIENT_ID --client-secret $ARM_CLIENT_SECRET

kubectl get node

# Azure Kubernetes Service AAD Client

# https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-4.4.2/ingress-nginx-4.4.2.tgz

# helm push hello-world-0.1.0.tgz oci://$ACR_NAME.azurecr.io/helm

# REGISTRY_NAME=$ACR_NAME
# SOURCE_REGISTRY=k8s.gcr.io
# CONTROLLER_IMAGE=ingress-nginx/controller
# CONTROLLER_TAG=v1.2.1
# PATCH_IMAGE=ingress-nginx/kube-webhook-certgen
# PATCH_TAG=v1.1.1
# DEFAULTBACKEND_IMAGE=defaultbackend-amd64
# DEFAULTBACKEND_TAG=1.5

# az acr import --name $REGISTRY_NAME --source $SOURCE_REGISTRY/$CONTROLLER_IMAGE:$CONTROLLER_TAG --image $CONTROLLER_IMAGE:$CONTROLLER_TAG
# az acr import --name $REGISTRY_NAME --source $SOURCE_REGISTRY/$PATCH_IMAGE:$PATCH_TAG --image $PATCH_IMAGE:$PATCH_TAG
# az acr import --name $REGISTRY_NAME --source $SOURCE_REGISTRY/$DEFAULTBACKEND_IMAGE:$DEFAULTBACKEND_TAG --image $DEFAULTBACKEND_IMAGE:$DEFAULTBACKEND_TAG