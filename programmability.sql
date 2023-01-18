USE WWIGlobal;
go

--FUNCTION
--	returns the sum total of products in a given saleDetails
--	parameters: @SaleID int - the ID of a SaleHeader that will render a list of products from the same sale
drop function if exists fn_countProductsInSale
go

CREATE OR ALTER FUNCTION fn_countProductsInSale(
	@SaleID int
)
RETURNS INT
AS
BEGIN 
	DECLARE @count int;
	BEGIN
		--SELECT @count = count(*) from dbo.SaleDetails sd where sd.SaleHeaderID = @SaleID 
		SELECT @count = count(sd.StockItemID)
		FROM SaleDetails sd
		join SaleHeader sh on sd.SaleHeaderID = sh.SaleHeaderID
		where sd.SaleHeaderID = @SaleID
		group by sd.SaleHeaderID
	END;
	RETURN @count
END 
GO


--PROCEDURE
--	Removes a StockItem from a given sale / removes a sale
--	The user can make the choice of removing the whole SaleHeader containing the product or only the saleDetails instance
--	Throws an error if SaleHeader with SaleHeaderID does not exist 
-- parameters: 
--		@saleID int - ID of the sale containing the stockitem
--		@itemID int - ID of the StockItem to be removed 
--		@removeSale nvarchar(50) - action to perform (delete saleHeader or just saleDetails | yes or no)
DROP procedure if exists sp_removeStockItem
go

Create or Alter procedure sp_removeStockItem(
	@saleID int,
	@itemID int,
	@removeSale nvarchar(50)
)
AS
BEGIN try
	DECLARE @count int
	select @count = dbo.fn_countProductsInSale(@saleID)
	
	if (select count(*) from SaleDetails sh where sh.SaleHeaderID = @saleID and sh.StockItemID = @itemID) = 0
		RAISERROR('Sale does not exist in table',16,1);

	begin transaction
	DELETE FROM [dbo].[SaleDetails]
	WHERE StockItemID = @itemID
	AND SaleHeaderID = @saleID

	if @removeSale = 'yes' and dbo.fn_countProductsInSale(@saleID) IS NULL
		DELETE FROM [dbo].[SaleHeader]
		WHERE SaleHeaderID = @saleID
	commit transaction

END try
BEGIN CATCH
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
END CATCH;
go



--FUNCTION
--	returns the sum total of the price of a saleHeader (sum of the prices of the products)
--	parameters: @SaleID int - the ID of a SaleHeader
CREATE or ALTER FUNCTION fnGetSaleTotalPrice(
	@SaleID int
)
RETURNS MONEY
AS
BEGIN 
	DECLARE @result money
	

	BEGIN
		SELECT @result = sum(p.UnitPrice * sd.Quantity)
		FROM dbo.SaleDetails sd
			join dbo.StockItem p on p.StockItemID = sd.StockItemID
		WHERE @SaleID = sd.SaleHeaderID
		Group by sd.SaleHeaderID
	END

	RETURN @result
END 
go

--FUNCTION
--	returns 0 if the product was not delivered within the time specified in the product table
--	parameters: @SaleID int - the ID of a SaleHeader
Create or alter function fn_checkTime(
	@SaleID int
)
RETURNS BIT
as
begin
	DECLARE @leadTime int
	DECLARE @actualTime int

	if((select count(sd.SaleHeaderID) from SaleDetails sd) = 0) return 2

	SELECT @leadTime = p.LeadTimeDays from dbo.SaleDetails sd 
		join dbo.StockItem p on sd.StockItemID = p.StockItemID
	where sd.SaleHeaderID = @SaleID
	SELECT @actualTime = DATEDIFF(day, i.InvoiceDateKey, i.DeliveryDateKey) from SaleHeader i where i.SaleHeaderID = @SaleID

	if @actualTime > @leadTime
		return 0
	
	return 1
END
GO


--Trigger for the table SaleHeader, for after when it is subject of insert
--	It will verify the difference of the dates of expected delivery and actual delivery
-- 	If the actual delivery presents a greater value it will throw an error stating this issue
DROP TRIGGER IF EXISTS  trg_LeadTimeDays_insert
go

CREATE OR ALTER TRIGGER trg_LeadTimeDays_insert
	ON dbo.SaleHeader
	instead of INSERT
AS
BEGIN TRY
	DECLARE @SaleID int
	Select @SaleID = i.SaleHeaderID from inserted i

	BEGIN TRAN
		insert into SaleHeader(SalesPersonID,CityID,InvoiceDateKey,DeliveryDateKey,Profit)
		select i.SalesPersonID, i.CityID, i.InvoiceDateKey, i.DeliveryDateKey, i.Profit from inserted i
	COMMIT TRAN
	
	if (select dbo.fn_checkTime(@SaleID)) = 0
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR('Delivery took more time than expected',16,1);
		END

END TRY	
BEGIN CATCH
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
END CATCH
go


--Trigger for the table SaleHeader, for after when it is subject of update
--	It will verify the difference of the dates of expected delivery and actual delivery
-- 	If the actual delivery presents a greater value it will throw an error stating this issue
DROP TRIGGER IF EXISTS trg_LeadTimeDays_update
go

CREATE OR ALTER TRIGGER trg_LeadTimeDays_update
	ON dbo.SaleHeader
	instead of update
AS
BEGIN TRY
	DECLARE @SaleID int
	Select @SaleID = i.SaleHeaderID from inserted i

	BEGIN TRAN
		update SaleHeader set
			CityID = i.CityID,
			SalesPersonID = i.SalesPersonID,
			Profit = i.Profit,
			InvoiceDateKey = i.InvoiceDateKey,
			DeliveryDateKey = i.DeliveryDateKey
			from inserted i 
				join SaleHeader sd on sd.SaleHeaderID = i.SaleHeaderID
	COMMIT TRAN
	
	if (select dbo.fn_checkTime(@SaleID)) = 0
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR('Delivery took more time than expected',16,1);
		END

END TRY	
BEGIN CATCH
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
END CATCH
go


--FUNCTION
--	returns 0 if the Sale has products that are stored in a chiller and products that are not at the same time
--	parameters: 
--		@SaleID int - the ID of a SaleHeader
--		@Chiller bit - the value of IsChiller of the product in the new sale
CREATE OR ALTER function fn_checkChiller(
	@SaleID int,
	@Chiller bit
)
returns bit
as
begin 
	declare @isChiller bit
	declare @count int
	
	SELECT @count = count(p.IsChillerStock)
		FROM dbo.SaleDetails sd
			join dbo.StockItem p on p.StockItemID = sd.StockItemID
		WHERE @SaleID = sd.SaleHeaderID
			AND p.IsChillerStock =  ~@Chiller
		Group by sd.SaleHeaderID
	
	if @count > 0
		return 0
	return 1
END 
go


--Trigger on SaleDetails after an insert 
--	It will verify if the new values in the updated/inserted columns dont conflict with the remaining saleDetails in the same Header
--	(A given SaleHeader must only contain either chiller or non-chiller stock)
--	If the obove condition is not met the trigger will throw an error
CREATE OR ALTER TRIGGER trg_ChillerStockSale_Insert
	ON dbo.SaleDetails
	instead of INSERT
AS
BEGIN try
	declare @isChiller bit
	declare @saleID int
	select @isChiller = p.IsChillerStock
	from StockItem p join inserted i on i.StockItemID = p.StockItemID
	select @saleID = i.SaleHeaderID from inserted i

	begin tran
		insert into SaleDetails(CustomerID,SaleHeaderID,StockItemID,Quantity,TaxRateId)
		select CustomerID,SaleHeaderID,StockItemID,Quantity,TaxRateId from inserted
	commit tran
	
	if (select dbo.fn_checkChiller(@saleID, @isChiller)) = 0
		begin
			rollback tran
			RAISERROR('All items must all be either stored on a chiller or not',16,1)
		end

end try
BEGIN CATCH
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
END CATCH
go


--Trigger on SaleDetails after an update
--	It will verify if the new values in the updated/inserted columns dont conflict with the remaining saleDetails in the same Header
--	(A given SaleHeader must only contain either chiller or non-chiller stock)
--	If the obove condition is not met the trigger will throw an error
CREATE OR ALTER TRIGGER trg_ChillerStockSale_Update
	ON dbo.SaleDetails
	instead of update
AS
BEGIN try
	declare @isChiller bit
	declare @saleID int
	select @isChiller = p.IsChillerStock
	from StockItem p join inserted i on i.StockItemID = p.StockItemID
	select @saleID = i.SaleHeaderID from inserted i

	begin tran
		update SaleDetails set
			SaleHeaderID = i.SaleHeaderID,
			CustomerID = i.CustomerID,
			StockItemID = i.StockItemID,
			TaxRateId = i.TaxRateId
			from inserted i 
				join SaleDetails sd on sd.SaleDetailsID = i.SaleDetailsID
	commit tran
	
	if (select dbo.fn_checkChiller(@saleID, @isChiller)) = 0
		begin
			rollback tran
			RAISERROR('All items must all be either stored on a chiller or not',16,1)
		end
	
end try
BEGIN CATCH
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
END CATCH
go




-- SP: Change a product's quantity in a given sale
-- Parameters: 
--		SalesDetailID - The ID of the SaleDetail containing the product in question
--		Qty - The new quantity
CREATE OR ALTER PROCEDURE sp_update_product_qty 
@SalesDetailID int, @Qty int 

AS 
BEGIN TRY

-- todo: Validation of the qty value (>0), can also be done in trigger
	if (select count(*) from SaleDetails sd where sd.SaleDetailsID = @SalesDetailID) = 0
		RAISERROR('Sale does not exist in table',16,1);

	if @Qty <= 0
		RAISERROR('New quantity cannot be 0 or negative', 16,1);

	begin transaction
		UPDATE SaleDetails 
			SET Quantity = @Qty
			WHERE SaleDetailsID = @SalesDetailID;
	commit transaction


END TRY
begin catch
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
end catch
go

exec sp_update_product_qty  1, 2
go

-- SP: Add a new product to a given sale
-- Parameters: 
--		SalesHeaderID - The ID of the sale header to insert the new product
--		Qty - The new quantity of the product
--		CustomerID - The ID of the Customer purchasing the product
--		ProductID - ID of the product
CREATE OR ALTER PROCEDURE sp_new_SaleDetail 
@SalesHeaderID int, @ProductID int, @Qty int, @CustomerID int, @TaxID int

AS 
BEGIN TRY
-- Todo: validation of customer id and qty, can also be done in triggers (before insert)

	if (select count(*) from SaleHeader sh where sh.SaleHeaderID = @SalesHeaderID) = 0
		RAISERROR('Sale does not exist in table',16,1);

	if(select count(*) from StockItem p where p.StockItemID = @ProductID) = 0
		RAISERROR('Item does not exist in table',16,1);

	if (select count(*) from Customer c where c.CustomerID = @CustomerID) = 0
		RAISERROR('Customer does not exist in table',16,1);	

	begin tran
		INSERT INTO SaleDetails(SaleHeaderID, CustomerID, Quantity, StockItemID,TaxRateId)
		VALUES(@SalesHeaderID, @CustomerID, @Qty, @ProductID,@TaxID)
	commit tran

END TRY
begin catch
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
end catch
go


--SP: create a Promotion and add's it to a given StockItem
-- THrows an error if StockItemID is not VALIDATE
-- Parameters:
--		@itemID int - the id of the stockitem
--		@Discount decimal - the discount value (percentage)
--		@Start date - begining date of promo
--		@End date - end date of promo
CREATE OR ALTER PROCEDURE sp_addPromotion(
	@ItemID int,
	@Discount decimal(18,3),
	@Start date,
	@End date
)
as
begin try
	declare @promoID int
	declare @count int
	select top 1 @promoID = P.PromotionID
	from Promotion p
	order by p.PromotionID DESC
	set @promoID = @promoID + 1

	if (select count(*) from StockItem p where p.StockItemID = @ItemID) = 0
		RAISERROR('Item does not exist in table',16,1);

	
		insert into Promotion(Discount, StartDate, EndDate)
		values(@Discount, @Start, @End)

		update StockItem
		set PromotionID = @promoID
		where StockItemID = @ItemID
	
end try
begin catch
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
end catch
go


--SP: removes a promotion from a given StockItem through the stockitemID and deletes the promotion in the Promotions table
-- Throws an error if the @ItemID is not valid
--Paramteres: @ItemID int - ID of the StockItem in question
CREATE OR ALTER PROCEDURE sp_removePromotion(
	@ItemID int
)
as
begin try
	if (select count(*) from StockItem p where p.StockItemID = @ItemID) = 0
		RAISERROR('Item does not exist in table',16,1);

	if (select count(p.PromotionID) from StockItem p where p.StockItemID = @ItemID) = 0
		RAISERROR('Item does not have promotion',16,1);

	declare @promoID int
	select @promoID = i.PromotionID
	from StockItem i
	where i.StockItemID = @ItemID

	update StockItem
	set PromotionID = null
	where StockItemID = @ItemID
	
	delete from Promotion
	where PromotionID = @promoID
end try
begin catch
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
end catch
go

--SP: creates a new user for a given Customer
-- throws an error if the customer in question does not exist
--parameters:
--		@hash binary(64) - the encrypted password of the user
--		@CustomerID int - the ID of the customer in question
--		@mail nvarchar(255) - the email of the customer
CREATE OR ALTER PROCEDURE sp_createUser(
	@CustomerID int,
	@hash binary(64),
	@mail nvarchar(255)
)
as
begin try
	if (select count(*) from Customer c where c.CustomerID = @CustomerID) = 0
		RAISERROR('Customer does not exist in table',16,1);	
	if (select count(*) from UserData c where c.UserDataID = @CustomerID) > 0
		RAISERROR('User already exists in table',16,1);	

	begin tran
		insert into UserData(UserDataID, PasswordHash, Email)
		values(@CustomerID, @hash, @mail)
	commit tran
		
end try
begin catch
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
end catch
go

--SP: Generates a password reset token for the user
-- throws an error if the user in question does not exist
--parameters:
--		@UserID int - Id of the user
create or alter procedure sp_generate_token(
	@UserID int
)
as
begin try
	if not exists (select 1 from UserData u where u.UserDataID = @userID)
		RAISERROR('User does not exist in table',16,1);
	begin tran
		insert into PasswordResetToken(UserDataID, Token, ExpDate)
		values (@userID, newid(), DATEADD(hour,24,GETDATE()))
	commit tran
end try
begin catch
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
end catch
go
 


--SP: Edits an user's many columns
-- throws an error if the customer or the user account in question does not exist
--parameters:
--		@userID int - The id of the Customer's user account
--		@CustomerID int - the ID of the Customer
--		@mail nvarchar(255) - the new email of the customer
--		@hash binary(64) - the new encrypted password of the user
CREATE OR ALTER PROCEDURE sp_editUser(
	@userID int,
	@CustomerID int,
	@hash binary(64),
	@mail nvarchar(255)
)
as
begin try
 
	if  (select count(*) from Customer c where c.CustomerID = @CustomerID) = 0
		RAISERROR('Customer does not exist in table',16,1);
	if  (select count(*) from UserData u where u.UserDataID = @userID) = 0
		RAISERROR('User does not exist in table',16,1);

	begin tran
		update UserData set
			UserDataID = @CustomerID,
			PasswordHash = @hash,
			Email = @mail
		where UserDataID = @userID
	commit tran

end try
begin catch
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
end catch
go



--SP: Removes an user account
-- throws an error if the user account in question does not exist
--parameters:
--		@userID int - The id of the Customer's user account
CREATE OR ALTER PROCEDURE sp_removeUser(
	@UserID int
)
as
begin try
	if (select count(*) from UserData u where u.UserDataID = @userID)  = 0
		RAISERROR('User does not exist in table',16,1);

	begin tran
		delete from UserData where UserDataID = @UserID
	commit tran

end try
begin catch
	insert into Errors(Username, Message, Number, Date)
	values(SUSER_NAME(), ERROR_MESSAGE(), ERROR_NUMBER(), GETDATE())
	DECLARE @msg varchar(max) = ERROR_MESSAGE(),
			@sev int = ERROR_SEVERITY(),
			@state smallint = ERROR_STATE()
	RAISERROR(@msg, @sev, @state)
end catch
go