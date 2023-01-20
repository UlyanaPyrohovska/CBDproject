use WWIGlobal
--Search sales by city. The name of the city, the name of the seller, to make available, total sales 
--(note: cities with the same name but different locations should be considered distinct);

SET STATISTICS IO ON

CREATE NONCLUSTERED INDEX city_index on readData.City(Name)

DROP INDEX [saleDetailsIndex]
ON [salesMgt].[SaleDetails]

CREATE NONCLUSTERED INDEX [saleDetailsIndex]
ON [salesMgt].[SaleDetails] ([StockItemID])
INCLUDE ([SaleHeaderID],[Quantity],[TaxRateId])

CREATE VIEW citySales
as
SELECT c.Name, st.Name, e.PrimaryContact, sum([Total Including Tax]) as TotalSales FROM dbo.SalesData s
join readData.City c on c.CityID = s.CityID
join readData.State st on st.StateID = c.StateID
join auth.UserTable e on e.UserID = s.SalesPersonID
--where c.Name = 'Madaket' and st.Name = 'Massachusetts'
group by  c.Name, e.PrimaryContact, st.Name
go

--For sales, calculate the growth rate for each year, compared to the previous year, by customer category;

CREATE or ALTER FUNCTION fn_total(
	@ano int,
	@cat varchar(25)
)
RETURNS FLOAT
BEGIN
	DECLARE @val float
	BEGIN
		SELECT @val = (select CAST(count(sh.SaleHeaderID)as float)  from salesMgt.SaleHeader sh
	join salesMgt.SaleDetails sd on sd.SaleHeaderID = sh.SaleHeaderID
	join customer.Customer c on c.CustomerID = sd.CustomerID
	join customer.CustomerCategory cc on c.CategotyID = cc.CustomerCategoryID
	where sh.InvoiceDateKey like CAST(@ano as varchar) + '%' and cc.Name = @cat)
	END
	if @val = 0 RETURN dbo.fn_total(@ano+1, @cat)
	RETURN @val
END
GO

CREATE VIEW GrowthRate
AS
SELECT A.Ano, (dbo.fn_total(A.Ano, 'Novelty Shop' )- dbo.fn_total(A.Ano-1, 'Novelty Shop' ))/dbo.fn_total(A.Ano-1, 'Novelty Shop') as GrowthRate
from (SELECT DISTINCT YEAR(sh.InvoiceDateKey) as Ano from salesMgt.SaleHeader sh) A

select * from GrowthRate
ORDER BY Ano


CREATE NONCLUSTERED INDEX InvoiceDateKey_index on salesMgt.SaleHeader(InvoiceDateKey)

DROP INDEX InvoiceDateKey_index on SaleHeader

--Number of products (stockItem) in sales by color.

CREATE NONCLUSTERED INDEX stockItem_index on salesMgt.SaleDetails(StockItemID)

DROP INDEX stockItem_index on SaleDetails

CREATE VIEW NumOfProductsByColor
AS
SELECT c.Name, count(SaleDetailsID) as NumOfProducts FROM salesMgt.SaleDetails s
join stock.StockItem si on si.StockItemID = s.StockItemID
join readData.Color c on c.ColorID = si.ColorID
--where c.Name = 'White'
GROUP BY c.Name
go

select * from NumOfProductsByColor

SET STATISTICS IO OFF