DROP schema IF EXISTS dbo CASCADE; 
CREATE SCHEMA IF NOT EXISTS dbo;

DROP TABLE IF EXISTS dbo.Contacts;

CREATE TABLE dbo.Contacts(
	ContactID serial PRIMARY KEY,
	ContactType text NULL,
	CompanyName text NULL,
	ContactName text NULL,
	ContactTitle text NULL,
	Address text NULL,
	City text NULL,
	Region text NULL,
	PostalCode text NULL,
	Country text NULL,
	Phone text NULL,
	Extensions int4 NULL,
	Fax text NULL,
	HomePage text NULL,
	PhotoPath text NULL,
	Photo text NULL
);

CREATE INDEX Contacts_CompanyName_IDX ON dbo.Contacts(CompanyName);

CREATE INDEX Contacts_ContactName_IDX ON dbo.Contacts(ContactName);

CREATE INDEX Contacts_PostalCode_IDX ON dbo.Contacts(PostalCode);

CREATE INDEX Contacts_Address_IDX ON dbo.Contacts(Address);

CREATE INDEX Contacts_Phone_IDX ON dbo.Contacts(Phone);

DROP TABLE IF EXISTS dbo.Employees;

CREATE TABLE dbo.Employees(
	EmployeeID SERIAL PRIMARY KEY,
	LastName text NOT NULL ,
	FirstName text NOT NULL ,
	Title text NULL ,
	TitleOfCourtesy text NULL ,
	BirthDate timestamp NULL ,
	HireDate timestamp NULL ,
	Address text NULL ,
	City text NULL ,
	Region text NULL ,
	PostalCode text NULL ,
	Country text NULL ,
	HomePhone text NULL ,
	Extensions int4 NULL ,
	Photo text NULL ,
	Notes text NULL ,
	ReportsTo int4 NULL ,
	PhotoPath text NULL
);
CREATE  INDEX Employees_LastName_IDX ON dbo.Employees(LastName);

DROP TABLE IF EXISTS dbo.Categories;

CREATE TABLE dbo.Categories (
	CategoryID SERIAL PRIMARY KEY,
	CategoryName text NOT NULL ,
	Description text NULL ,
	Picture text NULL
);

CREATE  INDEX Categories_CategoryName_IDX ON dbo.Categories(CategoryName);

DROP TABLE IF EXISTS dbo.Customers;

CREATE TABLE dbo.Customers (
	CustomerID text PRIMARY KEY,
	CompanyName text NOT NULL ,
	ContactName text NULL ,
	ContactTitle text NULL ,
	Address text NULL ,
	City text NULL ,
	Region text NULL ,
	PostalCode text NULL ,
	Country text NULL ,
	Phone text NULL ,
	Fax text NULL
);

CREATE  INDEX Customers_City_IDX ON dbo.Customers(City);

CREATE  INDEX Customers_CompanyName_IDX ON dbo.Customers(CompanyName);

CREATE  INDEX Customers_PostalCode_IDX ON dbo.Customers(PostalCode);

CREATE  INDEX Customers_Region_IDX ON dbo.Customers(Region);

DROP TABLE IF EXISTS dbo.Shippers;

CREATE TABLE dbo.Shippers (
	ShipperID SERIAL PRIMARY KEY,
	CompanyName text NOT NULL ,
	Phone text NULL
);

DROP TABLE IF EXISTS dbo.Suppliers;

CREATE TABLE dbo.Suppliers (
	SupplierID SERIAL PRIMARY KEY ,
	CompanyName text NOT NULL ,
	ContactName text NULL ,
	ContactTitle text NULL ,
	Address text NULL ,
	City text NULL ,
	Region text NULL ,
	PostalCode text NULL ,
	Country text NULL ,
	Phone text NULL ,
	Fax text NULL ,
	HomePage text NULL
);

CREATE  INDEX Suppliers_CompanyName_IDX ON dbo.Suppliers(CompanyName);

CREATE  INDEX Suppliers_PostalCode_IDX ON dbo.Suppliers(PostalCode);

DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders (
	OrderID int4 PRIMARY KEY,
	CustomerID text NULL ,
	EmployeeID int2 NULL ,
	OrderDate timestamp NULL ,
	RequiredDate timestamp NULL ,
	ShippedDate timestamp NULL ,
	ShipVia int2 NULL ,
	Freight numeric NULL CONSTRAINT "DF_Orders_Freight" DEFAULT (0),
	ShipName text NULL ,
	ShipAddress text NULL ,
	ShipCity text NULL ,
	ShipRegion text NULL ,
	ShipPostalCode text NULL ,
	ShipCountry text NULL ,
	FOREIGN KEY (CustomerID) REFERENCES dbo.Customers (CustomerID),
	FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees (EmployeeID),
	FOREIGN KEY (ShipVia) REFERENCES dbo.Shippers (ShipperID)
);

CREATE  INDEX Orders_CustomerID_IDX ON dbo.Orders(CustomerID);

 CREATE  INDEX Orders_CustomersOrders_IDX ON dbo.Orders(CustomerID);

 CREATE  INDEX Orders_EmployeeID_IDX ON dbo.Orders(EmployeeID);

 CREATE  INDEX Orders_EmployeesOrders_IDX ON dbo.Orders(EmployeeID);

 CREATE  INDEX Orders_OrderDate_IDX ON dbo.Orders(OrderDate);

 CREATE  INDEX Orders_ShippedDate_IDX ON dbo.Orders(ShippedDate);

 CREATE  INDEX Orders_ShippersOrders_IDX ON dbo.Orders(ShipVia);

 CREATE  INDEX Orders_ShipPostalCode_IDX ON dbo.Orders(ShipPostalCode);

DROP TABLE IF EXISTS dbo.Products;

CREATE TABLE dbo.Products (
	ProductID SERIAL PRIMARY KEY,
	ProductName text NOT NULL ,
	SupplierID int2 NULL ,
	CategoryID int2 NULL ,
	QuantityPerUnit text NULL ,
	UnitPrice numeric NULL CONSTRAINT DF_Products_UnitPrice DEFAULT (0),
	UnitsInStock int2 NULL CONSTRAINT DF_Products_UnitsInStock DEFAULT (0),
	UnitsOnOrder int2 NULL CONSTRAINT DF_Products_UnitsOnOrder DEFAULT (0),
	ReorderLevel int2 NULL CONSTRAINT DF_Products_ReorderLevel DEFAULT (0),
	Discontinued int2 NOT NULL CONSTRAINT DF_Products_Discontinued DEFAULT (0),
	FOREIGN KEY (CategoryID) REFERENCES dbo.Categories (CategoryID),
	FOREIGN KEY (SupplierID) REFERENCES dbo.Suppliers (SupplierID)
);

CREATE  INDEX Products_CategoriesProducts_IDX ON dbo.Products(CategoryID);

 CREATE  INDEX Products_CategoryID_IDX ON dbo.Products(CategoryID);

 CREATE  INDEX Products_ProductName_IDX ON dbo.Products(ProductName);

 CREATE  INDEX Products_SupplierID_IDX ON dbo.Products(SupplierID);

 CREATE  INDEX Products_SuppliersProducts_IDX ON dbo.Products(SupplierID);

DROP TABLE IF EXISTS dbo.Order_Details;

CREATE TABLE dbo.Order_Details (
	OrderID int4 NOT NULL ,
	ProductID int4 NOT NULL ,
	UnitPrice numeric NOT NULL CONSTRAINT DF_Order_Details_UnitPrice DEFAULT (0),
	Quantity int2 NOT NULL CONSTRAINT DF_Order_Details_Quantity DEFAULT (1),
	Discount numeric NOT NULL CONSTRAINT DF_Order_Details_Discount DEFAULT (0),
	PRIMARY KEY  (OrderID, ProductID),
	FOREIGN KEY (OrderID) REFERENCES dbo.Orders (OrderID),
	FOREIGN KEY (ProductID) REFERENCES dbo.Products (ProductID)
);

CREATE  INDEX Order_Details_OrderID_IDX ON dbo.Order_Details(OrderID);

CREATE  INDEX Order_Details_ProductID_IDX ON dbo.Order_Details(ProductID);

CREATE  INDEX Order_Details_ProductsOrder_Details_IDX ON dbo.Order_Details(ProductID);

DROP TABLE IF EXISTS dbo.Region;

CREATE TABLE dbo.Region (
	RegionID SERIAL PRIMARY KEY,
	RegionDescription text NOT NULL
);

DROP TABLE IF EXISTS dbo.Territories;

CREATE TABLE dbo.Territories (
	TerritoryID text PRIMARY KEY,
	TerritoryDescription text NOT NULL,
	RegionID int2 NOT NULL,
	FOREIGN KEY (RegionID) REFERENCES dbo.Region (RegionID)
);

CREATE INDEX Territories_RegionID_IDX ON dbo.Territories(RegionID);

DROP TABLE IF EXISTS dbo.CustomerDemographics;

CREATE TABLE dbo.CustomerDemographics (
	CustomerTypeID text PRIMARY KEY,
	CustomerDesc text NULL
);

DROP TABLE IF EXISTS dbo.CustomerCustomerDemo;

CREATE TABLE dbo.CustomerCustomerDemo (
	CustomerID text NOT NULL,
	CustomerTypeID text NOT NULL,
	FOREIGN KEY (CustomerID) REFERENCES dbo.Customers (CustomerID),
	FOREIGN KEY (CustomerTypeID) REFERENCES dbo.CustomerDemographics (CustomerTypeID)
);

DROP TABLE IF EXISTS dbo.EmployeeTerritories;

CREATE TABLE dbo.EmployeeTerritories (
	EmployeeID int2 NOT NULL,
	TerritoryID text NOT NULL ,
	FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees (EmployeeID),
	FOREIGN KEY (TerritoryID) REFERENCES dbo.Territories (TerritoryID)
);
