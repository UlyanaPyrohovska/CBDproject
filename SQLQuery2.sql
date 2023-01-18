--location,customer,authentication,sale,stock
use WWIGlobal;
go


--role db login creation
CREATE LOGIN adminLogin WITH PASSWORD = 'admin123';
GO
CREATE LOGIN empLogin WITH PASSWORD = 'employee123';
GO
CREATE LOGIN salesTerrLogin WITH PASSWORD = 'sales123';
GO

-- role creation
go
create role Administrator;
go
create role EmployeeSalesPerson;
go
create role SalesTerritory;
go
-- db user creation
create user admin1 for login adminLogin;
go
create user emplyee1  for login empLogin;
go
create user salesTerritory1  for login salesTerrLogin;
go

--schema creation

create schema sale authorization admin1;
create schema stock authorization admin1;
create schema location authorization admin1;
create schema customer authorization admin1;
create schema auth authorization admin1;

--setting role permissions
-- --admin
grant db_ddladmin to Aministrator;
go
grant db_datareader to Aministrator;
go
grant db_datawriter to Aministrator;
go
grant db_accessadmin to Aministrator;
go
grant db_securityadmin to Aministrator;
go
grant db_backupoperator to Aministrator;
go

-- --emplyee
grant db_datareader to EmployeeSalesPerson;
go
grant insert on schema::sale to EmployeeSalesPerson;
go
grant update on schema::sale to EmployeeSalesPerson;
go
grant delete on schema::sale to EmployeeSalesPerson;
go

-- create view for sales territory role
CREATE VIEW location.view_sales_territory AS 
SELECT st.Name as 'Sale Territory Name', 
	c.Name as 'City',
	s.Name as 'State',
	cnt.Name as 'Continent',
	e.PrefferedName as 'Sales Person',
	sh.InvoiceDateKey as 'Invoice Date',
	sh.DeliveryDateKey as 'Delivery Date',
	sh.Profit as 'Profit'
	from location.SalesTerritory st
inner join location.City c on st.SalesTerritoryID = c.SalesTerritoryID
inner join location.State s on s.StateID = c.CityID
inner join location.Continent cnt on cnt.ContinentID = c.ContinentID
inner join sale.SaleHeader sh on sh.SaleHeaderID = c.CityID
inner join sale.Employee e on e.EmployeeID = sh.SalesPersonID
where st.Name like 'Rocky Mountain';


-- --sales territory
grant select on object::location.view_sales_territory to SalesTerritory;
go
--setting roles to users
exec sp_addrolemember 'EmployeeSalesPerson', 'emplyee1';
go
exec sp_addrolemember 'Administrator', 'admin1';
go
exec sp_addrolemember 'SalesTerritory', 'salesTerritory1';