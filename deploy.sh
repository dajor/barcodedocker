
###
# Before Login into Docker and Azure
# docker login  
# az login 


export SugarURL="https://ludwigbeck-test.sugaropencloud.eu/"
export SugarUser="admin"
# If your password have special character use escape 
export SugarPassword="43xXCUg4YzLLRaG"

export DockerImage=dajor85570/barcodedocker:v1.8

export APPName=barcodereaderdockertest
export RessourceGroup=lb-barcodereaderdockertest
export Subscription=LudwigBeck
export StorageFunc=barcodereaderdockertest
export StorageFiles=barcodereaderfilestest
export AppServicePlan=barcodereaderdockertest
#docker build --tag $DockerImage .   

#docker push $DockerImage

echo ------------------- Creating Group -------------------

az group create \
--name $RessourceGroup --location  westeurope --subscription $Subscription

echo ------------------- Creating Storage Function -------------------

az storage account create \
--name $StorageFunc \
--location westeurope \
--resource-group $RessourceGroup \
--sku Standard_LRS \
--subscription $Subscription

## yellow error is okay - is more a information

echo ------------------- Creating App Service Plan -------------------

az appservice plan create \
--name $AppServicePlan \
--resource-group $RessourceGroup \
--sku B1 \
--is-linux \
--subscription $Subscription


echo ------------------- Creating Function APP  -------------------

az functionapp create \
--resource-group $RessourceGroup \
--name $APPName \
--storage-account  $StorageFunc \
--plan $AppServicePlan \
--deployment-container-image-name $DockerImage \
--subscription $Subscription

echo ------------------- Creating Storage File for PDF -------------------

az storage account create \
--name $StorageFiles \
--location westeurope \
--resource-group $RessourceGroup \
--sku Standard_LRS \
--subscription $Subscription

echo ------------------- Connect Storage Function -------------------

storageConnectionString=$(az storage account show-connection-string \
--resource-group $RessourceGroup \
--name $StorageFiles --subscription $Subscription \
--query connectionString --output tsv) 

export AZURE_STORAGE_CONNECTION_STRING=$storageConnectionString

echo ------------------- Creating Items on Storage -------------------

az storage container create -n "items" --public-access off 
az storage container create -n "error" --public-access off 

echo ------------------- CDI Information -------------------

az functionapp config appsettings set --name $APPName \
--resource-group $RessourceGroup \
--settings barcodereader_STORAGE=$storageConnectionString \
 SugarURL=$SugarURL \
 SugarUser=$SugarUser \
 SugarPassword=$SugarPassword \
 --subscription $Subscription



az functionapp restart --name $APPName --resource-group $RessourceGroup --subscription $Subscription


# Enable continuous deployment
az functionapp deployment container config \
  --resource-group $RessourceGroup \
  --name $APPName \
  --subscription $Subscription \
  --enable-cd \
  --query CI_CD_URL --output tsv

# Get CI_CD_URL
az functionapp deployment container show-cd-url \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME


#############

#Now upload any files to items ---> and you see it in Sugar 



# And now the best - delete all the points we have done cleanly so we do not have all the storage etc to pay 

#az group delete --name $RessourceGroup  --subscription LudwigBeck --yes
