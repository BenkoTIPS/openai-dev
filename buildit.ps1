# ChatGPT

git remote add origin https://github.com/BenkoTIPS/openai-dev.git
git branch -M main
git push -u origin main

dotnet new razor -o myChat

dotnet add code/myChat package Azure.AI.OpenAI --version 1.0.0-beta.5

## Move the Chat app to a code folder
## Core to Containers to Orchestration

dotnet new webapi -o code\myApi  
dotnet new sln
dotnet sln add code\myChat code\myApi 

tye init
tye run
tye push -i
tye deploy -i


## Containerize
### Basic Dockerfile
cd .\code\myChat
dotnet build --configuration release
dotnet publish -c release -o dist
cd .\dist
dotnet myChat.dll


# add docker file to ./myChat folder

cd .\code\myChat\ # so we're in .\myChat
$imgName = "mychat:simple"
docker build -t $imgName -f ./Dockerfile ./
docker image list $imgName
docker run -p 5001:80 -d $imgName
# http://localhost:5001
docker container list
docker container stop 6eee
docker container rm 6eee

## add Dockerfile to Chat and API
cd ..\..

docker build -f ./code/myApi/Dockerfile -t cco23_api:v0.1 ./code/myApi --build-arg tag=v0.1
docker build -f ./code/myChat/Dockerfile -t cco23_web:v0.1 ./code/myChat --build-arg tag=v0.1

docker image list cco23*

## add docker-compose.yml and test
docker compose build
docker compose up
docker compose down


# push to acr bnkacr23
az acr login -n bnkacr23
az acr build --image bnkacr23.azurecr.io/cco23_web:v1 --registry bnkacr23 -f ./code/myChat/Dockerfile ./code/myChat --build-arg tag=v1
az acr build --image bnkacr23.azurecr.io/cco23_api:v1 --registry bnkacr23 -f ./code/myApi/Dockerfile ./code/myApi --build-arg tag=v1


## Test in ACA
$env = "cco23-demo"
$rg = "cco23-demos-rg"
az containerapp up -n cco23-web-aca -g $rg --environment $env --image bnkacr23.azurecr.io/cco23_web:v1 --ingress external
az containerapp up -n cco23-api-aca -g $rg --environment $env --image bnkacr23.azurecr.io/cco23_api:v1 --ingress internal
az containerapp list -o table
az containerapp update -n cco23-web-aca -g $rg --set-env-vars "EnvName=ACA" 
az containerapp update -n cco23-web-aca -g $rg --set-env-vars "ApiUrl=http://cco23-api-aca/weatherforecast" 

## Test in AKS

$acrName = "bnkacr23"
$aksName = "bnk-shared-cus-aks"
$aksRg = "rg-shared-cus"

az group create -n $aksrg --location northcentralus
az acr create -n $acrName -g $rg --sku Standard

az acr login -n $acrName

# Create a test AKS cluster with ACR integration
# az aks create -n $aksName -g $aksrg --generate-ssh-keys --attach-acr $acrName --node-vm-size "standard_d2as_v5"
az aks get-credentials --resource-group $aksrg --name $aksName
# attach acr to aks
az aks update -n $aksName -g $aksrg --attach-acr $acrName

$ns = "cco23-demos"
kubectl create namespace $ns
kubectl apply -n $ns -f k8s.yml


