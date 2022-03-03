

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build

RUN apt-get update -y
RUN apt-get install default-jdk -y



# Copy csproj and restore as distinct layers
COPY SampleWebApp/*.csproj .
ENV SONAR_SCANNER_OPTS="-Xmx512m"
RUN dotnet tool install --global dotnet-sonarscanner
ENV PATH="${PATH}:/root/.dotnet/tools"
RUN dotnet sonarscanner begin /k:"dotnetsonar" /d:sonar.host.url=http://3.14.82.98:9000 /d:sonar.login=d6bf03d1f9ce082be45a82504474affdc13bce13

#RUN dotnet restore

#RUN dotnet sonarscanner end /d:sonar.login=d6bf03d1f9ce082be45a82504474affdc13bce13
# Copy everything else and build website
COPY SampleWebApp/. .

COPY . .
#RUN dotnet publish -c release -o /WebApp --no-restore

RUN dotnet sonarscanner end /d:sonar.login=d6bf03d1f9ce082be45a82504474affdc13bce13
# Final stage / image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /WebApp
COPY --from=build /WebApp ./
ENTRYPOINT ["dotnet", "SampleWebApp.dll"]
