
CREATE VIEW Total_Spent_By_Vendor AS 
	SELECT
		VendorNumber,
		Total_Billing,
		CASE NTILE(4) OVER (ORDER BY Total_Billing DESC)
		WHEN 1 THEN 4
		WHEN 2 THEN 3
		WHEN 3 THEN 2
		ELSE 1 
		END AS Vendor_Rank
	FROM (
		SELECT
			VendorNumber,
			SUM(Dollars + Freight) AS Total_Billing
			FROM VendorInvoicesDec
			GROUP BY VendorNumber
);



CREATE VIEW Vendor_Product_Scorecard AS
WITH VendorPurchases AS (
    SELECT
        VI.VendorName,
        B.Brand,
        B.Description,
        SUM(VI.Quantity) AS Total_Items_Bought
    FROM VendorInvoicesDec VI
    JOIN PurchasesDec P
        ON VI.PONumber = P.PONumber
    JOIN Brands B
        ON P.Brand = B.Brand
    GROUP BY
        VI.VendorName,
        B.Brand,
        B.Description
),
BrandTotals AS (
    SELECT
        Brand,
        SUM(Total_Items_Bought) AS Brand_Total_Bought
    FROM VendorPurchases
    GROUP BY Brand
),
BrandSales AS (
    SELECT
        Brand,
        SUM(SalesQuantity) AS Total_Items_Sold
    FROM SalesDec
    GROUP BY Brand
)
SELECT
    VP.VendorName,
    VP.Brand,
    VP.Description,
    VP.Total_Items_Bought,
    (VP.Total_Items_Bought * 1.0 / BT.Brand_Total_Bought)
        * COALESCE(BS.Total_Items_Sold, 0) AS Allocated_Items_Sold,
    VP.Total_Items_Bought
        - (
            (VP.Total_Items_Bought * 1.0 / BT.Brand_Total_Bought)
            * COALESCE(BS.Total_Items_Sold, 0)
          ) AS Difference,
    CASE NTILE(4) OVER (
        ORDER BY
            (
                VP.Total_Items_Bought
                - (
                    (VP.Total_Items_Bought * 1.0 / BT.Brand_Total_Bought)
                    * COALESCE(BS.Total_Items_Sold, 0)
                  )
            ) DESC
    )
        WHEN 1 THEN 1
        WHEN 2 THEN 2
        WHEN 3 THEN 3
        ELSE 4
    END AS Score
FROM VendorPurchases VP
JOIN BrandTotals BT
    ON VP.Brand = BT.Brand
LEFT JOIN BrandSales BS
    ON VP.Brand = BS.Brand;


CREATE VIEW Rank_Valuable_Items AS
SELECT Brand, Value, CASE ntile (4) OVER (ORDER BY Value DESC)
	WHEN 1 THEN 4
	WHEN 2 THEN 3
	WHEN 3 THEN 2
	ELSE 1
END AS Item_Rank
FROM (SELECT Brand, PurchasePrice AS Value
FROM PurchasesDec
GROUP BY Brand
);


CREATE VIEW Vendor_LeadTime_Score AS
SELECT
    VendorName,
    Description,
    AVG_Lead_Time,
    CASE NTILE(4) OVER (ORDER BY AVG_Lead_Time DESC)
        WHEN 1 THEN 1   -- longest lead time (worst)
        WHEN 2 THEN 2
        WHEN 3 THEN 3
        ELSE 4          -- shortest lead time (best)
    END AS LeadTime_Score
FROM (
    SELECT
        VI.VendorName,
        B.Description,
        AVG(
            julianday(P.ReceivingDate)
            - julianday(VI.PODate)
        ) AS AVG_Lead_Time
    FROM VendorInvoicesDec VI
    JOIN PurchasesDec P
        ON VI.PONumber = P.PONumber
    JOIN Brands B
        ON P.Brand = B.Brand
    GROUP BY
        VI.VendorName,
        B.Description
);

CREATE VIEW Vendor_InventoryRisk_Score AS
WITH VendorPurchases AS (
    SELECT
        VI.VendorName,
        B.Brand,
        B.Description,
        SUM(VI.Quantity) AS Total_Items_Bought
    FROM VendorInvoicesDec VI
    JOIN PurchasesDec P
        ON VI.PONumber = P.PONumber
    JOIN Brands B
        ON P.Brand = B.Brand
    GROUP BY
        VI.VendorName,
        B.Brand,
        B.Description
),
BrandTotals AS (
    SELECT
        Brand,
        SUM(Total_Items_Bought) AS Brand_Total_Bought
    FROM VendorPurchases
    GROUP BY Brand
),
BrandSales AS (
    SELECT
        Brand,
        SUM(SalesQuantity) AS Total_Items_Sold
    FROM SalesDec
    GROUP BY Brand
)
SELECT
    VP.VendorName,
    VP.Description,

    VP.Total_Items_Bought,

    -- proportional sales allocation
    (VP.Total_Items_Bought * 1.0 / BT.Brand_Total_Bought)
        * COALESCE(BS.Total_Items_Sold, 0) AS Allocated_Items_Sold,

    -- inventory difference
    VP.Total_Items_Bought
        - (
            (VP.Total_Items_Bought * 1.0 / BT.Brand_Total_Bought)
            * COALESCE(BS.Total_Items_Sold, 0)
          ) AS Inventory_Difference,

    -- inventory risk score
    CASE NTILE(4) OVER (
        ORDER BY
            (
                VP.Total_Items_Bought
                - (
                    (VP.Total_Items_Bought * 1.0 / BT.Brand_Total_Bought)
                    * COALESCE(BS.Total_Items_Sold, 0)
                  )
            ) DESC
    )
        WHEN 1 THEN 1   -- highest inventory risk
        WHEN 2 THEN 2
        WHEN 3 THEN 3
        ELSE 4          -- lowest inventory risk
    END AS InventoryRisk_Score

FROM VendorPurchases VP
JOIN BrandTotals BT
    ON VP.Brand = BT.Brand
LEFT JOIN BrandSales BS
    ON VP.Brand = BS.Brand;

	
	CREATE VIEW Vendor_Velocity_Score AS
WITH VendorPurchases AS (
    SELECT
        VI.VendorName,
        B.Brand,
        B.Description,
        SUM(VI.Quantity) AS Total_Items_Bought
    FROM VendorInvoicesDec VI
    JOIN PurchasesDec P
        ON VI.PONumber = P.PONumber
    JOIN Brands B
        ON P.Brand = B.Brand
    GROUP BY
        VI.VendorName,
        B.Brand,
        B.Description
),

BrandTotals AS (
    SELECT
        Brand,
        SUM(Total_Items_Bought) AS Brand_Total_Bought
    FROM VendorPurchases
    GROUP BY Brand
),

BrandSalesByDay AS (
    SELECT
        Brand,
        DATE(SalesDate) AS Sales_Day,
        SUM(SalesQuantity) AS Daily_Sales
    FROM SalesDec
    GROUP BY
        Brand,
        DATE(SalesDate)
),

BrandVelocity AS (
    SELECT
        Brand,
        SUM(Daily_Sales) * 1.0 / COUNT(*) AS Avg_Daily_Sales
    FROM BrandSalesByDay
    GROUP BY Brand
)

SELECT
    VP.VendorName,
    VP.Description,

    -- allocated velocity
    (VP.Total_Items_Bought * 1.0 / BT.Brand_Total_Bought)
        * COALESCE(BV.Avg_Daily_Sales, 0) AS Allocated_Avg_Daily_Sales,

    -- velocity score (importance)
    CASE NTILE(4) OVER (
        ORDER BY
            (VP.Total_Items_Bought * 1.0 / BT.Brand_Total_Bought)
            * COALESCE(BV.Avg_Daily_Sales, 0) DESC
    )
        WHEN 1 THEN 4   -- fastest movers (most important)
        WHEN 2 THEN 3
        WHEN 3 THEN 2
        ELSE 1          -- slowest movers
    END AS Velocity_Score

FROM VendorPurchases VP
JOIN BrandTotals BT
    ON VP.Brand = BT.Brand
LEFT JOIN BrandVelocity BV
    ON VP.Brand = BV.Brand;


	
CREATE VIEW Vendor_RevenueShare_Score AS
WITH VendorPurchases AS (
    SELECT
        VI.VendorName,
        B.Brand,
        B.Description,
        SUM(VI.Quantity) AS Total_Items_Bought
    FROM VendorInvoicesDec VI
    JOIN PurchasesDec P
        ON VI.PONumber = P.PONumber
    JOIN Brands B
        ON P.Brand = B.Brand
    GROUP BY
        VI.VendorName,
        B.Brand,
        B.Description
),

BrandTotals AS (
    SELECT
        Brand,
        SUM(Total_Items_Bought) AS Brand_Total_Bought
    FROM VendorPurchases
    GROUP BY Brand
),

BrandRevenue AS (
    SELECT
        Brand,
        SUM(SalesDollars) AS Total_Brand_Revenue
    FROM SalesDec
    GROUP BY Brand
)

SELECT
    VP.VendorName,
    VP.Description,

    -- allocated revenue
    (VP.Total_Items_Bought * 1.0 / BT.Brand_Total_Bought)
        * COALESCE(BR.Total_Brand_Revenue, 0) AS Allocated_Revenue,

    -- revenue share score (importance)
    CASE NTILE(4) OVER (
        ORDER BY
            (VP.Total_Items_Bought * 1.0 / BT.Brand_Total_Bought)
            * COALESCE(BR.Total_Brand_Revenue, 0) DESC
    )
        WHEN 1 THEN 4   -- highest revenue impact
        WHEN 2 THEN 3
        WHEN 3 THEN 2
        ELSE 1          -- lowest revenue impact
    END AS RevenueShare_Score

FROM VendorPurchases VP
JOIN BrandTotals BT
    ON VP.Brand = BT.Brand
LEFT JOIN BrandRevenue BR
    ON VP.Brand = BR.Brand;
	
-- Importance Scorecard

CREATE VIEW Importance_Scores AS
SELECT
    VV.VendorName,
    VV.Description,
    (VV.Velocity_Score * 1.0 * 0.6)
  + (VR.RevenueShare_Score * 1.0 * 0.4) AS Importance_Score
FROM Vendor_Velocity_Score VV
JOIN Vendor_RevenueShare_Score VR
ON VV.VendorName = VR.VendorName
AND VV.Description = VR.Description;

-- Complexity Scorecard
CREATE VIEW Complexity_Scores AS
SELECT 
VL.VendorName,
VL.Description,
((( 5 - VL.LeadTime_Score) * 1.0 *0.6) + (( 5- VIR.InventoryRisk_Score) * 1.0 * 0.4)) AS Complexity_Score
FROM Vendor_LeadTime_Score VL
INNER JOIN Vendor_InventoryRisk_Score VIR
ON VL.VendorName = VIR.VendorName
AND VL.Description = VIR.Description;

-- MasterScorecard Sourcing Matrix

CREATE VIEW MasterScorecard AS
SELECT I.VendorName, I.Description, I.Importance_Score as Importance, CS.Complexity_Score as Complexity,
CASE 
	WHEN I.Importance_Score < 2.5 AND CS.Complexity_Score < 2.5 THEN 'Routine'
	WHEN I.Importance_Score < 2.5 AND CS.Complexity_Score >= 2.5 THEN 'Bottleneck'
	WHEN I.Importance_Score >= 2.5 AND CS.Complexity_Score < 2.5 THEN 'Leverage'
	ELSE 'Critical'
	END AS Sourcing_Category
FROM Importance_Scores I
INNER JOIN Complexity_Scores CS
ON I.VendorName = CS.VendorName
AND I.Description = CS.Description;

SELECT Sourcing_Category, COUNT(*)
FROM MasterScorecard
GROUP BY Sourcing_Category;
