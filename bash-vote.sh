# https://docs.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal?tabs=azure-cli

resourcegroupname=$1
aksclustername=$2

az aks get-credentials --overwrite-existing --resource-group "$resourcegroupname" --name "$aksclustername"

kubectl get nodes

kubectl apply -f azure-vote.yaml

kubectl get service azure-vote-front --watch