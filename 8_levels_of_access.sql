--location,customer,authentication,sale,stock


drop login  adminLogin
drop login  empLogin
drop login salesTerrLogin


--role db login creation
CREATE LOGIN adminLogin WITH PASSWORD = 'admin123';
GO
CREATE LOGIN empLogin WITH PASSWORD = 'employee123';
GO
CREATE LOGIN normalUser WITH PASSWORD = 'user123';
GO


-- role creation

create role Administrator;
go
create role EmployeeSalesPerson;
go
create role Customer;
go
create role SaleUser;
go
create role SalesTerritory;
go



-- db user creation
create user admin1 for login adminLogin;
go
create user emplyee1  for login empLogin;
go
create user normaluser1  for login normalUser;
go

revert

EXEC sp_who

use WWIGlobal;
go

EXECUTE AS USER='AdminLogin';
go
--schema creation
/*
create schema sale authorization admin1;
go
create schema stock authorization admin1;
go
create schema location authorization admin1;
go

create schema customer authorization admin1;
go

create schema auth authorization admin1;
go
*/

--setting role permissions
-- --admin
/*
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
*/

grant control on schema::auth to Administrator
go
grant insert on schema::auth to Administrator
go
grant update on schema::auth to Administrator
go
grant select on schema::auth to Administrator
go
grant delete on schema::auth to Administrator
go
grant references on schema::auth to Administrator
go
grant execute on schema::auth to Administrator
go

grant control on schema::salesMgt to Administrator
go
grant insert on schema::salesMgt to Administrator
go
grant update on schema::salesMgt to Administrator
go
grant select on schema::salesMgt to Administrator
go
grant delete on schema::salesMgt to Administrator
go
grant references on schema::salesMgt to Administrator
go
grant execute on schema::salesMgt to Administrator
go

grant control on schema::readData to Administrator
go
grant insert on schema::readData to Administrator
go
grant update on schema::readData to Administrator
go
grant select on schema::readData to Administrator
go
grant delete on schema::readData to Administrator
go
grant references on schema::readData to Administrator
go
grant execute on schema::readData to Administrator
go

grant control on schema::customer to Administrator
go
grant insert on schema::customer to Administrator
go
grant update on schema::customer to Administrator
go
grant select on schema::customer to Administrator
go
grant delete on schema::customer to Administrator
go
grant references on schema::customer to Administrator
go
grant execute on schema::customer to Administrator
go

grant control on schema::stock to Administrator
go
grant insert on schema::stock to Administrator
go
grant update on schema::stock to Administrator
go
grant select on schema::stock to Administrator
go
grant delete on schema::stock to Administrator
go
grant references on schema::stock to Administrator
go
grant execute on schema::stock to Administrator
go

-- --emplyee
grant insert on schema::salesMgt to EmployeeSalesPerson;
go
grant update on schema::salesMgt to EmployeeSalesPerson;
go
grant delete on schema::salesMgt to EmployeeSalesPerson;
go
grant execute on schema::salesMgt to EmployeeSalesPerson
go
grant select on schema::stock to EmployeeSalesPerson
go
grant select on schema::auth to EmployeeSalesPerson
go
grant select on schema::readData to EmployeeSalesPerson
go
grant select on schema::stock to EmployeeSalesPerson
go
grant select on schema::customer to EmployeeSalesPerson
go
-- -- customer
grant insert on schema::customer to Customer;
go
grant update on schema::customer to Customer;
go
grant select on schema::customer to Customer;
go
grant execute on schema::customer to Customer;
go
grant execute on schema::auth to Customer;
go
grant select on schema::auth to Customer;
go
grant select on schema::stock to Customer;
go
grant select on schema::salesMgt to Customer;
go
----SalesTerritory
grant select on schema::readData to SalesTerritory
go
grant select on schema::salesMgt to SalesTerritory
go


exec sp_addrolemember N'Administrator', 'admin1'

exec sp_addrolemember N'Employee'

revert

use WWIGlobal
GO

execute as user='admin1'
go

-- create view for sales territory role
CREATE VIEW salesMgt.view_sales_territory AS 
SELECT st.Name as 'Sale Territory Name', 
	c.Name as 'City',
	s.Name as 'State',
	cnt.Name as 'Continent',
	e.EmployeeID as 'Sales Person',
	sh.InvoiceDateKey as 'Invoice Date',
	sh.DeliveryDateKey as 'Delivery Date',
	sh.Profit as 'Profit'
	from readData.SalesTerritory st
inner join readData.City c on st.SalesTerritoryID = c.SalesTerritoryID
inner join readData.State s on s.StateID = c.CityID
inner join readData.Continent cnt on cnt.ContinentID = c.ContinentID
inner join salesMgt.SaleHeader sh on sh.SaleHeaderID = c.CityID
inner join salesMgt.Employee e on e.EmployeeID = sh.SalesPersonID
where st.Name like 'Rocky Mountain';
go


-- --sales territory
grant select on object::location.view_sales_territory to SalesTerritory;
go
--setting roles to users
exec sp_addrolemember 'EmployeeSalesPerson', 'emplyee1';
go
exec sp_addrolemember 'Administrator', 'admin1';
go
exec sp_addrolemember 'SalesTerritory', 'salesTerritory1';