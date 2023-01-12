--Creating the master key of the database
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'CBDProjectPass'

--Creating the Encryption Certificate
CREATE CERTIFICATE EncryptionPassCert
WITH SUBJECT = 'Project Data'

--Creating Symmetric Key
CREATE SYMMETRIC KEY PasswordKey WITH
ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE EncryptionPassCert

--ALTER TABLE [dbo].[table1] ADD [EncryptName] VARBINARY(256)

--OPEN SYMMETRIC KEY PasswordKey
--DECRYPTION BY CERTIFICATE EncryptionPassCert
--UPDATE [dbo].[table1]
--SET [EncryptName] = ENCRYPTBYKEY(KEY_GUID('TestTableKey'), name)


-- SP: Editing the procedures in order to enable encryption of the passwords
--	Parameters:
--		@UserID -> id of the user which needs to be authorized in the system
--		@password -> password to be encrypted in the system
--		@mail nvarchar(255) -> email of the new user
CREATE OR ALTER PROCEDURE sp_createUser(
	@UserID int,
	@password varchar(30),
	@mail nvarchar(255)
)
as
begin try
	if not exists (select 1 from UserTable c where c.UserID = @CustomerID)
		RAISERROR('Customer does not exist in table',16,1);	

	begin tran
		open symmetric key PasswordKey
		decryption by certificate EncryptionPassCert
		insert into UserData(CustomerID, PasswordHash, Email)
		values(@CustomerID,	ENCRYPTBYKEY(KEY_GUID('PasswordKey'), @password), @mail)
	commit tran
		
end try
begin catch
	rollback transaction
	print ERROR_MESSAGE()
	insert into Errors(Username, Message, Number, Date)
	values (SUSER_ID(), ERROR_MESSAGE(),  ERROR_NUMBER(), getdate())
end catch