use master;
go

-- sales header, sales destails, stockitem, promotion and everything that has to do with customers

DROP DATABASE IF EXISTS WWIGlobal

Create DATABASE WWIGlobal
ON
PRIMARY
(name = WWI_Sales,
FILENAME = 'C:\WWIGlobal\Sales\sales.mdf', -- Write files
SIZE = 20,
MAXSIZE = 50,
FILEGROWTH = 5)
log on
(name = WWI_Log,
filename = 'C:\WWIGlobal\Log\log.ndf',
size = 100,
maxsize = 200,
filegrowth = 10)

ALTER DATABASE WWIGlobal
ADD FileGroup WWI_Data; -- Read Only 

ALTER DATABASE WWIGlobal
ADD File	
(name = WW_data,
FILENAME  = 'C:\WWIGlobal\Data\data.df',
SIZE = 4,
maxsize = 30,
filegrowth = 20)
to filegroup WWI_Data;
go



use WWIGlobal;
go


--schema creation

create schema salesMgt authorization [dbo];
go

create schema readData authorization [dbo];
go

create schema customer authorization [dbo];
go

create schema stock authorization [dbo];
go

create schema auth authorization [dbo];
go



DROP TABLE IF EXISTS salesMgt.SaleDetails 
DROP TABLE IF EXISTS salesMgt.SaleHeader
DROP TABLE IF EXISTS stock.StockItem 
DROP TABLE IF EXISTS stock.Promotion 
DROP TABLE IF EXISTS salesMgt.Employee 
DROP TABLE IF EXISTS auth.PasswordResetToken
DROP TABLE IF EXISTS auth.UserData
DROP TABLE IF EXISTS auth.UserTable
DROP TABLE IF EXISTS customer.Customer
DROP TABLE IF EXISTS readData.Package
DROP TABLE IF EXISTS readData.Color
DROP TABLE IF EXISTS customer.CustomerCategory
DROP TABLE IF EXISTS customer.BuyingGroup
DROP TABLE IF EXISTS readData.Location
DROP TABLE IF EXISTS readData.SalesTerritory
DROP TABLE IF EXISTS readData.Continent
DROP TABLE IF EXISTS readData.Country
DROP TABLE IF EXISTS readData.City
DROP TABLE IF EXISTS readData.State
DROP TABLE IF EXISTS readData.Size
DROP TABLE IF EXISTS readData.TaxRate
DROP TABLE IF EXISTS auth.SpaceUsed
DROP TABLE IF EXISTS auth.TablesInfo
DROP TABLE IF EXISTS auth.ConstraintsInfo
DROP TABLE IF EXISTS auth.Errors



CREATE TABLE readData.State(
	StateID int identity not null,
	Code nvarchar(10) not null,
	Name nvarchar(60) not null,
	primary key(StateID)
)on WWI_Data

CREATE TABLE readData.Country(
	CountryID int identity not null,
	Name nvarchar(60) not null,
	primary key(CountryID)
)on WWI_Data

CREATE TABLE readData.Continent(
	ContinentID int identity not null,
	Name nvarchar(30) not null,
	primary key(ContinentID)
)on WWI_Data

CREATE TABLE readData.SalesTerritory(
	SalesTerritoryID int identity not null,
	Name nvarchar(50) not null,
	primary key(SalesTerritoryID)
)on WWI_Data

CREATE TABLE readData.City(
	CityID int identity not null,
	StateID int not null,
	CountryID int not null,
	ContinentID int not null,
	SalesTerritoryID int not null,
	Name nvarchar(50) not null,
	LastRecordedPopulation bigint not null,
	primary key(CityID),
	constraint FK_CIty_Country foreign key(CountryID) references readData.Country(CountryID) ON DELETE CASCADE,
	constraint FK_City_Continent foreign key(ContinentID) references readData.Continent(ContinentID) ON DELETE CASCADE,
	constraint FK_City_SalesTerritory foreign key(SalesTerritoryID) references readData.SalesTerritory(SalesTerritoryID) ON DELETE CASCADE ,
	constraint FK_City_State foreign key(StateID) references readData.State(StateID) ON DELETE CASCADE
)on WWI_Data

CREATE TABLE readData.Location(
	LocationID int identity not null,
	CityID int not null,
	PostalCode nvarchar(10) not null,
	primary key(LocationID),
	constraint FK_Location_City foreign key(CityID) references readData.City(CityID) ON DELETE CASCADE
)on WWI_Data

CREATE TABLE customer.BuyingGroup(
	BuyingGroupID int identity not null,
	Name nvarchar(50) not null,
	BillToCustomer nvarchar(100) not null,
	primary key(BuyingGroupID)
)on WWI_Data

CREATE TABLE customer.CustomerCategory(
	CustomerCategoryID int identity not null,
	Name nvarchar(50) not null,
	primary key(CustomerCategoryID)
)on WWI_Data

CREATE TABLE readData.Color(
	ColorID int identity not null,
	Name nvarchar(20) not null,
	primary key(ColorID)
)on WWI_Data

CREATE TABLE readData.Package(
	PackageID int identity not null,
	Name nvarchar(50) not null,
	primary key(PackageID)
)on WWI_Data

CREATE TABLE readData.Size(
	SizeID int identity not null,
	Name nvarchar(20) not null,
	primary key(SizeID)
)on WWI_Data


CREATE TABLE readData.TaxRate(
	TaxRateID int identity not null,
	TaxRate decimal(18,2) not null,
	primary key(TaxRateID)
)on WWI_Data


CREATE TABLE auth.UserTable(
	UserID int identity not null primary key,
	PrimaryContact nvarchar(50) not null
)

CREATE TABLE auth.UserData(
	UserDataID int identity not null,
	UserID int not null,
	PasswordHash varbinary(64) not null,
	Email nvarchar(255) not null,
	primary key(UserDataID),
	constraint FK_Customer_UserData foreign key(UserID) references auth.UserTable(UserID) ON DELETE CASCADE
)

CREATE TABLE auth.PasswordResetToken(
	UserDataID int not null,    
    Token varchar(128) not null unique,
	ExpDate date not null,
    primary key (UserDataID, Token),
	constraint FK_PasswordResetToken_UserData foreign key(UserDataID) references auth.UserData(UserDataID) ON DELETE CASCADE
)


CREATE TABLE customer.Customer(
	CustomerID int not null primary key references auth.UserTable(UserID),
	CategotyID int not null,
	BuyingGroupID int not null,
	LocationID int not null,
	constraint FK_Customer_Location foreign key(LocationID) references readData.Location(LocationID)  ON DELETE CASCADE,
	constraint FK_Customer_Category foreign key(CategotyID) references customer.CustomerCategory(CustomerCategoryID) ON DELETE CASCADE,
	constraint FK_Customer_BuyingGroup foreign key(BuyingGroupID) references customer.BuyingGroup(BuyingGroupID) ON DELETE CASCADE
)

CREATE TABLE salesMgt.Employee(
	EmployeeID int not null primary key references auth.UserTable(UserID),
	Photo varbinary(max)
)

CREATE TABLE stock.Promotion(
	PromotionID int identity,
	Discount decimal(18,3) not null,
	StartDate date not null,
	EndDate date not null,
	primary key(PromotionID)
)

CREATE TABLE stock.StockItem(
	StockItemID int identity not null,
	Name nvarchar(100) not null,
	ColorID int not null,
	Brand nvarchar(50) not null,
	SellingPackageID int not null,
	BuyingPackageID int not null,
	LeadTimeDays int not null,
	QuantityPerOuter int not null,
	IsChillerStock bit not null,
	Barcode nvarchar(50) null,
	TaxRateID int not null,
	UnitPrice decimal(18,3) not null,
	RecommendedRetailPrice decimal(18,2) null,
	TypicalWeightPerUnit decimal(18,3) not null,
	SizeID int not null,
	PromotionID int,
	primary key(StockItemID),
	constraint FK_StockItem_Color foreign key(ColorID) references readData.Color(ColorID)  ON DELETE CASCADE,
	constraint FK_StockItem_Size foreign key(SizeID) references readData.Size(SizeID) ON DELETE CASCADE,
	constraint FK_StockItem_TaxRate foreign key(TaxRateID) references readData.TaxRate(TaxRateID) ON DELETE CASCADE,
	constraint FK_StockItem_SellingPackage foreign key(SellingPackageID) references readData.Package(PackageID) ON DELETE CASCADE,
	constraint FK_StockItem_BuyingPackage foreign key(BuyingPackageID) references readData.Package(PackageID),
	constraint FK_StockItem_Promotion foreign key(PromotionID) references stock.Promotion(PromotionID) ON DELETE CASCADE
)

CREATE TABLE salesMgt.SaleHeader(
	SaleHeaderID int identity not null,
	SalesPersonID int not null,
	CityID int not null,
	InvoiceDateKey date not null,
	DeliveryDateKey date,
	Profit decimal(18,2) not null,
	primary key(SaleHeaderID),
	constraint FK_SaleHeader_Employee foreign key(SalesPersonID) references salesMgt.Employee(EmployeeID) ON DELETE CASCADE,
	constraint FK_SaleHeader_City foreign key(CityID) references readData.City(CityID) ON DELETE CASCADE
)

CREATE TABLE salesMgt.SaleDetails (
	SaleDetailsID int identity not null,
	SaleHeaderID int not null,
	CustomerID int not null,
	Quantity int not null,
	StockItemID int not null,
	TaxRateId int not null,
	primary key(SaleDetailsID),
	constraint FK_SaleHeader_TaxRate foreign key(TaxRateID) references readData.TaxRate(TaxRateID) ON DELETE CASCADE,
	constraint FK_SaleDetails_Customer foreign key(CustomerID) references customer.Customer(CustomerID) ON DELETE CASCADE,
	constraint FK_SaleDetails_SaleHeader foreign key(SaleHeaderID) references salesMgt.SaleHeader(SaleHeaderID),
	constraint FK_SaleDetails_StockItem foreign key(StockItemID) references stock.StockItem(StockItemID)
)
CREATE TABLE auth.TablesInfo(
	column_name sysname not null,
	table_name sysname not null,
	data_type sysname not null,
	max_length smallint not null,
	is_nullable bit null,
	primary_key bit null,
	update_date datetime not null constraint update_date DEFAULT (getdate())
)

CREATE TABLE auth.ConstraintsInfo(
	NameofConstraint nvarchar(128) not null,
	SchemaName nvarchar(128) not null,
	TableName nvarchar(128) not null,
	ConstraintType nvarchar(128) null,
	update_date_constraint datetime not null constraint update_date_constraint DEFAULT (getdate())
)

CREATE TABLE auth.SpaceUsed(
		TableName nvarchar(128),
		Rows char(20),
		ReservedSpace varchar(18),
		Data varchar(18),
		IndexSize varchar(18),
		UnusedSpace	varchar(18),
		updateDate datetime not null constraint updateDate DEFAULT (getdate())
)

CREATE TABLE auth.Errors(
	ErrorID int identity not null,
	Message nvarchar(100) null,
	Username nvarchar(100) not null,
	Number int not null,
	Date DATETIME not null
)


