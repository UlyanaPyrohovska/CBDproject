use WWIGlobal
go
--Creating the master key of the database
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'CBDProjectPass'

--Creating the Encryption Certificate
CREATE CERTIFICATE EncryptionCert
WITH SUBJECT = 'Project Data'

--Creating Symmetric Key
CREATE SYMMETRIC KEY PriceKey WITH
ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE EncryptionCert

--Adding the EncryptPrice column to store encrypted price
ALTER TABLE stock.StockItem ADD [EncryptPrice] VARBINARY(256)

--Encrypting the UnitPrice column 
OPEN SYMMETRIC KEY PriceKey
DECRYPTION BY CERTIFICATE EncryptionCert
UPDATE stock.StockItem
SET [EncryptPrice] = ENCRYPTBYKEY(KEY_GUID('PriceKey'), convert(varchar(256),UnitPrice))

--Decrypting the EncryptPrice column for testing purposes
OPEN SYMMETRIC KEY PriceKey
DECRYPTION BY CERTIFICATE EncryptionCert
SELECT EncryptPrice, CONVERT(VARCHAR(50), DECRYPTBYKEY([EncryptPrice])) as [DecryptPrice]
FROM stock.StockItem

-- SP: Editing the procedure in order to enable hashing of the passwords using 'SHA' algorithm
--	Parameters:
--		@UserID -> id of the user which needs to be authorized in the system
--		@hash -> password to be encrypted in the system
--		@mail nvarchar(255) -> email of the new user
CREATE OR ALTER PROCEDURE sp_createUser(
	@UserID int,
	@hash varchar(30),
	@mail nvarchar(255)
)
as
begin try
	if not exists (select 1 from auth.UserTable c where c.UserID = @UserID)
		RAISERROR('User does not exist in table',16,1);	
	begin tran
		insert into auth.UserData(UserID, PasswordHash, Email)
		values(@UserID, HashBytes('SHA', @hash), @mail)
	commit tran
		
end try
begin catch
	rollback transaction
	print ERROR_MESSAGE()
	insert into auth.Errors(Username, Message, Number, Date)
	values (SUSER_ID(), ERROR_MESSAGE(),  ERROR_NUMBER(), getdate())
end catch

--SP: procedure to check if the password is valid
--	Parameters:
--		@hash -> password
--		@mail -> email of the user
CREATE OR ALTER PROCEDURE sp_password_check(
	@mail nvarchar(255),
	@hash varchar(30)
)
as
	if exists(
	SELECT 1 FROM auth.UserData where Email = @mail and PasswordHash = HASHBYTES('SHA', @hash)
	)
	BEGIN
		SELECT 'Password matched'
	END
	ELSE
	BEGIN
		SELECT 'Password did not match!'
	END

--Test case of creating a user and checcking the password through procedures

exec sp_createUser 1,  N'teste123', 'ullasa@ukr.net'

exec sp_password_check 'ullasa@ukr.net', N'teste123'

--Justification: In terms of encryption it was decided to encrypt the price in order to have the ability to decrypt it in case of need
--while the password needs to be stored hashed and we don't need to retreive the actual password.
--That's why we are using symmetric key for encrypting and decrypting the unitPrice and use hashing to securely store the users' passwords