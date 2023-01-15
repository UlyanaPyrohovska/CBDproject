--Search sales by city. The name of the city, the name of the seller, to make available, total sales 
--(note: cities with the same name but different locations should be considered distinct);

SELECT * FROM UserTable

SET STATISTICS IO ON

--CREATE NONCLUSTERED INDEX pc_index on UserTable(PrimaryContact)
--CREATE NONCLUSTERED INDEX emp_index on SaleHeader(SalesPersonID)
CREATE NONCLUSTERED INDEX city_index on City(Name)
--CREATE NONCLUSTERED INDEX state_index on State(Name)

--DROP INDEX pc_index on UserTable
--DROP INDEX emp_index on SaleHeader
DROP INDEX city_index on City
--DROP INDEX state_index on State

SELECT c.Name, st.Name, e.PrimaryContact, COUNT(SaleHeaderID) as TotalSales FROM SaleHeader s
join City c on c.CityID = s.CityID
join State st on st.StateID = c.StateID
join UserTable e on e.UserID = s.SalesPersonID
where c.Name = 'Madaket' and st.Name = 'Massachusetts'
group by  c.Name, e.PrimaryContact, st.Name

--For sales, calculate the growth rate for each year, compared to the previous year, by customer category;

CREATE NONCLUSTERED INDEX InvoiceDateKey_index on SaleHeader(InvoiceDateKey)
--CREATE NONCLUSTERED INDEX CustomerID_index on SaleDetails(CustomerID)

DECLARE @Category varchar(20), 
		@Year int

SET @Category = 'Novelty Shop' 
SET @Year = 2014

SELECT (count(sh.SaleHeaderID) - (select count(sh.SaleHeaderID) from SaleHeader sh
join SaleDetails sd on sd.SaleHeaderID = sh.SaleHeaderID
join Customer c on c.CustomerID = sd.CustomerID
join CustomerCategory cc on c.CategotyID = cc.CustomerCategoryID
where sh.InvoiceDateKey like CAST(@Year-1 as varchar) + '%' and cc.Name = @Category
))/(select CAST(count(sh.SaleHeaderID)as float)  from SaleHeader sh
join SaleDetails sd on sd.SaleHeaderID = sh.SaleHeaderID
join Customer c on c.CustomerID = sd.CustomerID
join CustomerCategory cc on c.CategotyID = cc.CustomerCategoryID
where sh.InvoiceDateKey like CAST(@Year-1 as varchar) + '%' and cc.Name = @Category) as GrowthRate FROM SaleHeader sh
join SaleDetails sd on sd.SaleHeaderID = sh.SaleHeaderID
join Customer c on c.CustomerID = sd.CustomerID
join CustomerCategory cc on c.CategotyID = cc.CustomerCategoryID
where sh.InvoiceDateKey like CAST(@Year as varchar) + '%' and cc.Name = @Category

--Number of products (stockItem) in sales by color.

CREATE NONCLUSTERED INDEX stockItem_index on SaleDetails(StockItemID)

DROP INDEX stockItem_index on SaleDetails

SELECT c.Name, count(SaleDetailsID) as NumOfProducts FROM SaleDetails s
join StockItem si on si.StockItemID = s.StockItemID
join Color c on c.ColorID = si.ColorID
--where c.Name = 'White'
GROUP BY c.Name

SET STATISTICS IO OFF