--SaleDetails Collection
SELECT
	SaleHeaderID as [SaleHeaderID], 
	ut.PrimaryContact as [Customer],
	Quantity as [Quantity], 
	StockItemID as [StockItemID], 
	tr.TaxRate as [TaxRate] FROM SaleDetails sd
join Customer c on c.CustomerID = sd.CustomerID
join UserTable ut on ut.UserID = c.CustomerID
join TaxRate tr on tr.TaxRateID = sd.TaxRateId
FOR JSON PATH

--SaleHeaders Collection
Select
	SaleHeaderID as [SaleHeaderID],
	c.Name+ st.Code as [City], 
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
	c.Name as [City], 
	Brand as [Brand], 
	s.Name as [Size], 
	si.TypicalWeightPerUnit as [TypicalWeightPerUnit],
	si.UnitPrice as [UnitPrice]
	FROM StockItem si
join Color c on c.ColorID = si.ColorID
join Size s on s.SizeID = si.SizeID
FOR JSON PATH