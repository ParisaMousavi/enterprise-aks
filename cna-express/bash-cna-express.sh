# Build a Docker image and upload it to Azure Container Registry
REGISTRYNAME=$1
CLUSTERNAME=$2
RESOURCEGROUP=$3

# git clone https://github.com/MicrosoftDocs/mslearn-cloud-native-apps-express.git

# cd mslearn-cloud-native-apps-express/src

# az acr build --registry $REGISTRYNAME --image expressimage .

# cd ..

# #Build the management app Docker Image

# cd react/

# az acr build --registry $REGISTRYNAME --image webimage .

# az aks get-credentials --resource-group $RESOURCEGROUP --name $CLUSTERNAME

# kubectl get nodes

# az acr list --resource-group $RESOURCEGROUP --query "[].{acrLoginServer:loginServer}" --output table

# # Deploy your container to AKS

# cd ..
# cd ..

kubectl apply -f ./cna-express/deployment.yaml

kubectl get deploy cna-express

kubectl get pods

kubectl apply -f ./cna-express/service.yaml

kubectl get service cna-express

az aks show --resource-group "projn-rg-app-dev-gwc" --name "projn-aks-app-dev-gwc" -o tsv --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName