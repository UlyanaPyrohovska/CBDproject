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
maxsize = 8,
filegrowth = 2)
to filegroup WWI_Data;
go



use WWIGlobal;
go

DROP TABLE IF EXISTS SaleDetails 
DROP TABLE IF EXISTS SaleHeader
DROP TABLE IF EXISTS StockItem 
DROP TABLE IF EXISTS Promotion 
DROP TABLE IF EXISTS Employee 
DROP TABLE IF EXISTS PasswordResetToken
DROP TABLE IF EXISTS UserData
DROP TABLE IF EXISTS Customer
DROP TABLE IF EXISTS Package
DROP TABLE IF EXISTS Color
DROP TABLE IF EXISTS CustomerCategory
DROP TABLE IF EXISTS BuyingGroup
DROP TABLE IF EXISTS Location
DROP TABLE IF EXISTS SalesTerritory
DROP TABLE IF EXISTS Continent
DROP TABLE IF EXISTS Country
DROP TABLE IF EXISTS City
DROP TABLE IF EXISTS State
DROP TABLE IF EXISTS Size
DROP TABLE IF EXISTS TaxRate
DROP TABLE IF EXISTS SpaceUsed
DROP TABLE IF EXISTS TablesInfo
DROP TABLE IF EXISTS ConstraintsInfo





CREATE TABLE State(
	StateID int identity not null,
	Code nvarchar(10) not null,
	Name nvarchar(60) not null,
	primary key(StateID)
)on WWI_Data

CREATE TABLE Country(
	CountryID int identity not null,
	Name nvarchar(60) not null,
	primary key(CountryID)
)on WWI_Data

CREATE TABLE Continent(
	ContinentID int identity not null,
	Name nvarchar(30) not null,
	primary key(ContinentID)
)on WWI_Data

CREATE TABLE SalesTerritory(
	SalesTerritoryID int identity not null,
	Name nvarchar(50) not null,
	primary key(SalesTerritoryID)
)on WWI_Data

CREATE TABLE City(
	CityID int identity not null,
	StateID int not null,
	CountryID int not null,
	ContinentID int not null,
	SalesTerritoryID int not null,
	Name nvarchar(50) not null,
	LastRecordedPopulation bigint not null,
	primary key(CityID),
	constraint FK_CIty_Country foreign key(CountryID) references Country(CountryID) ON DELETE CASCADE,
	constraint FK_City_Continent foreign key(ContinentID) references Continent(ContinentID) ON DELETE CASCADE,
	constraint FK_City_SalesTerritory foreign key(SalesTerritoryID) references SalesTerritory(SalesTerritoryID) ON DELETE CASCADE ,
	constraint FK_City_State foreign key(StateID) references State(StateID) ON DELETE CASCADE
)on WWI_Data

CREATE TABLE Location(
	LocationID int identity not null,
	CityID int not null,
	PostalCode nvarchar(10) not null,
	primary key(LocationID),
	constraint FK_Location_City foreign key(CityID) references City(CityID) ON DELETE CASCADE
)on WWI_Data

CREATE TABLE BuyingGroup(
	BuyingGroupID int identity not null,
	Name nvarchar(50) not null,
	BillToCustomer nvarchar(100) not null,
	primary key(BuyingGroupID)
)on WWI_Data

CREATE TABLE CustomerCategory(
	CustomerCategoryID int identity not null,
	Name nvarchar(50) not null,
	primary key(CustomerCategoryID)
)on WWI_Data

CREATE TABLE Color(
	ColorID int identity not null,
	Name nvarchar(20) not null,
	primary key(ColorID)
)on WWI_Data

CREATE TABLE Package(
	PackageID int identity not null,
	Name nvarchar(50) not null,
	primary key(PackageID)
)on WWI_Data

CREATE TABLE Size(
	SizeID int identity not null,
	Name nvarchar(20) not null,
	primary key(SizeID)
)on WWI_Data

CREATE TABLE TaxRate(
	TaxRateID int identity not null,
	TaxRate decimal(18,2) not null,
	primary key(TaxRateID)
)on WWI_Data


CREATE TABLE UserTable(
	UserID int identity not null primary key,
	PrimaryContact nvarchar(50) not null
)

CREATE TABLE UserData(
	UserDataID int identity not null,
	UserID int not null,
	PasswordHash varbinary(64) not null,
	Email nvarchar(255) not null,
	primary key(UserDataID),
	constraint FK_Customer_UserData foreign key(UserID) references UserTable(UserID) ON DELETE CASCADE
)

CREATE TABLE PasswordResetToken(
	UserDataID int not null,    
    Token varchar(128) not null unique,
	ExpDate date not null,
    primary key (UserDataID, Token),
	constraint FK_PasswordResetToken_UserData foreign key(UserDataID) references UserData(UserDataID) ON DELETE CASCADE
)


CREATE TABLE Customer(
	CustomerID int not null primary key references UserTable(UserID),
	CategotyID int not null,
	BuyingGroupID int not null,
	LocationID int not null,
	constraint FK_Customer_Location foreign key(LocationID) references Location(LocationID)  ON DELETE CASCADE,
	constraint FK_Customer_Category foreign key(CategotyID) references CustomerCategory(CustomerCategoryID) ON DELETE CASCADE,
	constraint FK_Customer_BuyingGroup foreign key(BuyingGroupID) references BuyingGroup(BuyingGroupID) ON DELETE CASCADE
)

CREATE TABLE Employee(
	EmployeeID int not null primary key references UserTable(UserID),
	Photo varbinary(max)
)

CREATE TABLE Promotion(
	PromotionID int identity,
	Discount decimal(18,3) not null,
	StartDate date not null,
	EndDate date not null,
	primary key(PromotionID)
)

CREATE TABLE StockItem(
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
	constraint FK_StockItem_Color foreign key(ColorID) references Color(ColorID)  ON DELETE CASCADE,
	constraint FK_StockItem_Size foreign key(SizeID) references Size(SizeID) ON DELETE CASCADE,
	constraint FK_StockItem_TaxRate foreign key(TaxRateID) references TaxRate(TaxRateID) ON DELETE CASCADE,
	constraint FK_StockItem_SellingPackage foreign key(SellingPackageID) references Package(PackageID) ON DELETE CASCADE,
	constraint FK_StockItem_BuyingPackage foreign key(BuyingPackageID) references Package(PackageID),
	constraint FK_StockItem_Promotion foreign key(PromotionID) references Promotion(PromotionID) ON DELETE CASCADE
)

CREATE TABLE SaleHeader(
	SaleHeaderID int identity not null,
	SalesPersonID int not null,
	CityID int not null,
	InvoiceDateKey date not null,
	DeliveryDateKey date,
	Profit decimal(18,2) not null,
	primary key(SaleHeaderID),
	constraint FK_SaleHeader_Employee foreign key(SalesPersonID) references Employee(EmployeeID) ON DELETE CASCADE,
	constraint FK_SaleHeader_City foreign key(CityID) references City(CityID) ON DELETE CASCADE
)

CREATE TABLE SaleDetails (
	SaleDetailsID int identity not null,
	SaleHeaderID int not null,
	CustomerID int not null,
	Quantity int not null,
	StockItemID int not null,
	TaxRateId int not null,
	primary key(SaleDetailsID),
	constraint FK_SaleHeader_TaxRate foreign key(TaxRateID) references TaxRate(TaxRateID) ON DELETE CASCADE,
	constraint FK_SaleDetails_Customer foreign key(CustomerID) references Customer(CustomerID) ON DELETE CASCADE,
	constraint FK_SaleDetails_SaleHeader foreign key(SaleHeaderID) references SaleHeader(SaleHeaderID),
	constraint FK_SaleDetails_StockItem foreign key(StockItemID) references StockItem(StockItemID)
)
CREATE TABLE TablesInfo(
	column_name sysname not null,
	table_name sysname not null,
	data_type sysname not null,
	max_length smallint not null,
	is_nullable bit null,
	primary_key bit null,
	update_date datetime not null constraint update_date DEFAULT (getdate())
)

CREATE TABLE ConstraintsInfo(
	NameofConstraint nvarchar(128) not null,
	SchemaName nvarchar(128) not null,
	TableName nvarchar(128) not null,
	ConstraintType nvarchar(128) null,
	update_date_constraint datetime not null constraint update_date_constraint DEFAULT (getdate())
)

CREATE TABLE SpaceUsed(
		TableName nvarchar(128),
		Rows char(20),
		ReservedSpace varchar(18),
		Data varchar(18),
		IndexSize varchar(18),
		UnusedSpace	varchar(18),
		updateDate datetime not null constraint updateDate DEFAULT (getdate())
)

CREATE TABLE Errors(
	ErrorID int identity not null,
	Message nvarchar(100) null,
	Username nvarchar(100) not null,
	Number int not null,
	Date DATETIME not null
)

