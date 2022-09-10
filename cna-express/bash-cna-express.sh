# Build a Docker image and upload it to Azure Container Registry
REGISTRYNAME=$1
CLUSTERNAME=$2
RESOURCEGROUP=$3

# git clone https://github.com/MicrosoftDocs/mslearn-cloud-native-apps-express.git

cd mslearn-cloud-native-apps-express/src

az acr build --registry $REGISTRYNAME --image expressimage .

cd ..

#Build the management app Docker Image

cd react/

az acr build --registry $REGISTRYNAME --image webimage .

# az aks get-credentials --resource-group $RESOURCEGROUP --name $CLUSTERNAME

# kubectl get nodes

# az acr list --resource-group $RESOURCEGROUP --query "[].{acrLoginServer:loginServer}" --output table

# # Deploy your container to AKS

# cd ..
# cd ..

# kubectl apply -f ./cna-express/deployment.yaml

# kubectl get deploy cna-express

# kubectl get pods

# kubectl apply -f ./cna-express/service.yaml

# kubectl get service cna-express

# # Identify the fully qualified domain name (FQDN) of the host allowed access to the cluster.

# az aks show --resource-group $RESOURCEGROUP --name $CLUSTERNAME -o tsv --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName

# # Deploy the ingress

# kubectl apply -f ./cna-express/ingress.yaml

# # Make sure the ADDRESS column of the output is filled with an IP address. That's the address of your cluster.

# kubectl get ingress cna-express

# # query Azure to find out if our DNS has been created and we can access the website container

# az network dns zone list --output table

# az network dns record-set list -g projn-rg-aks-node-dev-gwc -z 69b1c43028a1489ea348.germanywestcentral.aksapp.io --output table