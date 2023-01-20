--SaleDetails Collection
SELECT
	sd.SaleHeaderID as [SaleHeaderID],
	ut.PrimaryContact as [Customer],
	ci.Name + '(' + st.Code + ')' as [City], 
	sd.Quantity as [Quantity], 
	sd.StockItemID as [StockItemID], 
	ut1.PrimaryContact as [SalesPerson],
	InvoiceDateKey as [InvoiceDate], 
	tr.TaxRate as [TaxRate] ,
	(sd.Quantity * dis.DiscountedPrice + (tr.TaxRate/100 * sd.Quantity * dis.DiscountedPrice)) as [TotalIncludingTax] FROM salesMgt.SaleDetails sd
join customer.Customer c on c.CustomerID = sd.CustomerID
join auth.UserTable ut on ut.UserID = c.CustomerID
join readData.TaxRate tr on tr.TaxRateID = sd.TaxRateId
join dbo.SalesData sh on sh.SaleHeaderID = sd.SaleHeaderID
join readData.City ci on ci.CityID = sh.CityID
join readData.State st on st.StateID = ci.StateID
join auth.UserTable ut1 on ut1.UserID = sh.SalesPersonID
join dbo.ItemsDiscounted dis on dis.StockItemID = sd.StockItemID
FOR JSON PATH


--StockItems Collection
SELECT 
	si.StockItemID as [StockItemID], 
	si.Name as [Name], 
	c.Name as [Color], 
	Brand as [Brand], 
	s.Name as [Size], 
	si.TypicalWeightPerUnit as [TypicalWeightPerUnit],
	si.UnitPrice as [UnitPrice]
	FROM stock.StockItem si
join readData.Color c on c.ColorID = si.ColorID
join readData.Size s on s.SizeID = si.SizeID
FOR JSON PATH