#Variables
RESOURCE_GROUP="unified-streaming-platform-on-aks"
LOCATION="northeurope"
AKS_NAME="usp-demo"
AZURE_STORAGE_NAME="originfiles"
SHARE_NAME="assets"

#Create resource group
az group create -n $RESOURCE_GROUP -l $LOCATION

# Create AKS cluster
az aks create -n $AKS_NAME -g $RESOURCE_GROUP --node-count 1 --generate-ssh-keys

#Get the context for the new AKS
az aks get-credentials -n $AKS_NAME -g $RESOURCE_GROUP

#Create Azure Storage Account
az storage account create --name $AZURE_STORAGE_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS

#Create File Share
az storage share create --account-name $AZURE_STORAGE_NAME --name $SHARE_NAME


#Download tears of steel locally
wget http://repository.unified-streaming.com/tears-of-steel.zip

#Unzip it
unzip tears-of-steel.zip -d tears-of-steel

#Upload it to assets file share
STORAGE_KEY=$(az storage account keys list -g $RESOURCE_GROUP -n $AZURE_STORAGE_NAME --query '[0].value' -o tsv)
az storage file upload-batch --destination $SHARE_NAME --source tears-of-steel/. --account-name $AZURE_STORAGE_NAME --account-key $STORAGE_KEY

#Create a secret with azure storage credentials
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$AZURE_STORAGE_NAME --from-literal=azurestorageaccountkey=$STORAGE_KEY

#Create a secret with the USP key
kubectl create secret generic usp-licence --from-file=key

#Generate new image and push to Docker Hub
cd usp-origin
docker build --no-cache -t 0gis0/usp-origin .
docker push 0gis0/usp-origin

#Get public IP for the service
kubectl get svc usp-service

#Delete all
az group delete -n $RESOURCE_GROUP -y