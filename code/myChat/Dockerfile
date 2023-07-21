# Basic Dockerfile
# 
# docker build -f ./code/myChat/Dockerfile -t mychat:v0.1 ./code/myChat --build-arg tag=v0.1

FROM mcr.microsoft.com/dotnet/sdk:7.0 as build
WORKDIR /src
COPY myChat.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:7.0 as publish
WORKDIR /app
ENV EnvName=Docker
ENV ApiUrl=http://myapi/weatherforecast
COPY --from=build /app .
ENTRYPOINT ["dotnet","myChat.dll"]