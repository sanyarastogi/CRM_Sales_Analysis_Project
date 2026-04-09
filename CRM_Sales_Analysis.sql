-- --------------------------------------------------------------------
--------------------------------------------------------------------------
-- CRM Sales Analysis - SQL QUERIES
-- Author : Sanya Rastogi
-- Tool : SSMS

-- Query 1 : Total Revenue from Won Deals

SELECT SUM(close_value) AS Total_Revenue
FROM [sales_pipeline$]
WHERE deal_stage = 'Won';

-- Query 2: Win Rate by Product

SELECT product,
COUNT(*) AS Total_Deals,
SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) AS Won_Deals,
ROUND(SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Win_Rate_Percent
FROM [sales_pipeline$]
GROUP BY product
ORDER BY Win_Rate_Percent DESC;

-- Query 3: Best Performing Sales Team

SELECT st.manager,
COUNT(*) AS Total_Deals,
SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS Won_Deals,
SUM(sp.close_value) AS Total_Revenue
FROM [sales_pipeline$] sp
JOIN [sales_teams$] st ON sp.sales_agent = st.sales_agent
GROUP BY st.manager
ORDER BY Total_Revenue DESC;


-- Query 4: Quarter over Quarter Revenue with LAG

SELECT 
YEAR(close_date) AS Year,
DATEPART(QUARTER, close_date) AS Quarter,
SUM(close_value) AS Current_Revenue,
LAG(SUM(close_value)) OVER (ORDER BY YEAR(close_date), 
DATEPART(QUARTER, close_date)) AS Previous_Quarter_Revenue,
SUM(close_value) - LAG(SUM(close_value)) OVER (ORDER BY YEAR(close_date), 
DATEPART(QUARTER, close_date)) AS Revenue_Growth
FROM [sales_pipeline$]
WHERE deal_stage = 'Won'
AND close_date IS NOT NULL
GROUP BY YEAR(close_date), DATEPART(QUARTER, close_date)
ORDER BY Year, Quarter;


-- Query 5: Sales by Industry/Sector

SELECT a.sector,
COUNT(*) AS Total_Deals,
SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS Won_Deals,
SUM(sp.close_value) AS Total_Revenue,
ROUND(SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Win_Rate_Percent
FROM [sales_pipeline$] sp
JOIN [accounts$] a ON sp.account = a.account
GROUP BY a.sector
ORDER BY Total_Revenue DESC;


-- Query 6: Stuck Deals in Pipeline

SELECT sales_agent,
account,
product,
deal_stage,
engage_date,
DATEDIFF(DAY, engage_date, GETDATE()) AS Days_In_Pipeline
FROM [sales_pipeline$]
WHERE deal_stage IN ('Engaging', 'Prospecting')
AND close_date IS NULL
ORDER BY Days_In_Pipeline DESC;


-- Query 7: Agent Performance Ranking

SELECT 
sales_agent,
COUNT(*) AS Total_Deals,
SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) AS Won_Deals,
SUM(close_value) AS Total_Revenue,
ROUND(SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Win_Rate_Percent,
RANK() OVER (ORDER BY SUM(close_value) DESC) AS Revenue_Rank
FROM [sales_pipeline$]
GROUP BY sales_agent
ORDER BY Revenue_Rank;