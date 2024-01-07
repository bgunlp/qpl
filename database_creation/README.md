# Spider SQL Server Database Creation

## Create Docker Container with Spider Data from Scratch

1. Make sure Docker is installed
2. Run `docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Passw0rd!" -p 1433:1433 --name sql1 --hostname sql1 -d mcr.microsoft.com/mssql/server:2019-latest`
3. Run `python create_db.py -s <path-to-spider>` (this should take around 30 minutes)

## Use Pre-populated Docker Image

Run `docker run -p 1433:1433 --name spider-db --hostname spider-db -d beneyal/spider-db-full`
