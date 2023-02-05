# refernce pages
# https://learn.microsoft.com/en-us/azure/container-registry/container-registry-helm-repos

ACR_NAME=projacrappdevweu
USER_NAME="helmtoken"

PASSWORD=$(az acr token create -n $USER_NAME \
                  -r $ACR_NAME \
                  --scope-map _repositories_admin \
                  --only-show-errors \
                  --query "credentials.passwords[0].value" -o tsv)

helm registry login $ACR_NAME.azurecr.io \
  --username $USER_NAME \
  --password $PASSWORD



echo "-------------------------------------"
echo "Push chart to registry as OCI artifact"
echo "-------------------------------------"
helm push hello-world-0.1.0.tgz oci://$ACR_NAME.azurecr.io/helm

# List charts in the repository
az acr repository show \
  --name $ACR_NAME \
  --repository helm/hello-world

# List all repos
az acr repository list --name $ACR_NAME

# List Helm charts from your ACR
az acr helm list -n $ACR_NAME


# Install Helm chart
helm install releaseone oci://$ACR_NAME.azurecr.io/helm/hello-world --version 0.1.0

# verify the installation
helm get manifest myhelmtest

helm uninstall myhelmtest

echo "-------------------------------------"
echo "List charts in the repository"
echo "-------------------------------------"
az acr repository show \
  --name $ACR_NAME \
  --repository helm/hello-world

echo "-------------------------------------"
echo "Install Helm chart"
echo "-------------------------------------"
helm install myhelmtest oci://$ACR_NAME.azurecr.io/helm/hello-world --version 0.1.0


echo "-------------------------------------"
echo "Push charts as OCI artifacts to registry"
echo "-------------------------------------"
az acr login --name $ACR_NAME

helm push ingress-nginx-4.4.2.tgz oci://$ACR_NAME.azurecr.io/helm

az acr repository list --name $ACR_NAME


echo "-------------------------------------"
echo "List charts"
echo "-------------------------------------"
helm search repo

# for acr
helm search repo projacrappdevweu

helm repo projacrappdevweu add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

