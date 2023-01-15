--SaleDetails Collection
SELECT Top(1) 
	SaleHeaderID as [SaleHeader.Id], 
	ut.PrimaryContact as [SaleHeader.Customer],
	Quantity as [SaleHeader.Quantity], 
	StockItemID as [SaleHeader.StockItemID], 
	tr.TaxRate as [SaleHeader.TaxRate] FROM SaleDetails sd
join Customer c on c.CustomerID = sd.CustomerID
join UserTable ut on ut.UserID = c.CustomerID
join TaxRate tr on tr.TaxRateID = sd.TaxRateId
FOR JSON AUTO

select * from StockItem

Select SaleHeaderID,c.Name+' '+ st.Code as City, ut.PrimaryContact, InvoiceDateKey, [Total Including Tax] from SalesData sh
join Employee e on e.EmployeeID = sh.SalesPersonID
join UserTable ut on ut.UserID = e.EmployeeID
join City c on c.CityID = sh.CityID
join State st on st.StateID = c.StateID

SELECT si.StockItemID, si.Name, c.Name, Brand, s.Name, si.TypicalWeightPerUnit FROM StockItem si
join Color c on c.ColorID = si.ColorID
join Size s on s.SizeID = si.SizeID
