ALTER DATABASE WWIGlobal SET RECOVERY FULL

--In terms of backup devices our database will store back-ups 

--Every week. Usually on non-business days
BACKUP DATABASE [WWIGlobal] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\WWIGlobal.bak' WITH NOFORMAT, NOINIT,  NAME = N'WWIGlobal-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

--Every day
BACKUP DATABASE [WWIGlobal] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\WWIGlobal.bak' WITH  DIFFERENTIAL , NOFORMAT, NOINIT,  NAME = N'WWIGlobal-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

--Every hour
BACKUP LOG [WWIGlobal] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\WWIGlobal.bak' WITH NO_TRUNCATE, NOFORMAT, NOINIT,  NAME = N'WWIGlobal-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

Drop table SaleDetails

USE [master]
RESTORE DATABASE [WWIGlobal] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\WWIGlobal.bak' WITH  FILE = 2,  NORECOVERY,  NOUNLOAD,  REPLACE,  STATS = 5
RESTORE DATABASE [WWIGlobal] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\WWIGlobal.bak' WITH  FILE = 4,  NORECOVERY,  NOUNLOAD,  STATS = 5
RESTORE LOG [WWIGlobal] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\WWIGlobal.bak' WITH  FILE = 5,  NOUNLOAD,  STATS = 5

GO