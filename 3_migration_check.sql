--Checking minimum requirements:

--¹ of Customers for WWI_DS
select count([Customer Key]) as '¹ of Customers'
from WWI_DS.dbo.Customer

--¹ of Customers for WWIGlobal
select count(CustomerID) as '¹ of Customers'
from WWIGlobal.dbo.Customer

--¹ of Customers per Category for WWI_DS
select category, count([Customer Key]) as '¹ of Customers'
from WWI_DS.dbo.Customer
group by Category

--¹ of Customers per Category for WWIGlobal
select c.Name, count(CustomerID) as '¹ of Customers'
from WWIGlobal.dbo.Customer
join WWIGlobal.dbo.CustomerCategory c on c.CustomerCategoryID = CategotyID
group by c.Name

--Total sales per employee for WWI_DS
select oldE.Employee, count(*) as 'Total number of sales' from WWI_DS.dbo.Sale s
join WWI_DS.dbo.Employee oldE on oldE.[Employee Key] = s.[Salesperson Key]
group by oldE.Employee

--Total sales per employee for WWIGlobal
select ut.PrimaryContact, count(s.SaleDetailsID) as 'Total number of sales'
from WWIGlobal.dbo.SaleDetails s
join WWIGlobal.dbo.SaleHeader sh on sh.SaleHeaderID = s.SaleHeaderID
join WWIGlobal.dbo.Employee e on e.EmployeeID = sh.SalesPersonID
join WWIGlobal.dbo.UserTable ut on ut.UserID =  e.EmployeeID
group by ut.PrimaryContact

--Total monetary sales per “Stock Item” for WWI_DS
select sd.[Stock Item Key], p.[Stock Item] ,sum(p.[Unit Price] * sd.Quantity) as 'Monetary Sales'
from WWI_DS.dbo.Sale sd
join WWI_DS.dbo.[Stock Item] p on p.[Stock Item Key] = sd.[Stock Item Key]
--where p.[Stock Item] = 'White chocolate snow balls 250g'
group by sd.[Stock Item Key], p.[Stock Item]
order by p.[Stock Item]

--Total monetary sales per “Stock Item” for WWIGlobal
select sd.StockItemID, p.Name, sum(p.UnitPrice * sd.Quantity) as 'Monetary Sales'
from WWIGlobal.dbo.SaleDetails sd
join WWIGlobal.dbo.StockItem p on p.StockItemID = sd.StockItemID
--where p.Name = 'White chocolate snow balls 250g'
group by sd.StockItemID, p.Name
order by p.Name

--Total monetary sales per year by “Stock Item” for WWI_DS
select year(sd.[Delivery Date Key]) as Year, sd.[Stock Item Key], p.[Stock Item] ,sum(p.[Unit Price] * sd.Quantity) as 'Monetary Sales'
from WWI_DS.dbo.Sale sd
join WWI_DS.dbo.[Stock Item] p on p.[Stock Item Key] = sd.[Stock Item Key]
where sd.[Delivery Date Key] is not null
--where p.[Stock Item] = 'White chocolate snow balls 250g'
group by year(sd.[Delivery Date Key]), sd.[Stock Item Key], p.[Stock Item]
order by p.[Stock Item], year(sd.[Delivery Date Key])

--Total monetary sales per year by “Stock Item” for WWIGlobal
select year(sh.DeliveryDateKey) as Year,sd.StockItemID, p.Name, sum(p.UnitPrice * sd.Quantity) as 'Monetary Sales'
from WWIGlobal.dbo.SaleDetails sd
join WWIGlobal.dbo.SaleHeader sh on sh.SaleHeaderID = sd.SaleHeaderID
join WWIGlobal.dbo.StockItem p on p.StockItemID = sd.StockItemID
where sh.DeliveryDateKey is not null
--where p.Name = 'White chocolate snow balls 250g'
group by sd.StockItemID, p.Name, year(sh.DeliveryDateKey)
order by p.Name, year(sh.DeliveryDateKey)

--Total monetary sales per year by “City” for WWI_DS
select year(sd.[Delivery Date Key]) as Year, c.City, c.[State Province] ,sum(p.[Unit Price] * sd.Quantity) as 'Monetary Sales'
from WWI_DS.dbo.Sale sd
join WWI_DS.dbo.[Stock Item] p on p.[Stock Item Key] = sd.[Stock Item Key]
join WWI_DS.dbo.City c on c.[City Key]=sd.[City Key]
where sd.[Delivery Date Key] is not null
--where p.[Stock Item] = 'White chocolate snow balls 250g'
group by year(sd.[Delivery Date Key]), c.City, c.[State Province]
order by year(sd.[Delivery Date Key]), c.City

--Total monetary sales per year by “City” for WWIGlobal
select year(sh.DeliveryDateKey) as Year, c.Name, sum(p.UnitPrice * sd.Quantity) as 'Monetary Sales'
from WWIGlobal.dbo.SaleDetails sd
join WWIGlobal.dbo.SaleHeader sh on sh.SaleHeaderID = sd.SaleHeaderID
join WWIGlobal.dbo.StockItem p on p.StockItemID = sd.StockItemID
join WWIGlobal.dbo.City c on c.CityID = sh.CityID
--where p.Name = 'White chocolate snow balls 250g'
where sh.DeliveryDateKey is not null
group by year(sh.DeliveryDateKey), c.Name
order by year(sh.DeliveryDateKey), c.Name