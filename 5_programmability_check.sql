use WWIGlobal


--Tests if the function that counts the number of produts inside a saleDetails is working properly

select sd.SaleHeaderID, dbo.fn_countProductsInSale(sd.SaleHeaderID) as 'count' from SaleDetails sd order by SaleHeaderID

select sd.SaleHeaderID, sd.SaleDetailsID, sd.StockItemID, sd.Quantity from SaleDetails sd order by SaleHeaderID


--Tests if procedure that removes stock item from sale is working properly

select * from SaleHeader
select sd.SaleHeaderID, sd.SaleDetailsID, sd.StockItemID, sd.Quantity from SaleDetails sd order by SaleHeaderID

exec sp_removeStockItem 1, 15, 'no'

exec sp_removeStockItem 1, 182, 'no'

exec sp_removeStockItem 2, 217, 'yes'
exec sp_removeStockItem 2, 102, 'yes'

exec sp_removeStockItem 3,1,'no'

select * from SaleHeader
select sd.SaleHeaderID, sd.SaleDetailsID, sd.StockItemID, sd.Quantity from SaleDetails sd order by SaleHeaderID

---Tests if the triggers that maintain Chiller item consistency inside sales are working properly--

SELECT count(p.IsChillerStock) as'result'
		FROM dbo.SaleHeader sh
			join dbo.SaleDetails sd on sd.SaleHeaderID = sh.SaleHeaderID
			join dbo.StockItem p on p.StockItemID = sd.StockItemID
			where p.IsChillerStock = 1
		Group by sd.SaleHeaderID
		order by result 
	



select sd.SaleHeaderID, p.StockItemID, p.IsChillerStock, dbo.fn_checkChiller(sd.SaleHeaderID, 0) as 'result'
from SaleDetails sd
inner join StockItem p on p.StockItemID = sd.StockItemID
where p.IsChillerStock = 0
order by result DESC


select sh.SaleHeaderID, sd.SaleDetailsID, p.StockItemID, p.IsChillerStock
from SaleHeader sh
join SaleDetails sd on sd.SaleHeaderID = sh.SaleHeaderID
join StockItem p on p.StockItemID = sd.StockItemID
where sh.SaleHeaderID = 64639
order by SaleHeaderID

select * from SaleDetails where SaleHeaderID = 61518



----- Tests if triggers that check delivery times on sales work

SELECT  p.StockItemID, p.LeadTimeDays as 'leadtime' from dbo.SaleDetails sd 
		join dbo.StockItem p on sd.StockItemID = p.StockItemID
		order by p.LeadTimeDays 
		

SELECT DATEDIFF(day, i.InvoiceDateKey, i.DeliveryDateKey) as 'actual time', p.LeadTimeDays as 'lead time', p.StockItemID
from SaleHeader i 
join SaleDetails sd on sd.SaleDetailsID = i.SaleHeaderID
join StockItem p on p.StockItemID = sd.StockItemID
order by [actual time] desc

select * from SaleHeader

insert into SaleHeader(CityID,Profit,SalesPersonID,InvoiceDateKey,DeliveryDateKey)
values (1,1,403,'2023-01-16','2023-02-16')

select * from SaleHeader
order by SaleHeaderID DESC

select dbo.fn_checkTime(70516)

select count(sd.SaleHeaderID) from SaleDetails sd where sd.SaleHeaderID = 70516


select * from Employee

insert into SaleHeader(CityID,Profit,SalesPersonID,InvoiceDateKey,DeliveryDateKey)
values (1,1,1,'2023-01-16','2023-01-17')


update SaleHeader
set InvoiceDateKey = '2023-01-16', DeliveryDateKey = '2023-05-16'
where SaleHeaderID = 1


update SaleHeader
set InvoiceDateKey = '2023-01-16', DeliveryDateKey = '2023-01-17'
where SaleHeaderID = 1


---Check if the procedure that updates a product's quantity in a sale is working properly

select SaleDetailsID, StockItemID, Quantity from SaleDetails where SaleDetailsID = 2

exec sp_update_product_qty 1, 20

UPDATE salesMgt.SaleDetails 
	SET 
	CustomerID = 2,
	StockItemID = 15,
	Quantity = 199,
	SaleHeaderID = 1,
	TaxRateId = 3
	WHERE SaleDetailsID = 1;

select * from salesMgt.SaleDetails  

select * from StockItem where SaleDetailsID = 1

update StockItem
	SET LeadTimeDays = 1
	where StockItemID = 1

-- Tests if procedure that adds new Sale Detail is working properly 

select * from SaleDetails order by SaleDetailsID DESC

exec sp_new_SaleDetail 70516, 1, 20, 3, 4

exec sp_new_SaleDetail 705160, -1, 20, 3, 4

exec sp_new_SaleDetail 70516, 1, 20, -43, 4

exec sp_new_SaleDetail 70516, 1, 20, 3, 42


-- Tests if procedures to add and remove Promotions are working properly

select * from Promotion order by PromotionID DESC

SELECT * from StockItem where PromotionID IS NOT NULL

exec sp_addPromotion 1, 50.00, '2023-01-16','2023-01-31'

exec sp_addPromotion 1, 20.00, '2024-01-16','2024-01-31'

exec sp_addPromotion 300000, 51.00, '2023-01-16','2023-01-31'

select * from Promotion order by PromotionID DESC

SELECT * from StockItem where PromotionID IS NOT NULL

exec sp_removePromotion 1

exec sp_removePromotion 1000000

exec sp_removePromotion 5

SELECT * from StockItem where PromotionID IS NOT NULL


--- Tests if procedures that manage users work properly

select * from UserData

exec sp_createUser 1, 123, 'mail@gmail.com'

exec sp_createUser 4000, 123, 'mail@gmail.com'

select * from UserData


exec sp_password_check 5, wow

exec sp_password_check -5, wow


select * from PasswordResetToken

exec sp_generate_token 1

exec sp_generate_token -1

select * from PasswordResetToken

exec sp_editUser 1, 2, 987, 'novo@gmail.com'

exec sp_editUser -1, 2, 987, 'novo@gmail.com'

exec sp_editUser 1, -2, 987, 'novo@gmail.com'

select * from UserData

exec sp_removeUser 1

exec sp_removeUser 10

select * from UserData

