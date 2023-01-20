use WWIGlobal
go

--inserting data into states table
insert into WWIGlobal.readData.State
select [Code], [Name] 
from WWI_DS.dbo.state

--inserting data into Country table
insert into WWIGlobal.readData.Country
select distinct Country
from WWI_DS.dbo.City

--inserting data into SalesTerritory table
insert into WWIGlobal.readData.SalesTerritory
select distinct [Sales Territory]
from WWI_DS.dbo.City

--inserting data into Continent table
insert into WWIGlobal.readData.Continent
select distinct Continent
from WWI_DS.dbo.City

--changing the Virgin Islands registry
update WWIGlobal.readData.State
set Name = 'Virgin Islands'
where Name = 'Virgin Islands, U.S.'

--inserting city name, stateId and last recorded population into city table
insert into WWIGlobal.readData.City
select distinct s.StateID, contr.CountryID, cont.ContinentID, st.SalesTerritoryID, c.City, c.[Latest Recorded Population]
from WWI_DS.dbo.City c
join WWIGlobal.readData.State s on c.[State Province] collate LATIN1_GENERAL_CI_AS like s.Name + '%'
join WWIGlobal.readData.Continent cont on c.Continent collate LATIN1_GENERAL_CI_AS = cont.Name
join WWIGlobal.readData.Country contr on c.Country collate LATIN1_GENERAL_CI_AS = contr.Name
join WWIGlobal.readData.SalesTerritory st on c.[Sales Territory] collate LATIN1_GENERAL_CI_AS = st.Name

--inserting into Location table
insert into WWIGlobal.readData.Location
select c.CityID, cust.[Postal Code]
from WWI_DS.dbo.Customer cust
join WWIGlobal.readData.State s on cust.Customer collate LATIN1_GENERAL_CI_AS like  '%' + s.Code + ')'
join WWIGlobal.readData.City c on cust.Customer collate LATIN1_GENERAL_CI_AS like  '%(' + c.Name + ', %' and s.StateID = c.StateID  
order by cust.[Postal Code]

--inserting unknown city state country continent sales territory
insert into WWIGlobal.readData.State(Name, Code) values ('Unknown', 'UNKN');

insert into WWIGlobal.readData.Country (Name) values ('Unknown');

insert into WWIGlobal.readData.SalesTerritory(Name) values ('Unknown');

insert into WWIGlobal.readData.Continent(Name) values ('Unknown');

insert into WWIGlobal.readData.City
select s.StateID, con.CountryID, c.ContinentID, st.SalesTerritoryID, 'Unknown', 0
from WWIGlobal.readData.Continent c
join readData.SalesTerritory st on st.Name='Unknown'
join readData.Country con on con.Name='Unknown'
join readData.State s on s.Name='Unknown'
where c.Name = 'Unknown'

--inserting unknown city to head office entries
insert into WWIGlobal.readData.Location
select c.CityID, cust.[Postal Code]
from WWIGlobal.readData.City c
join WWI_DS.dbo.Customer cust on cust.Customer collate LATIN1_GENERAL_CI_AS like '%(Head Office)'
where c.Name = 'Unknown'

--inserting into buying group table
insert into Customer.BuyingGroup(name, BillToCustomer)
select distinct old.[Buying Group], old.[Bill To Customer]
from WWI_DS.dbo.Customer old

--inserting into customer category table
insert into WWIGlobal.customer.CustomerCategory(Name)
select distinct old.Category
from WWI_DS.dbo.Customer old

select * from auth.UserTable

insert into WWIGlobal.auth.UserTable(PrimaryContact)
select c.[Primary Contact]
from WWI_DS.dbo.Customer c

--inserting into customer table
insert into WWIGlobal.customer.Customer(CustomerID, CategotyID, BuyingGroupID, LocationID)
select ut.UserID, ct.CustomerCategoryID, bg.BuyingGroupID, l.LocationID
from WWI_DS.dbo.Customer c
join WWIGlobal.auth.UserTable ut on c.[Primary Contact] collate LATIN1_GENERAL_CI_AS = ut.PrimaryContact
join WWIGlobal.customer.CustomerCategory ct on ct.Name collate LATIN1_GENERAL_CI_AS = c.Category
join WWIGlobal.customer.BuyingGroup bg on bg.Name collate LATIN1_GENERAL_CI_AS = c.[Buying Group]
join WWIGlobal.readData.State state on c.Customer collate LATIN1_GENERAL_CI_AS like  '%' + state.Code + ')'
join WWIGlobal.readData.City city on c.Customer collate LATIN1_GENERAL_CI_AS like  '%(' + city.Name + ', %' and state.StateID = city.StateID
join WWIGlobal.readData.Location l on l.PostalCode collate LATIN1_GENERAL_CI_AS = c.[Postal Code] and l.CityID = city.CityID

--inserting customers with unknown cities
insert into WWIGlobal.customer.Customer(CustomerID, CategotyID, BuyingGroupID, LocationID)
select  ut.UserID, ct.CustomerCategoryID, bg.BuyingGroupID, l.LocationID
from WWI_DS.dbo.Customer c
join WWIGlobal.auth.UserTable ut on c.[Primary Contact] collate LATIN1_GENERAL_CI_AS = ut.PrimaryContact
join WWIGlobal.customer.CustomerCategory ct on ct.Name collate LATIN1_GENERAL_CI_AS = c.Category
join WWIGlobal.customer.BuyingGroup bg on bg.Name collate LATIN1_GENERAL_CI_AS = c.[Buying Group]
join WWIGlobal.readData.Location l on l.PostalCode collate LATIN1_GENERAL_CI_AS = c.[Postal Code]
join WWIGlobal.readData.City ci on l.CityID = ci.CityID and ci.Name = 'Unknown'

--inserting into package table
insert into readData.Package(Name)
select  old.Package
from WWI_DS.dbo.Package$ old

--inserting into color table
insert into readData.Color(Name)
select distinct old.Color	
from WWI_DS.dbo.Color$ old

insert into readData.Size(Name)
select distinct old.Size
from WWI_DS.dbo.[Stock Item] old

--inserting into TaxtRate table
insert into readData.TaxRate(TaxRate)
select distinct old.[Tax Rate]
from WWI_DS.dbo.[Stock Item] old

insert into readData.TaxRate(TaxRate)
select distinct old.[Tax Rate]
from WWI_DS.dbo.Sale old
where old.[Tax Rate] not in (select TaxRate from readData.TaxRate)

insert into WWIGlobal.auth.UserTable(PrimaryContact)
select distinct c.Employee
from WWI_DS.dbo.Employee c

--inserting into employee table
insert into salesMgt.Employee(EmployeeID,Photo)
select	distinct ut.UserID, old.Photo
from WWI_DS.dbo.Employee old 
join WWIGlobal.auth.UserTable ut on ut.PrimaryContact = old.Employee collate LATIN1_GENERAL_CI_AS

--inserting into stockitem table
insert into stock.StockItem(Name, ColorID, Brand, SellingPackageID, BuyingPackageID, LeadTimeDays, QuantityPerOuter, 
IsChillerStock, Barcode, TaxRateID, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, SizeID)
select distinct oldItem.[Stock Item], col.ColorID, oldItem.Brand, sellpac.PackageID, buypac.PackageID, oldItem.[Lead Time Days], 
oldItem.[Quantity Per Outer], oldItem.[Is Chiller Stock], oldItem.Barcode, tr.TaxRateID, oldItem.[Unit Price], oldItem.[Recommended Retail Price], oldItem.[Typical Weight Per Unit],  siz.SizeID
from WWI_DS.dbo.[Stock Item] oldItem 
join readData.TaxRate tr on tr.TaxRate = oldItem.[Tax Rate]
join readData.Color col on col.Name = oldItem.Color  collate LATIN1_GENERAL_CI_AS
join readData.Package buypac on buypac.Name = oldItem.[Buying Package] collate LATIN1_GENERAL_CI_AS
join readData.Package sellpac on sellpac.Name = oldItem.[Selling Package] collate LATIN1_GENERAL_CI_AS
join readData.Size siz on siz.Name = oldItem.Size collate LATIN1_GENERAL_CI_AS
--join WWI_DS.dbo.Sale s on oldItem.[Stock Item Key] = s.[Stock Item Key]

SET IDENTITY_INSERT salesMgt.SaleHeader ON
--inserting into saleheader table
insert into salesMgt.SaleHeader(SaleHeaderID, SalesPersonID, CityID, InvoiceDateKey, DeliveryDateKey, Profit)
select s.[WWI Invoice ID], e.UserID, newCity.CityID, s.[Invoice Date Key], s.[Delivery Date Key], sum(s.Profit)
from WWI_DS.dbo.Sale s
join WWI_DS.dbo.City city on city.[City Key] = s.[City Key]
join WWIGlobal.readData.State newState on city.[State Province] collate LATIN1_GENERAL_CI_AS like newState.Name + '%'
join WWIGlobal.readData.City newCity on newCity.Name collate LATIN1_GENERAL_CI_AS = city.City and newCity.StateID=newState.StateID
join WWI_DS.dbo.Employee oldE on oldE.[Employee Key] = s.[Salesperson Key]
join WWIGlobal.auth.UserTable e on e.PrimaryContact collate LATIN1_GENERAL_CI_AS = oldE.Employee
group by s.[WWI Invoice ID], s.[Invoice Date Key], e.UserID, s.[Invoice Date Key], s.[Delivery Date Key], newCity.CityID
order by s.[WWI Invoice ID]
SET IDENTITY_INSERT salesMgt.SaleHeader OFF

---inserting into SaleDetails
insert into salesMgt.SaleDetails(SaleHeaderID, CustomerID, Quantity, StockItemID, TaxRateID)
select s.[WWI Invoice ID], newCust.UserID,s.Quantity, newItem.StockItemID, tr.TaxRateID
from WWI_DS.dbo.Sale s
join WWI_DS.dbo.Customer oldCust on oldCust.[Customer Key] = s.[Customer Key]
join WWIGlobal.auth.UserTable newCust on newCust.PrimaryContact collate LATIN1_GENERAL_CI_AS = oldCust.[Primary Contact]
join WWI_DS.dbo.[Stock Item] oldItem on s.[Stock Item Key] = oldItem.[Stock Item Key]
join WWIGlobal.readData.Color col on col.Name collate LATIN1_GENERAL_CI_AS = oldItem.Color
join readData.TaxRate tr on tr.TaxRate = s.[Tax Rate]
join WWIGlobal.stock.StockItem newItem on newItem.Name collate LATIN1_GENERAL_CI_AS = s.Description and col.ColorID = newItem.ColorID
order by newCust.UserID
go

CREATE VIEW ItemsDiscounted
as
select si.StockItemID, 
case
	when pr.PromotionID is null then si.UnitPrice
	else si.UnitPrice * (100 - pr.Discount) / 100
end as DiscountedPrice
from stock.StockItem si
left join WWIGlobal.stock.Promotion pr on pr.PromotionID = si.PromotionID
go
--Creating the view with information about each sale
CREATE VIEW SalesData
AS 
select sh.SaleHeaderID, sh.CityID, sh.InvoiceDateKey, sh.DeliveryDateKey, sh.SalesPersonID, sh.Profit,
sum(sd.Quantity * dis.DiscountedPrice) as TotalExcludingTax, 
sum(sd.Quantity * dis.DiscountedPrice) * sum(tr.TaxRate) / (100 * count(sd.StockItemID)) as TaxAmount,
sum(sd.Quantity * dis.DiscountedPrice) + sum(sd.Quantity * dis.DiscountedPrice) * 15 / 100 as 'Total Including Tax',
sum(cast(si.IsChillerStock as int) * sd.Quantity) as totalChillerItems,
(sum(sd.Quantity) - sum(cast(si.IsChillerStock as int) * sd.Quantity)) as totalDryItems
--sum(sd.Quantity) as qty
from WWIGlobal.salesMgt.SaleHeader sh
join WWIGlobal.salesMgt.SaleDetails sd on sd.SaleHeaderID = sh.SaleHeaderID
join WWIGlobal.stock.StockItem si on sd.StockItemID = si.StockItemID
join WWIGlobal.readData.TaxRate tr on tr.TaxRateID = sd.TaxRateID
left join WWIGlobal.stock.Promotion pr on pr.PromotionID = si.PromotionID
join ItemsDiscounted dis on dis.StockItemID = si.StockItemID
group by sh.SaleHeaderID, sh.CityID, sh.InvoiceDateKey, sh.DeliveryDateKey, sh.SalesPersonID, sh.Profit
go