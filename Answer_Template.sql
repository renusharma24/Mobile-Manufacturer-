--SQL Advance Case Study
/*
USE Company
SELECT *
FROM DIM_CUSTOMER
SELECT *
FROM DIM_DATE
SELECT *
FROM DIM_LOCATION
SELECT *
FROM DIM_MANUFACTURER
SELECT * 
FROM DIM_MODEL
SELECT *
FROM FACT_TRANSACTIONS*/

--Q1--BEGIN 

SELECT DISTINCT state_
FROM   (SELECT fact.idlocation,
               Year(fact.date) Year,
               loc.state state_
        FROM   fact_transactions fact
               LEFT JOIN dim_location loc
                      ON fact.idlocation = loc.idlocation
        WHERE  Year(fact.date) >= 2005)a
	
--Q1--end 


--Q2--BEGIN

	SELECT COUNT(*) as count_s, DIM_LOCATION.State from DIM_LOCATION, FACT_TRANSACTIONS, DIM_MODEL, DIM_MANUFACTURER
	where DIM_LOCATION.Country='US' and DIM_MANUFACTURER.Manufacturer_Name='Samsung' and DIM_LOCATION.IDLocation = FACT_TRANSACTIONS.IDLocation and DIM_MODEL.IDModel= FACT_TRANSACTIONS.IDModel and
	DIM_MANUFACTURER.IDManufacturer = DIM_MODEL.IDManufacturer
	GROUP BY DIM_LOCATION.State order by count_s desc

--Q2--END

--Q3--BEGIN      
	
	SELECT DIM_MANUFACTURER.manufacturer_name, d_mod.model_name, loc.zipcode, loc.state, Count(f_tran.idmodel) Total_Transactions_Done
    FROM   fact_transactions f_tran
    INNER JOIN dim_location loc ON f_tran.idlocation = loc.idlocation
    INNER JOIN dim_model d_mod ON f_tran.idmodel = d_mod.idmodel
    INNER JOIN dim_manufacturer DIM_MANUFACTURER ON d_mod.idmanufacturer = DIM_MANUFACTURER.idmanufacturer
    GROUP  BY DIM_MANUFACTURER.manufacturer_name, d_mod.model_name, loc.zipcode, loc.state 


--Q3--END

--Q4--BEGIN

SELECT dim_manufacturer.manufacturer_name,d_mod.model_name,d_mod.unit_price
FROM   dim_model d_mod
LEFT JOIN dim_manufacturer dim_manufacturer ON d_mod.idmanufacturer = dim_manufacturer.idmanufacturer
ORDER  BY d_mod.unit_price 


--Q4--END

--Q5--BEGIN

SELECT TOP 5 agroup.idmodel, agroup.model_name, d_manu.manufacturer_name, Avg(ft1.totalprice) Avg_Price
FROM  (SELECT ft.idmodel, Sum(ft.quantity) Total_Sales, d_mod.model_name, d_mod.idmanufacturer FROM fact_transactions ft
              LEFT JOIN dim_model d_mod ON ft.idmodel = d_mod.idmodel
			  GROUP  BY ft.idmodel, d_mod.model_name, d_mod.idmanufacturer)agroup
LEFT JOIN fact_transactions ft1 ON agroup.idmodel = ft1.idmodel
LEFT JOIN dim_manufacturer d_manu ON agroup.idmanufacturer = d_manu.idmanufacturer
GROUP  BY agroup.idmodel, d_manu.manufacturer_name, agroup.model_name
ORDER  BY avg_price DESC 


--Q5--END

--Q6--BEGIN

SELECT cust.customer_name,
       ft.idcustomer,
       Year(ft.date)      YEAR_,
       Avg(ft.totalprice) Avg_Price
FROM   fact_transactions ft
       LEFT JOIN dim_customer cust
              ON ft.idcustomer = cust.idcustomer
WHERE  Year(ft.date) = 2009
GROUP  BY Year(ft.date),
          ft.idcustomer,
          cust.customer_name
HAVING Avg(ft.totalprice) > 500
ORDER  BY Avg(ft.totalprice) DESC


--Q6--END
	
--Q7--BEGIN  
	
	SELECT a.model_name, a.total_qty_2008, b.total_qty_2009, c.total_qty_2010
FROM (SELECT Row_number() OVER( ORDER BY Sum(ft.quantity) DESC) RN, mode.model_name, Sum(ft.quantity) Total_Qty_2008, Year(ft.date) Year_2008
        FROM   fact_transactions ft
     LEFT JOIN dim_model mode ON ft.idmodel = mode.idmodel
        WHERE  Year(date) = 2008
        GROUP  BY mode.model_name, Year(ft.date))a
       INNER JOIN (SELECT Row_number() OVER( ORDER BY Sum(ft.quantity) DESC) RN, mode.model_name, Sum(ft.quantity) Total_Qty_2009, Year(ft.date) Year_2009
       FROM fact_transactions ft LEFT JOIN dim_model mode ON ft.idmodel = mode.idmodel
       WHERE  Year(date) = 2009
       GROUP  BY mode.model_name, Year(ft.date))b ON a.model_name = b.model_name
       INNER JOIN (SELECT Row_number() OVER(ORDER BY Sum(ft.quantity) DESC) RN, mode.model_name, Sum(ft.quantity) Total_Qty_2010, Year(ft.date) Year_2010
       FROM fact_transactions ft
       LEFT JOIN dim_model mode ON ft.idmodel = mode.idmodel
       WHERE  Year(date) = 2010
       GROUP  BY mode.model_name, Year(ft.date))c
               ON b.model_name = c.model_name
WHERE  a.rn BETWEEN 1 AND 5
		OR b.rn BETWEEN 1 AND 5
        AND c.rn BETWEEN 1 AND 5

--Q7--END


--Q8--BEGIN

SELECT a.idmodel,
       a.manufacturer_name,
       a.model_name,
       a.total_qty,
       a.year_
FROM  (SELECT Row_number()
                OVER(
                  ORDER BY Sum(ft.quantity) DESC) RN,
              ft.idmodel,
              model.model_name,
              manu.manufacturer_name,
              Sum(ft.quantity)                    Total_Qty,
              Year(ft.date)                       Year_
       FROM   fact_transactions ft
              LEFT JOIN dim_model model
                     ON model.idmodel = ft.idmodel
              LEFT JOIN dim_manufacturer manu
                     ON model.idmanufacturer = manu.idmanufacturer
       WHERE  Year(ft.date) = 2009
       GROUP  BY ft.idmodel,
                 model.model_name,
                 manu.manufacturer_name,
                 Year(ft.date))a
WHERE  a.rn = 2
UNION
SELECT b.idmodel,
       b.manufacturer_name,
       b.model_name,
       b.total_qty,
       b.year_
FROM   (SELECT Row_number()
                 OVER(
                   ORDER BY Sum(ft.quantity) DESC) RN,
               ft.idmodel,
               model.model_name,
               manu.manufacturer_name,
               Sum(ft.quantity)                    Total_Qty,
               Year(ft.date)                       Year_
        FROM   fact_transactions ft
               LEFT JOIN dim_model model
                      ON model.idmodel = ft.idmodel
               LEFT JOIN dim_manufacturer manu
                      ON model.idmanufacturer = manu.idmanufacturer
        WHERE  Year(ft.date) = 2010
        GROUP  BY ft.idmodel,
                  model.model_name,
                  manu.manufacturer_name,
                  Year(ft.date))b
WHERE  b.rn = 2 

--Q8--END


--Q9--BEGIN
	
SELECT a.*,
       b.total_count_2009
FROM   (SELECT manu.manufacturer_name,
               Count(manu.manufacturer_name) Total_Count_2010
        FROM   fact_transactions ft
               LEFT JOIN dim_model model
                      ON ft.idmodel = model.idmodel
               LEFT JOIN dim_manufacturer manu
                      ON model.idmanufacturer = manu.idmanufacturer
        WHERE  Year(ft.date) = 2010
        GROUP  BY manu.manufacturer_name) a
       LEFT JOIN(SELECT manu.manufacturer_name,
                        Count(manu.manufacturer_name) Total_Count_2009
                 FROM   fact_transactions ft
                        LEFT JOIN dim_model model
                               ON ft.idmodel = model.idmodel
                        LEFT JOIN dim_manufacturer manu
                               ON model.idmanufacturer = manu.idmanufacturer
                 WHERE  Year(ft.date) = 2009
                 GROUP  BY manu.manufacturer_name) b
              ON a.manufacturer_name = b.manufacturer_name
WHERE  b.manufacturer_name IS NULL 


--Q9--END

--Q10--BEGIN
	

	SELECT *
FROM   (SELECT cust.idcustomer,
               cust.customer_name,
               Sum(ft.quantity)   Avg_Qty_2003,
               Avg(ft.totalprice) Avg_Price_2003
        FROM   dim_customer cust
               LEFT JOIN fact_transactions ft
                      ON cust.idcustomer = ft.idcustomer
        WHERE  Year(date) = 2003
        GROUP  BY cust.idcustomer,
                  cust.customer_name)AS a
       CROSS JOIN (SELECT Avg(ft.quantity)   Avg_Qty_2004,
                          Avg(ft.totalprice) Avg_Price_2004
                   FROM   dim_customer cust
                          LEFT JOIN fact_transactions ft
                                 ON cust.idcustomer = ft.idcustomer
                   WHERE  Year(date) = 2004
                   GROUP  BY cust.idcustomer,
                             cust.customer_name)AS b
       CROSS JOIN (SELECT Avg(ft.quantity)   Avg_Qty_2005,
                          Avg(ft.totalprice) Avg_Price_2005
                   FROM   dim_customer cust
                          LEFT JOIN fact_transactions ft
                                 ON cust.idcustomer = ft.idcustomer
                   WHERE  Year(date) = 2005
                   GROUP  BY cust.idcustomer,
                             cust.customer_name)AS c
       CROSS JOIN (SELECT Avg(ft.quantity)   Avg_Qty_2006,
                          Avg(ft.totalprice) Avg_Price_2006
                   FROM   dim_customer cust
                          LEFT JOIN fact_transactions ft
                                 ON cust.idcustomer = ft.idcustomer
                   WHERE  Year(date) = 2006
                   GROUP  BY cust.idcustomer,
                             cust.customer_name)AS d
       CROSS JOIN (SELECT Avg(ft.quantity)   Avg_Qty_2007,
                          Avg(ft.totalprice) Avg_Price_2007
                   FROM   dim_customer cust
                          LEFT JOIN fact_transactions ft
                                 ON cust.idcustomer = ft.idcustomer
                   WHERE  Year(date) = 2007
                   GROUP  BY cust.idcustomer,
                             cust.customer_name)AS e
       CROSS JOIN (SELECT Avg(ft.quantity)   Avg_Qty_2008,
                          Avg(ft.totalprice) Avg_Price_2008
                   FROM   dim_customer cust
                          LEFT JOIN fact_transactions ft
                                 ON cust.idcustomer = ft.idcustomer
                   WHERE  Year(date) = 2008
                   GROUP  BY cust.idcustomer,
                             cust.customer_name)AS f
       CROSS JOIN (SELECT Avg(ft.quantity)   Avg_Qty_2009,
                          Avg(ft.totalprice) Avg_Price_2009
                   FROM   dim_customer cust
                          LEFT JOIN fact_transactions ft
                                 ON cust.idcustomer = ft.idcustomer
                   WHERE  Year(date) = 2009
                   GROUP  BY cust.idcustomer,
                             cust.customer_name)AS g
       CROSS JOIN (SELECT Avg(ft.quantity)   Avg_Qty_2010,
                          Avg(ft.totalprice) Avg_Price_2010
                   FROM   dim_customer cust
                          LEFT JOIN fact_transactions ft
                                 ON cust.idcustomer = ft.idcustomer
                   WHERE  Year(date) = 2010
                   GROUP  BY cust.idcustomer,
                             cust.customer_name)AS h

--Q10--END
	