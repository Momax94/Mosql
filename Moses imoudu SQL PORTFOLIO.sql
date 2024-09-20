-- 1) Using AdeventureWorks left join to retrive frist name, last name and email address
SELECT p.FirstName, p.LastName, ea.EmailAddress
FROM Person.Person p
LEFT JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID;

-- 2) Get the list of all the job title in the business
SELECT e1.BusinessEntityID, e1.JobTitle
FROM HumanResources.Employee e1
LEFT JOIN HumanResources.Employee e2 ON e1.BusinessEntityID = e2.BusinessEntityID;

-- 3) To Find the sales Orders by Customers in a Specific Territory using Join
SELECT soh.SalesOrderID, c.CustomerID
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
WHERE st.Name = 'Northwest';

-- 4) Query: Find products that have never been sold
SELECT p.ProductID, p.Name
FROM Production.Product p
WHERE p.ProductID NOT IN (
    SELECT ProductID
    FROM Sales.SalesOrderDetail
);

-- 5) using count to subquery phonecount
SELECT p.FirstName, p.LastName,
    (SELECT COUNT(*) FROM Person.PersonPhone pp WHERE pp.BusinessEntityID = p.BusinessEntityID) AS PhoneCount
FROM Person.Person p;

-- 6) using join with a subquery to get employees specific average salary of the employees
SELECT e.BusinessEntityID, e.JobTitle, SalaryDetails.AvgSalary
FROM HumanResources.Employee e
JOIN (
    SELECT BusinessEntityID, AVG(Rate) AS AvgSalary
    FROM HumanResources.EmployeePayHistory
    GROUP BY BusinessEntityID
) SalaryDetails ON e.BusinessEntityID = SalaryDetails.BusinessEntityID;
    
-- 7) using join to get employee hiredate range
SELECT p.FirstName, p.LastName, e.HireDate
FROM Person.Person p
JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID;

-- 8) subquery in Having
SELECT p.FirstName, p.LastName, COUNT(e.BusinessEntityID) AS EmployeeCount
FROM Person.Person p
JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(e.BusinessEntityID) > (SELECT AVG(COUNT(*)) FROM HumanResources.Employee);

--9) Find employees who have a higher salary than the average salary of the company
SELECT e.BusinessEntityID, p.FirstName, p.LastName, ep.Rate
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN HumanResources.EmployeePayHistory ep ON e.BusinessEntityID = ep.BusinessEntityID
WHERE ep.Rate > (
    SELECT AVG(Rate)
    FROM HumanResources.EmployeePayHistory
);

-- 10) to find customers who have placed more than 10 orders
SELECT c.CustomerID, COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
HAVING COUNT(soh.SalesOrderID) > 10;

-- 11) using CTE to rank Employees by Hire Date
WITH RankedEmployees AS (
    SELECT e.BusinessEntityID, e.HireDate, 
           RANK() OVER (ORDER BY e.HireDate) AS RankOrder
    FROM HumanResources.Employee e
)
SELECT * FROM RankedEmployees;

-- 12) List the gender of all the employees showing their first nameand last name
SELECT p.FirstName, p.LastName, 
    CASE 
        WHEN e.Gender = 'M' THEN 'Male' 
        WHEN e.Gender = 'F' THEN 'Female' 
        ELSE 'Other' 
    END AS Gender
FROM Person.Person p
JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID;

--13) All Orders Placed by Salespersons in all Specific Region
SELECT soh.SalesOrderID, st.Name AS TerritoryName, s.BusinessEntityID
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson s ON soh.SalesPersonID = s.BusinessEntityID
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID;

-- 14) Find the total sales amount for each product category
WITH ProductSales AS (
    SELECT sod.ProductID, SUM(sod.LineTotal) AS TotalSales
    FROM Sales.SalesOrderDetail sod
    GROUP BY sod.ProductID
)
SELECT p.Name, ps.TotalSales
FROM ProductSales ps
JOIN Production.Product p ON ps.ProductID = p.ProductID;

--15) Find customers who haven't placed any orders
SELECT c.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID;
WHERE c.CustomerID NOT IN (
    SELECT CustomerID
    FROM Sales.SalesOrderHeader
);