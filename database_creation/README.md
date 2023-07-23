# Spider SQL Server Database Creation

## Create Docker Container with Spider Data from Scratch

1. Make sure Docker is installed
2. Get the Spider dataset and extract it to this directory, i.e., next to this `README.md` file should be a directory called `spider`
3. Run `docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Passw0rd!" -p 1433:1433 --name sql1 --hostname sql1 -d mcr.microsoft.com/mssql/server:2019-latest`
4. Run `python create_db.py` (this should take around 30 minutes)

## Use Pre-populated Docker Image

Run `docker run -p 1433:1433 --name spider-db --hostname spider-db -d beneyal/spider-db-full`
