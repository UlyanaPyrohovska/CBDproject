--SaleDetails Collection
SELECT
	ut.PrimaryContact as [Customer],
	ci.Name + '(' + st.Code + ')' as [City], 
	Quantity as [Quantity], 
	StockItemID as [StockItemID], 
	ut1.PrimaryContact as [SalesPerson],
	InvoiceDateKey as [InvoiceDate], 
	tr.TaxRate as [TaxRate] ,
	[Total Including Tax] as [TotalIncludingTax] FROM SaleDetails sd
join Customer c on c.CustomerID = sd.CustomerID
join UserTable ut on ut.UserID = c.CustomerID
join TaxRate tr on tr.TaxRateID = sd.TaxRateId
join SalesData sh on sh.SaleHeaderID = sd.SaleHeaderID
join City ci on ci.CityID = sh.CityID
join State st on st.StateID = ci.StateID
join UserTable ut1 on ut1.UserID = sh.SalesPersonID
FOR JSON PATH

--SaleHeaders Collection
Select
	SaleHeaderID as [SaleHeaderID],
	c.Name + '(' + st.Code + ')' as [City], 
	ut.PrimaryContact as [SalesPerson], 
	InvoiceDateKey as [InvoiceDate], 
	[Total Including Tax] as [TotalIncludingTax]from SalesData sh
join Employee e on e.EmployeeID = sh.SalesPersonID
join UserTable ut on ut.UserID = e.EmployeeID
join City c on c.CityID = sh.CityID
join State st on st.StateID = c.StateID
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
	FROM StockItem si
join Color c on c.ColorID = si.ColorID
join Size s on s.SizeID = si.SizeID
FOR JSON PATH