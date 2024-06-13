SELECT * FROM sys.tables;

1.

SELECT * FROM Production.Product;

SELECT ProductID, Color, ListPrice, (StandardCost) Price FROM Production.Product
WHERE Color NOT IN ('Red','Silver','White','Black') 
AND Color IS NOT NULL 
AND ListPrice BETWEEN 75 AND 750

Order by ListPrice DESC;


2.

SELECT * FROM HumanResources.Employee;

SELECT BusinessEntityID, Gender, YEAR(HireDate) AS HireDate, YEAR(BirthDate) AS DOB FROM HumanResources.Employee

WHERE ((Gender='M') AND (YEAR(BirthDate) BETWEEN 1962 AND 1970)
AND (YEAR(HireDate)> 2001))
OR ((Gender ='F')
AND (YEAR(BirthDate) BETWEEN 1972 AND 1975)
AND (YEAR(HireDate) BETWEEN 2001 AND 2002));


3.

SELECT TOP 10 ProductID, Name, Color FROM Production.Product

WHERE ProductNumber LIKE 'BK%'
ORDER BY ListPrice DESC;

4.
---LIST OF CONTACT PERSON WITH SIMILAR CHARACTERS OF THE LAST NAME AND EMAIL ADDRESS

SELECT PP.BusinessEntityID, PP.FirstName, PP.LastName, PE.EmailAddress 
from Person.Person AS PP

INNER JOIN Person.EmailAddress as PE
ON PP.BusinessEntityID=PE.BusinessEntityID

WHERE SUBSTRING(PP.FirstName, 1, 4) = SUBSTRING(PE.EmailAddress,1,4)
AND SUBSTRING(PP.FirstName, 1, 1) = SUBSTRING(PP.LastName, 1, 1);

----FULL NAME COLUMN AND LENGTH
SELECT FirstName, LastName, CONCAT(FirstName,' ',LastName)as FullName, LEN(CONCAT(FirstName,' ',LastName)) as len_full_name 
FROM Person.Person

WHERE SUBSTRING(FirstName, 1, 4) = SUBSTRING(LastName,1,4)
AND SUBSTRING(FirstName, 1, 1) = SUBSTRING(LastName, 1, 1);


5.
----PRODUCT SUB-CATEGORIES WITH >=3DAYS MANUFACTURING DATE

SELECT PPS.ProductSubcategoryID, PPS.Name, PP.DaysToManufacture from Production.ProductSubcategory as PPS
LEFT JOIN Production.Product as PP

ON PPS.ProductSubcategoryID=PP.ProductSubcategoryID
where PP.DaysToManufacture >=3
order by PP.DaysToManufacture ASC

6.
----Product Segmentation by Defining Criteria
SELECT ProductID, Name, ListPrice, Color,
CASE
WHEN ListPrice<200
THEN 'LOW VALUE'
WHEN ListPrice BETWEEN 201 AND 750
THEN 'MID VALUE'
WHEN ListPrice BETWEEN 750 AND 1250
THEN 'HIGH VALUE'
ELSE 'HIGHER VALUE'
END AS Product_segmentation
FROM Production.Product
WHERE COLOR IN ('RED', 'BLACK', 'SILVER');


7.
----COUNT OF DISTINCT JOB TITLES
SELECT COUNT (DISTINCT JobTitle) FROM HumanResources.Employee;

8.
----CALCULATE AGES OF EMPLOYEE AT THE TIME OF HIRING

SELECT BusinessEntityID,NationalIDNumber, BirthDate, HireDate, 
DATEDIFF(YEAR,BirthDate, HireDate) Age
FROM HumanResources.Employee;

9.
----EMPLOYEES DUE LONG SERVICE AWARD IN THE NEXT 5 YEARS

SELECT
COUNT (*) AS employees_due_for_award
FROM HumanResources.Employee
WHERE DATEDIFF(YEAR,GETDATE(),HireDate)>=20
AND DATEDIFF(YEAR,GETDATE(),HireDate)<25

10.
----NUMBER OF YEARS TO REACH RETIREMENT AGE IF THE RETIREMENT AGE IS 65

SELECT BusinessEntityID,BirthDate, DATEDIFF(YEAR,BirthDate, GETDATE()) AS AGE,
CASE WHEN DATEDIFF(YEAR,BirthDate,GETDATE())<=65
THEN 65-DATEDIFF(YEAR,BirthDate, GETDATE())
END AS years_till_retirement
FROM HumanResources.Employee


11.
----
ALTER TABLE Production.Product
ADD NewPrice DECIMAL(10,2)

UPDATE Production.Product
SET NewPrice=
CASE
WHEN Color = 'White' THEN ListPrice*1.08
WHEN Color = 'Yellow' THEN ListPrice*0.95 ----(100%-7.5%)
WHEN Color = 'Black' THEN ListPrice*1.172 ----(100%+17.2%)
WHEN Color IN ('Multi', 'Silver', 'Silver/Black', 'Blue') THEN SQRT(ListPrice)*2
ELSE ListPrice
END

ALTER TABLE Production.Product
ADD Commission DECIMAL(10,2)

UPDATE Production.Product
SET Commission= NewPrice*0.375

SELECT * FROM Production.Product

12.

SELECT PP.FirstName, PP.LastName, HE.HireDate, HE.SickLeaveHours, SSP.SalesQuota,
CASE
WHEN HE.JobTitle IN('North America Sales Manager', 'Sales Representative', 'Pacific Sales Manager', 'European Sales Manager')
THEN SST.Name
END AS Region
from Person.Person PP 
JOIN HumanResources.Employee AS HE ON PP.BusinessEntityID= HE.BusinessEntityID
JOIN Sales.SalesPerson as SSP ON SSP.BusinessEntityID= PP.BusinessEntityID
JOIN Sales.SalesTerritory as SST  ON SST.TerritoryID = SSP.TerritoryID



13.
----
SELECT pp.Name as ProductName, ppc.Name AS Product_category_name, pps.Name as Product_subcategory_name, 
pe.FirstName+' '+pe.LastName as Sales_Person, ssd.LineTotal as REVENUE, 
MONTH(pth.TransactionDate) as Month_of_Transaction, DATEPART(QUARTER, pth.TransactionDate) as Quarter_of_Transaction, sst.Name as Region
FROM Sales.SalesOrderDetail ssd
join Production.Product pp on ssd.ProductID= pp.ProductID
Join Production.ProductSubcategory pps ON pp.ProductSubCategoryID= pps.ProductSubCategoryID
Join Production.ProductCategory ppc ON pps.ProductCategoryID= ppc.ProductCategoryID
Join Sales.SalesOrderHeader soh ON ssd.SalesOrderID= soh.SalesOrderID
Join Sales.SalesPerson ssp ON soh.SalesPersonID= ssp.BusinessEntityID
Join Person.Person pe ON ssp.BusinessEntityID= pe.BusinessEntityID
Join Production.TransactionHistory pth ON pth.ProductID= pp.ProductID
Join Sales.SalesTerritory sst ON soh.TerritoryID= sst.TerritoryID

14.
----
SELECT SSH.SalesOrderNumber, SSH.OrderDate, SUM(SSD.LineTotal) AS OrderAmount, SSH.CustomerID, 
PP.BusinessEntityID AS SalesPersonID, PP.FirstName+' '+ PP.LastName as SalesPersonName, 
SSP.CommissionPct*SUM(SSD.LineTotal) AS Commission
FROM Sales.SalesOrderHeader SSH
JOIN Sales.SalesOrderDetail as SSD ON SSH.SalesOrderID= SSD.SalesOrderID
JOIN Sales.SalesPerson as SSP ON SSH.TerritoryID = SSP.TerritoryID
JOIN Person.Person as PP ON PP.BusinessEntityID = SSP.BusinessEntityID
GROUP BY
SSH.SalesOrderNumber, SSH.OrderDate, SSH.CustomerID, PP.BusinessEntityID, SSP.CommissionPct, PP.FirstName+' '+ PP.LastName;


15.
----
CREATE VIEW ProductCommissionMargin AS
SELECT ProductID, Name as ProductName, Color, StandardCost, StandardCost*0.1479 as Commission,
CASE
WHEN Color= 'Black' THEN StandardCost*1.22
WHEN Color= 'Red' THEN StandardCost*0.88
WHEN Color= 'Silver' THEN StandardCost*1.15
WHEN Color= 'Multi' THEN StandardCost*1.05
WHEN Color= 'White' THEN (2*StandardCost)/ SQRT(StandardCost)
ELSE StandardCost
END AS AdjustedCost,

CASE
WHEN Color= 'Black' THEN 0.22
WHEN Color= 'Red' THEN -0.12
WHEN Color= 'Silver' THEN 0.15
WHEN Color= 'Multi' THEN 0.05
WHEN Color= 'White' THEN (2*StandardCost)/ SQRT(StandardCost) - 1
ELSE 0
END AS Margin
FROM Production.Product

16.
----
CREATE VIEW Top5MostExpensiveProducts AS
SELECT ProductID, Name AS ProductName, Color, StandardCost, ListPrice,
ROW_NUMBER() OVER(PARTITION BY Color ORDER BY ListPrice DESC) AS RANK
FROM Production.Product

SELECT ProductID, ProductName, Color, StandardCost, ListPrice
FROM Top5MostExpensiveProducts
WHERE RANK <=5