# Page reference : https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/custom-locations
#Install the following Azure CLI extensions
az extension add --name connectedk8s
az extension add --name k8s-extension
az extension add --name customlocation

# Or update them
az extension update --name connectedk8s
az extension update --name k8s-extension
az extension update --name customlocation

#Verify completed provider registration for Microsoft.ExtendedLocation
az provider register --namespace Microsoft.ExtendedLocation
az provider register --namespace Microsoft.ExtendedLocation

# Once registered, the RegistrationState state will have the Registered value

# Enable custom locations on your cluster
az connectedk8s enable-features -n <clusterName> -g <resourceGroupName> --features cluster-connect custom-locations

# Sign in to Azure CLI using your user account. Fetch the objectId or id of the Azure AD application used by Azure Arc service. The command you use depends on your version of Azure CLI
az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query objectId -o tsv
az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv

# Sign in to Azure CLI using the service principal. Use the <objectId> or id value from the previous step to enable custom locations on the cluster
az connectedk8s enable-features -n <clustername> -g <resourcegroupname> \
    --features cluster-connect custom-locations --custom-locations-oid <objectId/id>
# The custom locations feature is dependent on the Cluster Connect feature. Both features have to be enabled for custom locations to work
# az connectedk8s enable-features must be run on a machine where the kubeconfig file is pointing to the cluster on which the features are to be enabled.

# Deploy the Azure service cluster extension of the Azure service instance you want to install on your cluster
    # Azure Arc-enabled Data Services : Outbound proxy without authentication and outbound proxy with basic authentication are supported by the Azure Arc-enabled Data Services cluster extension
    # Azure App Service on Azure Arc
    # Event Grid on Kubernetes

# Get the Azure Resource Manager identifier of the Azure Arc-enabled Kubernetes cluster, referenced in later steps as connectedClusterId
az connectedk8s show -n <clusterName> -g <resourceGroupName>  --query id -o tsv

# Get the Azure Resource Manager identifier of the cluster extension deployed on top of Azure Arc-enabled Kubernetes cluster, referenced in later steps as extensionId:
az k8s-extension show --name <extensionInstanceName> --cluster-type connectedClusters -c <clusterName> -g <resourceGroupName>  --query id -o tsv

# Create the custom location by referencing the Azure Arc-enabled Kubernetes cluster and the extension
az customlocation create -n <customLocationName> -g <resourceGroupName> --namespace <name of namespace> --host-resource-id <connectedClusterId> --cluster-extension-ids <extensionIds>

# Show details of a custom location
az customlocation show -n <customLocationName> -g <resourceGroupName>

# List custom locations
az customlocation list -g <resourceGroupName>

# Update a custom location
# Use the update command to add new tags or associate new cluster extension IDs to the custom location while retaining existing tags and associated cluster extensions. --cluster-extension-ids, --tags, assign-identity can be updated
az customlocation update -n <customLocationName> -g <resourceGroupName> --namespace <name of namespace> --host-resource-id <connectedClusterId> --cluster-extension-ids <extensionIds>

# Delete a custom location
az customlocation delete -n <customLocationName> -g <resourceGroupName> --namespace <name of namespace> --host-resource-id <connectedClusterId> --cluster-extension-ids <extensionIds>