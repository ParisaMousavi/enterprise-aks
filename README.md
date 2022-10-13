# Push changes in Azure DevOps Repo & GitHub
```
git remote set-url --add --push origin https://github.com/ParisaMousavi/enterprise-aks.git

git remote set-url --add --push origin https://p-moosavinezhad@dev.azure.com/p-moosavinezhad/az-iac/_git/enterprise-aks
```

**https://stacksimplify.com/azure-aks/create-aks-nodepools-using-terraform/**

# Install ML Extension
az k8s-extension create --name proja-ml-ext-app-dev-weu \
                        --extension-type Microsoft.AzureML.Kubernetes \
                        --config enableTraining=True \
                        enableInference=True \
                        inferenceRouterServiceType=LoadBalancer \
                        allowInsecureConnections=True \
                        inferenceLoadBalancerHA=False \
                        --cluster-type managedClusters \
                        --cluster-name proja-aks-app-dev-weu \
                        --resource-group proja-rg-for-arc-dev-weu \
                        --scope cluste

# Links
- https://learn.microsoft.com/en-us/azure/machine-learning/how-to-deploy-kubernetes-extension?tabs=deploy-extension-with-cli#review-azureml-extension-configuration-settings
- https://learn.microsoft.com/en-us/azure/machine-learning/how-to-deploy-kubernetes-extension?tabs=portal
- https://learn.microsoft.com/en-us/cli/azure/k8s-extension?view=azure-cli-latest
- https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/event-grid/kubernetes/install-k8s-extension.md
- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/extensions?source=recommendations
- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-extensions?source=recommendations
- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster?tabs=azure-cli
- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/troubleshooting?source=recommendations
- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/extensions
- https://techcommunity.microsoft.com/t5/azure-arc-blog/realizing-machine-learning-anywhere-with-azure-kubernetes/ba-p/3470783
