/**Script for AWS database  creation **/
drop database if exists aws_northwind;
CREATE database aws_northwind;
USE aws_northwind;

CREATE TABLE DimDate (
  CurrentDate date NOT NULL,
  EuropeanDate CHAR(20),
  AmericanDate CHAR(20),
  NumberDay TINYINT,
  NumberDayOfWeek TINYINT, 
  TitleOfDay VARCHAR(15),    
  NumberDayOfYear SMALLINT,
  NumberWeekInYear TINYINT,
  NumberWeekInMonth TINYINT,
  NumberMonth TINYINT,
  NameMonth VARCHAR(15),
  NumberQuarter TINYINT,
  CurrentYear SMALLINT,
  
  CONSTRAINT PK_SK_CTD PRIMARY KEY(CurrentDate)
  );
  
  
CREATE TABLE DimProduct(
	SKProduct int AUTO_INCREMENT NOT NULL,
    ProductID int NOT NULL,
	ProductName varchar(40) NOT NULL,
	QuantityPerUnit varchar(20) NULL,
	UnitPrice decimal(6,2) NULL,
	ReorderLevel smallint NULL,
    CategoryName varchar(15) NOT NULL,
    CategoryDescription text NULL,
    DateFrom datetime NOT NULL,
    DateTo datetime NULL,
    
	CONSTRAINT PK_SK_PRD PRIMARY KEY(SKProduct)
    );
    
CREATE TABLE DimShipper(
    SKShipper int AUTO_INCREMENT NOT NULL,
    ShipperID int NOT NULL,
	CompanyName varchar(40) NOT NULL,
	Phone varchar(24) NULL,
    DateFrom datetime NOT NULL,
    DateTo datetime NULL,
    CONSTRAINT PK_SK_SHP PRIMARY KEY(SKShipper)
    );
    
CREATE TABLE DimSupplier(
    SKSupplier int AUTO_INCREMENT NOT NULL,
	SupplierID int NOT NULL,
	CompanyName varchar(40) NOT NULL,
	ContactName varchar(30) NULL,
	ContactTitle varchar(30) NULL,
	Address varchar(60) NULL,
	City varchar(15) NULL,
	Region varchar(15) NULL,
	Country varchar(15) NULL,
    DateFrom datetime NOT NULL,
    DateTo datetime NULL,
    
    CONSTRAINT PK_SK_PRD PRIMARY KEY(SKSupplier)
);

CREATE TABLE DimCustomer(
    SKCustomer int AUTO_INCREMENT NOT NULL,
    CustomerID char(5) NOT NULL,
	CompanyName varchar(40) NOT NULL,
	ContactName varchar(30) NULL,
	ContactTitle varchar(30) NULL,
	Address varchar(60) NULL,
	City varchar(15) NULL,
	Region varchar(15) NULL,
	Country varchar(15) NULL,
	DateFrom datetime NOT NULL,
    DateTo datetime NULL,
    
    CONSTRAINT PK_SK_CST PRIMARY KEY(SKCustomer)
);

CREATE TABLE DimEmployee(
    EmployeeID int NOT NULL,
	LastName varchar(20) NOT NULL,
	FirstName varchar(10) NOT NULL,
	Title varchar(30) NULL,
	TitleOfCourtesy varchar(25) NULL,
	Address varchar(60) NULL,
	City varchar(15) NULL,
	Region varchar(15) NULL,
	Country varchar(15) NULL,
	Extensions varchar(4) NULL,

    
    CONSTRAINT PK_EMP_ID PRIMARY KEY(EmployeeID)
    );
    
    
CREATE TABLE FactOrder(
    OrderID int NOT NULL,
    SKCustomer int NOT NULL,
    SKSupplier int NOT NULL,
    SKShipper int not NULL,
    SKProduct int NOT NULL,
	EmployeeID int not NULL,
    OrderDate date NOT NULL,
    RequiredDate date NOT NULL,
    ShippedDate date NULL,
    Freight decimal(8,2) NULL ,
    ShipName varchar(40) NULL,
    ShipAddress varchar(60) NULL,
    ShipCity varchar(15) NULL,
    ShipRegion varchar(15) NULL,
    ShipCountry varchar(15) NULL,
    ActualPrice decimal(8,2) NULL,
    Quantity smallint NOT NULL,
    Discount real NOT NULL,
    
    CONSTRAINT PK_ORD_ID PRIMARY KEY(OrderID,SKCustomer,SKSupplier,SKShipper,SKProduct,EmployeeID,OrderDate,RequiredDate),
    CONSTRAINT FK_CST_ID FOREIGN KEY(SKCustomer) REFERENCES DimCustomer(SKCustomer),
    CONSTRAINT FK_SUP_ID FOREIGN KEY(SKSupplier) REFERENCES DimSupplier(SKSupplier),
    CONSTRAINT FK_SHP_ID FOREIGN KEY(SKShipper) REFERENCES DimShipper(SKShipper),
    CONSTRAINT FK_PRD_ID FOREIGN KEY(SKProduct) REFERENCES DimProduct(SKProduct),
    CONSTRAINT FK_EMP_ID FOREIGN KEY(EmployeeID) REFERENCES DimEmployee(EmployeeID),
    CONSTRAINT FK_ORT_ID FOREIGN KEY(OrderDate) REFERENCES DimDate(CurrentDate),
    CONSTRAINT FK_REQ_ID FOREIGN KEY(RequiredDate) REFERENCES DimDate(CurrentDate),
    CONSTRAINT FK_SHD_ID FOREIGN KEY(ShippedDate) REFERENCES DimDate(CurrentDate)
    );


SET @first_date = '1970-01-01';
SET @last_date = '2050-12-31';
SET SESSION cte_max_recursion_depth = ABS(DATEDIFF(CONVERT(@last_date, DATE), CONVERT(@first_date, DATE))) + 1000;
INSERT INTO DimDate

WITH RECURSIVE date_dim(now_date) AS  
	(
	SELECT
		@first_date AS now_date
	UNION ALL
	SELECT
		DATE_ADD(now_date,INTERVAL 1 DAY)
	FROM
		date_dim
	WHERE
		now_date < @last_date
	)
    
    SELECT
    now_date AS CurrentDate,
	DATE_FORMAT(now_date,"%D,%M,%Y") AS EuropeanDate,
	DATE_FORMAT(now_date,"%M,%D,%Y") AS AmericanDate,
    DAY(now_date) AS NumberDay,
	WEEKDAY(now_date) AS NumberDayOfWeek,
    DAYNAME(now_date) AS TitleOfDay,
    DAYOFYEAR(now_date) AS NumberDayOfYear,
    WEEK(now_date) AS NumberWeekInYear,
    WEEK(now_date,5) - WEEK(DATE_SUB(now_date, INTERVAL DAYOFMONTH(now_date) - 1 DAY), 5) + 1 as NumberWeekInMonth,
    MONTH(now_date) AS NumberMonth,
    MONTHNAME(now_date) AS NameMonth,
    QUARTER(now_date) AS NumberQuarter,   																					
    YEAR(now_date) AS CurrentYear
    
FROM
	date_dim;


