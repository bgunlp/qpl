CREATE PROCEDURE SalesLT.uspGetCustomerCompany1
    @LastName nvarchar(50),
    @FirstName nvarchar(50)
AS   

    SET NOCOUNT ON;
    SELECT FirstName, LastName, CompanyName
    FROM SalesLT.Customer
    WHERE FirstName = @FirstName AND LastName = @LastName;
GO

datetime