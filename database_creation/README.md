# Spider SQL Server Database Creation

This module converts from original Spider (with SQL in SQLite) to Spider-QPL 
- Translate original SQL queries from SQLite to T-SQL with updates of datatypes to standard datatypes, updates of values
- Filling of the databases so that no queries return empty resultsets
- Addition of explicit foreign keys

## Create Docker Container with Spider Data from Scratch

1. Make sure Docker is installed
2. Download a copy of the Spider dataset (can be found [here](https://yale-lily.github.io/spider)) and extract it to `~/spider`.
3. Run `docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Passw0rd!" -p 1433:1433 --name sql1 --hostname sql1 -d mcr.microsoft.com/mssql/server:2019-latest`
4. Run `python create_db.py -s ~/spider` (this should take around 30 minutes)

## Use Pre-populated Docker Image

Run `docker run -p 1433:1433 --name spider-db --hostname spider-db -d beneyal/spider-db-full`

## Inspecting the Spider-QPL Database

To inspect the data in the database, we recommend using SQL Server Management Studio (SSMS).

- Download SSMS from [here](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16)
- Run the above Docker image
- Run SSMS and connect to the following server connection:
    - Server name: `localhost`
    - Authentication: SQL Server Authentication
    - Login: `SA`
    - Password: `Passw0rd!`
