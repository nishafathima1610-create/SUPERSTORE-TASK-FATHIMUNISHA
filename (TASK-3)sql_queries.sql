use superstore
select * from TASK_3
--Total Sales, Profit, Quantity--
SELECT 
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity
FROM task_3;

--Monthly Sales Trend--
SELECT 
    FORMAT([Order_Date], 'yyyy-MM') AS Month,
    SUM([Sales]) AS Monthly_Sales
FROM TASK_3
GROUP BY FORMAT([Order_Date], 'yyyy-MM')
ORDER BY Month;

--Year-over-Year Sales Comparison--

SELECT 
    YEAR([Order_Date]) AS Year,
    SUM(Sales) AS Yearly_Sales
FROM TASK_3
GROUP BY YEAR([Order_Date])
ORDER BY Year;

--Top 10 Products by Sales--

SELECT TOP 10
    [Product_Name],
    SUM(Sales) AS Total_Sales
FROM TASK_3
GROUP BY [Product_Name]
ORDER BY Total_Sales DESC;

--Top 10 Customers by Revenue--

SELECT TOP 10
    [Customer_Name],
    SUM(Sales) AS Total_Sales
FROM TASK_3
GROUP BY [Customer_Name]
ORDER BY Total_Sales DESC;

--Category-wise Profit Margin--

SELECT 
    Category,
    SUM(Profit) AS Total_Profit,
    SUM(Sales) AS Total_Sales,
    CASE 
        WHEN SUM(Sales) = 0 THEN 0
ELSE CAST(SUM(Profit) AS FLOAT)/SUM(Sales)
END AS Profit_Margin
FROM TASK_3
GROUP BY Category
ORDER BY Profit_Margin DESC;

--Region Performance (Sales + Profit)--

SELECT 
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM TASK_3
GROUP BY Region
ORDER BY Total_Sales DESC;

--Discount Impact on Profitability--

SELECT 
    ROUND(Discount, 2) AS Discount_Rate,
    SUM(Profit) AS Total_Profit
FROM TASK_3
GROUP BY ROUND(Discount, 2)
ORDER BY Discount_Rate;

--Profit Loss Analysis (Negative Profit Items)--

SELECT 
    Product_Name,
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM TASK_3
WHERE Profit < 0
GROUP BY Product_Name, Category
ORDER BY Total_Profit ASC;

--Segment Contribution %--

SELECT 
    Segment,
    SUM(Sales) AS Segment_Sales,
    CAST(SUM(Sales) * 100.0 / (SELECT SUM(Sales) FROM TASK_3) AS DECIMAL(5,2)) AS Sales_Percent,
    SUM(Profit) AS Segment_Profit,
    CAST(SUM(Profit) * 100.0 / (SELECT SUM(Profit) FROM TASK_3) AS DECIMAL(5,2)) AS Profit_Percent
FROM TASK_3
GROUP BY Segment
ORDER BY Segment_Sales DESC;

--Shipping Time Calculation (Ship Date – Order Date)--

SELECT 
    Order_ID,
    Customer_Name,
    Order_Date,
    Ship_Date,
    DATEDIFF(DAY, [Order_Date], [Ship_Date]) AS Shipping_Days
FROM TASK_3
ORDER BY Shipping_Days DESC;

--Identify Outlier Orders (High Sales or Loss)--

WITH SalesStats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Sales) OVER() AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Sales) OVER() AS Q3
    FROM TASK_3
),
Outliers AS (
    SELECT 
        s.Order_ID,
        s.Product_Name,
        s.Sales,
        s.Profit,
        ss.Q1,
        ss.Q3,
        1.5*(ss.Q3 - ss.Q1) AS IQR
    FROM TASK_3 s
    CROSS JOIN SalesStats ss
)
SELECT *
FROM Outliers
WHERE Sales < (Q1 - 1.5*IQR) OR Sales > (Q3 + 1.5*IQR)
ORDER BY Sales DESC;