use WWIGlobal;
go

-- 1� Teste
begin tran
	update salesMgt.SaleDetails set Quantity = 1 where SaleDetailsID = 2
	select * from salesMgt.SaleDetails where SaleDetailsID = 2
commit tran


-- 2� Teste
begin tran
	exec salesMgt.sp_removeStockItem 9091, 216, 'no'
	select salesMgt.fnGetSaleTotalPrice(9091) --13345
commit tran


-- 3� teste 
begin tran
	exec salesMgt.sp_removeStockItem 4040, 1, 'no'
	select * from salesMgt.SaleDetails where SaleHeaderID = 4040
commit tran


-- 4� teste 
begin tran
	exec stock.sp_removePromotion 66
	select * from stock.StockItem where StockItemID = 66
commit tran


-- 5� teste 
begin tran
	exec salesMgt.sp_update_product_price 42, 18
	select * from stock.StockItem where StockItemID = 42
commit tran


