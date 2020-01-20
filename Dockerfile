# escape=`

# NOTE: use 'process' isolation to build image (otherwise rhino fails to install)

### builder image
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8 as builder

# copy everything, restore packages and build app
COPY src/ ./src/
RUN msbuild ./src/compute.sln /t:build /restore /p:Configuration=Release

### main image
FROM mcr.microsoft.com/windows:1903
SHELL ["powershell", "-Command"]

# install rhino (with “-package -quiet” args)
# NOTE: edit this if you use a different version of rhino!
ADD http://files.mcneel.com/dujour/exe/20200114/rhino_en-us_7.0.20014.11185.exe rhino_installer.exe
RUN Start-Process .\rhino_installer.exe -ArgumentList '-package', '-quiet' -NoNewWindow -Wait
RUN Remove-Item .\rhino_installer.exe

COPY --from=builder ["/src/bin/Release", "/app"]

WORKDIR /app

EXPOSE 80

CMD ["compute.frontend.exe"]
