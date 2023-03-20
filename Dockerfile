FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build

ARG SONAR_TOKEN=token
ARG SONAR_PRJ_KEY=key
ENV SONAR_HOST http://192.168.0.10/
## Install Java, because the sonarscanner needs it.
RUN mkdir /usr/share/man/man1/
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y openjdk-11-jre

## Install sonarscanner
RUN dotnet tool install --global dotnet-sonarscanner --version 5.3.1

## Install report generator
RUN dotnet tool install --global dotnet-reportgenerator-globaltool --version 4.8.12

## Set the dotnet tools folder in the PATH env variable
ENV PATH="${PATH}:/root/.dotnet/tools"

WORKDIR /app

# Copy csproj and restore as distinct layers
#COPY * ./

## Start scanner
RUN dotnet sonarscanner begin \
	
	/k:"$SONAR_PRJ_KEY" \
	/d:sonar.host.url="$SONAR_HOST" \
	/d:sonar.login="$SONAR_TOKEN"

COPY app/SampleWebApp/*.csproj .
#RUN ls
RUN dotnet restore

# Copy everything else and build website
COPY app/SampleWebApp/. .
RUN dotnet publish -c release -o /WebApp --no-restore

RUN dotnet sonarscanner end /d:sonar.login="$SONAR_TOKEN"


# Final stage / image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /WebApp
COPY --from=build /WebApp ./
ENTRYPOINT ["dotnet", "SampleWebApp.dll"]
