
export SugarURL="https://ludwigbeck-dev.crm-couch.com/"
export SugarUser="******"
# If your password have special character use escape 
export SugarPassword="*****"

export DockerImage=dajor85570/barcodedocker:v1.8

docker build --tag $DockerImage .   

docker push $DockerImage

storageConnectionString=$(az storage account show-connection-string \
--resource-group lb-barcodereaderdocker \
--name barcodereaderfiles \
--query connectionString --output tsv) 

storageConnectionString1=$(az storage account show-connection-string \
--resource-group lb-barcodereaderdocker \
--name barcodereaderdocker \
--query connectionString --output tsv) 



docker run -e AzureWebJobsStorage=$storageConnectionString1 -e SugarURL=$SugarURL \
  -e SugarUser=$SugarUser -e SugarPassword=$SugarPassword \
  -e barcodereader_STORAGE=$storageConnectionString $DockerImage


az functionapp config appsettings set --name barcodereaderdocker \
--resource-group lb-barcodereaderdocker \
--settings barcodereader_STORAGE=$storageConnectionString \
 SugarURL=$SugarURL \
 SugarUser=$SugarUser \
 SugarPassword=$SugarPassword \
 DOCKER_CUSTOM_IMAGE_NAME=$DockerImage



az functionapp deployment container config --enable-cd \
--query CI_CD_URL --output tsv \
--name barcodereaderdocker --resource-group lb-barcodereaderdocker