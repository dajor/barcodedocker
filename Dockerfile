FROM mcr.microsoft.com/azure-functions/python:2.0

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY . /home/site/wwwroot
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get -y install libzbar0
RUN cd /home/site/wwwroot && \
    pip install -r requirements.txt
