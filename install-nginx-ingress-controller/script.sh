resourcegroupname=$1
aksclustername=$2

export KUBECONFIG=./config

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

echo "az aks get-credentials --overwrite-existing --resource-group $resourcegroupname --name $aksclustername"
# az aks get-credentials --overwrite-existing --resource-group projn-rg-app-dev-weu --name projn-aks-app-dev-weu

az aks get-credentials --overwrite-existing --resource-group "$resourcegroupname" --name "$aksclustername" --file ./config

kubelogin convert-kubeconfig -l spn --client-id $ARM_CLIENT_ID --client-secret $ARM_CLIENT_SECRET

kubectl get node

NAMESPACE=ingress-basic

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx-b ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $NAMESPACE \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
  --version 4.1.3 \
  --set controller.replicaCount=2 \
  --set controller.nodeSelector."kubernetes\.io/os"=linux \
  --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux \
  --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
  -f ./install-nginx-ingress-controller/internal-ingress.yaml    

#-----------------------------------------
# Verification
#-----------------------------------------
# kubectl run -it --rm aks-ingress-test --image=mcr.microsoft.com/dotnet/runtime-deps:6.0 --namespace $NAMESPACE
# apt-get update && apt-get install -y curl
# curl -L -k http://10.224.0.42/hello-world-two

#-----------------------------------------
# Clean up resources
#-----------------------------------------
# kubectl delete namespace ingress-basic
# helm list --namespace ingress-basic
# helm uninstall ingress-nginx --namespace ingress-basic
# kubectl delete -f aks-helloworld-one.yaml --namespace ingress-basic
# kubectl delete -f aks-helloworld-two.yaml --namespace ingress-basic
# kubectl delete -f hello-world-ingress.yaml