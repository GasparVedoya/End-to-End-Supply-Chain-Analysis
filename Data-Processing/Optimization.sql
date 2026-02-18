-- Create Parent Tables

CREATE TABLE Vendors (
VendorNumber INTEGER PRIMARY KEY,
VendorName TEXT);

CREATE TABLE Brands (
Brand INTEGER PRIMARY KEY,
Description TEXT,
Size TEXT);

CREATE TABLE Stores (
Store INTEGER PRIMARY KEY,
City TEXT);

CREATE TABLE Inventory (
    InventoryId TEXT PRIMARY KEY,
    Brand INTEGER,
    Size TEXT,
    Description TEXT,
	FOREIGN KEY (Brand) REFERENCES Brands (Brand)
	);
	
CREATE TABLE "VendorInvoicesDec" (
	"VendorNumber"	INTEGER,
	"VendorName"	TEXT,
	"InvoiceDate"	TEXT,
	"PONumber"	INTEGER PRIMARY KEY,
	"PODate"	TEXT,
	"PayDate"	TEXT,
	"Quantity"	INTEGER,
	"Dollars"	REAL,
	"Freight"	REAL,
	"Approval"	TEXT,
FOREIGN KEY (VendorNumber) REFERENCES Vendors (VendorNumber)
);

-- Insert Values to Parent Tables
INSERT OR IGNORE INTO Vendors (VendorNumber, VendorName)
SELECT VendorNumber, VendorName FROM 2017PurchasePricesDec
UNION
SELECT VendorNumber, VendorName FROM InvoicePurchases12312016
UNION
SELECT VendorNumber, VendorName FROM PurchasesFINAL12312016
UNION 
SELECT VendorNo, VendorName FROM SalesFINAL12312016;

INSERT OR IGNORE INTO Brands (Brand, Description, Size)
SELECT Brand, Description, Size FROM BegInvFINAL12312016
UNION
SELECT Brand, Description, Size FROM EndInvFINAL12312016
UNION
SELECT Brand, Description, Size FROM PurchasesFINAL12312016
UNION
SELECT Brand, Description, Size FROM SalesFINAL12312016;

INSERT OR IGNORE INTO Stores (Store, City)
SELECT Store, coalesce (City, 'Unknown') FROM BegInvFINAL12312016
UNION
SELECT Store, coalesce (City, 'Unknown') FROM EndInvFINAL12312016
UNION
SELECT Store, 'Unknown' FROM PurchasesFINAL12312016
UNION
Select Store, 'Unknown' FROM SalesFINAL12312016;

INSERT OR IGNORE INTO Inventory (InventoryId, Brand, Size, Description)
SELECT InventoryId, Brand, Size, Description FROM BegInvFINAL12312016
UNION
SELECT InventoryId, Brand, Size, Description FROM EndInvFINAL12312016
UNION
SELECT InventoryId, Brand, Size, Description FROM SalesFINAL12312016
UNION
SELECT InventoryId, Brand, Size, Description FROM PurchasesFINAL12312016;

INSERT INTO VendorInvoicesDec
SELECT * FROM InvoicePurchases12312016;


-- Create Child Tables

CREATE TABLE "PricingPurchasesDec" (
	"Brand"	INTEGER,
	"Description"	TEXT,
	"Price"	REAL,
	"Size"	TEXT,
	"Volume"	INTEGER,
	"Classification"	INTEGER,
	"PurchasePrice"	REAL,
	"VendorNumber"	INTEGER,
	"VendorName"	TEXT,
FOREIGN KEY (Brand) REFERENCES Brands (Brand)
FOREIGN KEY (VendorNumber) REFERENCES Vendors (VendorNumber)
);

CREATE TABLE "BegInvDec" (
	"InventoryId"	TEXT,
	"Store"	INTEGER,
	"City"	TEXT,
	"Brand"	INTEGER,
	"Description"	TEXT,
	"Size"	TEXT,
	"onHand"	INTEGER,
	"Price"	REAL,
	"startDate"	TEXT,
FOREIGN KEY (Store) REFERENCES Stores (Store)
FOREIGN KEY (Brand) REFERENCES Brands (Brand)
FOREIGN KEY (InventoryId) REFERENCES Inventory (InventoryId)
);

CREATE TABLE "EndInvDec" (
	"InventoryId"	TEXT,
	"Store"	INTEGER,
	"City"	TEXT,
	"Brand"	INTEGER,
	"Description"	TEXT,
	"Size"	TEXT,
	"onHand"	INTEGER,
	"Price"	REAL,
	"endDate"	TEXT,
FOREIGN KEY (Store) REFERENCES Stores (Store)
FOREIGN KEY (Brand) REFERENCES Brands (Brand)
FOREIGN KEY (InventoryId) REFERENCES Inventory (InventoryId)
);

CREATE TABLE "PurchasesDec" (
	"InventoryId"	TEXT,
	"Store"	INTEGER,
	"Brand"	INTEGER,
	"Description"	TEXT,
	"Size"	TEXT,
	"VendorNumber"	INTEGER,
	"VendorName"	TEXT,
	"PONumber"	INTEGER,
	"PODate"	TEXT,
	"ReceivingDate"	TEXT,
	"InvoiceDate"	TEXT,
	"PayDate"	TEXT,
	"PurchasePrice"	REAL,
	"Quantity"	INTEGER,
	"Dollars"	REAL,
	"Classification"	INTEGER,
FOREIGN KEY (Store) REFERENCES Stores (Store)
FOREIGN KEY (Brand) REFERENCES Brands (Brand)
FOREIGN KEY (PONumber) REFERENCES VendorInvoicesDecNew (PONumber)
FOREIGN KEY (VendorNumber) REFERENCES Vendors (VendorNumber)
FOREIGN KEY (InventoryId) REFERENCES Inventory (InventoryId)
);

CREATE TABLE "SalesDec" (
	"InventoryId"	TEXT,
	"Store"	INTEGER,
	"Brand"	INTEGER,
	"Description"	TEXT,
	"Size"	TEXT,
	"SalesQuantity"	INTEGER,
	"SalesDollars"	REAL,
	"SalesPrice"	REAL,
	"SalesDate"	TEXT,
	"Volume"	INTEGER,
	"Classification"	INTEGER,
	"ExciseTax"	REAL,
	"VendorNo"	INTEGER,
	"VendorName"	TEXT,
FOREIGN KEY (Store) REFERENCES Stores (Store)
FOREIGN KEY (Brand) REFERENCES Brands (Brand)
FOREIGN KEY (VendorNo) REFERENCES Vendors (VendorNumber)
FOREIGN KEY (InventoryId) REFERENCES Inventory (InventoryId)
);


-- Insert Values Into Child Tables
INSERT INTO BegInvDec
SELECT * FROM BegInvFINAL12312016;

INSERT INTO EndInvDec
SELECT * FROM EndInvFINAL12312016;

INSERT INTO PricingPurchasesDec
SELECT * FROM 2017PurchasePricesDec; 

INSERT INTO PurchasesDec
SELECT * FROM PurchasesFINAL12312016;

INSERT INTO SalesDec
SELECT * FROM SalesFINAL12312016;




-- Drop Old Tables
DROP TABLE 2017PurchasePricesDec;
DROP TABLE SalesFINAL12312016;
DROP TABLE BegInvFINAL12312016;
DROP TABLE EndInvFINAL12312016;
DROP TABLE PurchasesFINAL12312016;
DROP TABLE InvoicePurchases12312016;

-- DROP Extra Info. Columns
ALTER TABLE BegInvDec DROP COLUMN Description;
ALTER TABLE BegInvDec DROP COLUMN Size;
ALTER TABLE EndInvDec DROP COLUMN Description;
ALTER TABLE EndInvDec DROP COLUMN Size;
ALTER TABLE PricingPurchasesDec DROP COLUMN Description;
ALTER TABLE PricingPurchasesDec DROP COLUMN Size; 
ALTER TABLE PricingPurchasesDec DROP COLUMN VendorName;
ALTER TABLE PurchasesDec DROP COLUMN Description;
ALTER TABLE PurchasesDec DROP COLUMN Size;
ALTER TABLE PurchasesDec DROP COLUMN VendorName;
ALTER TABLE PurchasesDec DROP COLUMN PODate;
ALTER TABLE PurchasesDec DROP COLUMN InvoiceDate;
ALTER TABLE PurchasesDec DROP COLUMN PayDate;
ALTER TABLE SalesDec DROP COLUMN Description;
ALTER TABLE SalesDec DROP COLUMN Size;
ALTER TABLE SalesDec DROP COLUMN VendorName;


-- Indexes
CREATE INDEX indx_PONumber ON PurchasesDec (PONumber);
CREATE INDEX indx_VendorNumber ON PurchasesDec (VendorNumber);
CREATE INDEX indx_Brand ON PurchasesDec (Brand);
CREATE INDEX indx_Brand2 ON SalesDec (Brand);
CREATE INDEX indx_VendorNumber2 ON SalesDec (VendorNo);
CREATE INDEX indx_InventoryID ON SalesDec (InventoryId);
CREATE INDEX idx_Sales_SalesDate ON SalesDec (SalesDate);
CREATE INDEX idx_Brand_Description ON Brands (Description);
CREATE INDEX idx_Vendor_VendorName ON Vendors (VendorName);
CREATE INDEX idx_VendorInvoice_Vendor ON VendorInvoicesDec (VendorNumber);
CREATE INDEX idx_VendorInvoice_VendorName ON VendorInvoicesDec (VendorName);
CREATE INDEX idx_VendorInvoice_PO ON VendorInvoicesDec (PONumber);







