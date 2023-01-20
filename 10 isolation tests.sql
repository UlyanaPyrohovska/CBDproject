use WWIGlobal;
go


-- 1º Teste - update product quantity 
set transaction isolation level repeatable read
begin tran
	exec sp_update_product_qty 2, 50; -- valor original: 90
	waitfor delay '00:00:05';
	select * from salesMgt.SaleDetails where SaleDetailsID = 2
commit tran

-- 2º Teste - get sale total price 
set transaction isolation level serializable
begin tran
	select salesMgt.fnGetSaleTotalPrice(9091) --13505
	waitfor delay '00:00:05';
	select salesMgt.fnGetSaleTotalPrice(9091) --13505 apesar do valor efetivado na bd ser diferente (13345)
commit tran

-- 3º Teste - adicionar um produto numa venda
set transaction isolation level repeatable read
begin tran
	exec salesMgt.sp_new_SaleDetail 4040, 1, 123, 1, 1
	waitfor delay '00:00:05';
	select * from salesMgt.SaleDetails where SaleHeaderID = 4040 --5125 apesar do valor efetivado na bd ser diferente (13345)
commit tran

-- 4º Teste - adicionar uma promoçao
set transaction isolation level serializable
begin tran
	exec stock.sp_addPromotion 66, 0.9, '2023-01-01', '2023-12-12'
	waitfor delay '00:00:05';
	select * from stock.StockItem where StockItemID = 66 --5125 apesar do valor efetivado na bd ser diferente (13345)
commit tran


-- 5º Teste - mudar preço do produto
set transaction isolation level serializable
begin tran
	exec salesMgt.sp_update_product_price 42,60
	waitfor delay '00:00:05';
	select * from stock.StockItem where StockItemID = 42 --60 apesar do valor efetivado na bd ser diferente (18)
commit tran



set transaction isolation level read committed
