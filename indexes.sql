--Search sales by city. The name of the city, the name of the seller, to make available, total sales 
--(note: cities with the same name but different locations should be considered distinct);

SELECT * FROM UserTable

SET STATISTICS IO ON

CREATE NONCLUSTERED INDEX city_index on City(Name) include(StateID)

DROP INDEX city_index on City

SELECT c.Name, st.Name, e.PrimaryContact, COUNT(SaleHeaderID) as TotalSales FROM SaleHeader s
join City c on c.CityID = s.CityID
join State st on st.StateID = c.StateID
join UserTable e on e.UserID = s.SalesPersonID
where c.Name = 'Madaket' and st.Name = 'Massachusetts'
group by  c.Name, e.PrimaryContact, st.Name

--For sales, calculate the growth rate for each year, compared to the previous year, by customer category;

CREATE or ALTER FUNCTION fn_total(
	@ano int,
	@cat varchar(25)
)
RETURNS FLOAT
BEGIN
	DECLARE @val float
	BEGIN
		SELECT @val = (select CAST(count(sh.SaleHeaderID)as float)  from SaleHeader sh
	join SaleDetails sd on sd.SaleHeaderID = sh.SaleHeaderID
	join Customer c on c.CustomerID = sd.CustomerID
	join CustomerCategory cc on c.CategotyID = cc.CustomerCategoryID
	where sh.InvoiceDateKey like CAST(@ano as varchar) + '%' and cc.Name = @cat)
	END
	if @val = 0 RETURN dbo.fn_total(@ano+1, @cat)
	RETURN @val
END
GO

SELECT A.Ano, (dbo.fn_total(A.Ano, 'Novelty Shop' )- dbo.fn_total(A.Ano-1, 'Novelty Shop' ))/dbo.fn_total(A.Ano-1, 'Novelty Shop') as GrowthRate
from (SELECT DISTINCT YEAR(sh.InvoiceDateKey) as Ano from SaleHeader sh) A
ORDER BY A.Ano


CREATE NONCLUSTERED INDEX InvoiceDateKey_index on SaleHeader(InvoiceDateKey)

DROP INDEX InvoiceDateKey_index on SaleHeader

--Number of products (stockItem) in sales by color.

CREATE NONCLUSTERED INDEX stockItem_index on SaleDetails(StockItemID)

DROP INDEX stockItem_index on SaleDetails

SELECT c.Name, count(SaleDetailsID) as NumOfProducts FROM SaleDetails s
join StockItem si on si.StockItemID = s.StockItemID
join Color c on c.ColorID = si.ColorID
--where c.Name = 'White'
GROUP BY c.Name

SET STATISTICS IO OFF