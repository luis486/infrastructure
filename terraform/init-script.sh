#!/bin/bash

set -e

resourceGroupName=$(terraform output -raw resource_group_name)
applicationGatewayName=$(terraform output -raw application_gateway_name)
acr_name=$(terraform output -raw acr_name)
clusterName=$(terraform output -raw cluster_name)
appgwId=$(az network application-gateway list -g $resourceGroupName --query "[?name=='$applicationGatewayName'].id" -o tsv)
export AKS_OIDC_ISSUER="$(az aks show --resource-group $resourceGroupName --name $clusterName --query "oidcIssuerProfile.issuerUrl" -o tsv)"



az aks enable-addons -n $clusterName -g $resourceGroupName -a ingress-appgw --appgw-id $appgwId
az aks update -g $resourceGroupName -n $clusterName --enable-managed-identity
az acr login --name $acr_name



echo "Script ejecutado correctamente."