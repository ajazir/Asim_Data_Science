#==============================================================================================
# On checking the (demo) business database, we can identify the different type of information 
# available fpr a business entity that provide e-commerce services.
# These information are arranged in different tables and ultimatly represent the 
#different aspects of their business activity over a specific time segment.

# You can find below different commands to extract specified information:

#===============================================================================================

#How we can answer general questions.........
#---------------------------------------------------------------------------

#1. Here we want to check that "How many orders are there in the dataset"?
 
SELECT 
	COUNT(order_id) AS number_of_orders
FROM
	orders;

#----------------------------------------------------------------------------------

#2. Are orders actually delivered?

SELECT 
	order_status, 
	COUNT(*) AS number_of_orders
FROM
	orders
GROUP BY order_status
ORDER BY number_of_orders DESC;


#----------------------------------------------------------------------------------

#3. Is magist having user growth?

SELECT 
	YEAR(order_purchase_timestamp) AS year_opt,
	MONTH(order_purchase_timestamp) AS month_opt,
	COUNT(distinct(customer_id))
FROM
	orders
GROUP BY year_opt , month_opt
ORDER BY year_opt , month_opt;


#----------------------------------------------------------------------------------
#4. How many products are there in the products table?

SELECT 
	COUNT(DISTINCT product_id) AS numbers_of_products
FROM
	products;
#Number of products: 32951
#=============================================================

#5. Which are the categories with the most products?

SELECT 
	product_category_name,
	COUNT(DISTINCT product_id) AS number_of_products
FROM
	products
GROUP BY product_category_name
ORDER BY COUNT(product_id) DESC;


#=============================================================

#6. How many of those products were present in actual transactions?

SELECT 
	COUNT(DISTINCT product_id)
FROM order_items;



#=============================================================

#7. What's the price for the most expensive and cheapest products, rounded to 2 decimal points?

SELECT 
	MAX(price), 
	MIN(price), 
	round(AVG(price), 2)
FROM
	order_items;


#=============================================================

#8. What are the highest and lowest payment values?

SELECT 
	MAX(payment_value), 
	MIN(payment_value), 
	AVG(payment_value)
FROM
	order_payments;
   select * from  order_payments;



#========================================================================


#Answer Business questions

#Regarding the products

#========================================================================

#Categories of tech products

SELECT DISTINCT
	p.product_category_name AS Portugese,
	pcnt.product_category_name_english AS English
FROM
	products AS p
LEFT JOIN
	product_category_name_translation AS pcnt 
ON 
	p.product_category_name = pcnt.product_category_name;

#----------------------------------------------------------------------------------

# 	How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?



create table Catagory_wise_sales
as
SELECT 
	oi.order_id order_id,p.product_id product_id,price ,freight_value,e.product_category_name_english as Catagory
    
FROM
	products as p
LEFT JOIN
	product_category_name_translation as e
ON 
	e.product_category_name=p.product_category_name
JOIN
	order_items as oi
ON 
	oi.product_id=p.product_id;




#All catagories

SELECT 
    catagory, round(sum(price),0) "Pricr($)",count(product_id) Item_Sold
FROM
    catagory_wise_sales

GROUP BY  catagory

ORDER BY sum(price) desc;



SELECT 
    product_category_name_english, COUNT(product_id)
FROM
    product_sold_by_catagory_price
    GROUP BY  product_category_name_english

ORDER BY COUNT(product_id) desc;

# Tech products

SELECT 
    product_category_name_english, COUNT(product_id)
FROM
    product_sold_by_catagory_price
WHERE 
	product_category_name_english='audio'
or 
	product_category_name_english='cds_dvds_musicals'
or 
	product_category_name_english='computers'
or 
	product_category_name_english='computers_accessories'
or 
	product_category_name_english='consoles_games'
or 
	product_category_name_english='dvds_blu_ray'
or 
	product_category_name_english='electronics'
or 
	product_category_name_english='fixed_telephony'
or 
	product_category_name_english='home_appliances'
or 
	product_category_name_english='home_appliances_2'
or 
	product_category_name_english='pc_gamer'
or 
	product_category_name_english='signaling_and_security'
or 
	product_category_name_english='small_appliances'
or 
	product_category_name_english='tablets_printing_image'
or 
	product_category_name_english='telephony'
    
GROUP BY  product_category_name_english

ORDER BY COUNT(product_id) DESC ;
    



#----------------------------------------------------------------------------------

#Number of tech products sold (plus sum of price for each category)

SELECT 
	o.order_status,
	COUNT(DISTINCT o.order_id),
	ROUND(SUM(oi.price), 2)
FROM
	products AS p
		LEFT JOIN
	order_items AS oi ON p.product_id = oi.product_id
		LEFT JOIN
	orders AS o ON oi.order_id = o.order_id
WHERE
	o.order_status = 'delivered'
	OR o.order_status = 'shipped'
	OR o.order_status = 'invoiced'
GROUP BY o.order_status
ORDER BY COUNT(o.order_id) DESC;


#----------------------------------------------------------------------------------

#Average price (per product category)

SELECT DISTINCT
	catagory,
	ROUND(AVG(price), 2) AS AveragePrice
FROM
	catagory_wise_sales
GROUP BY
	catagory
ORDER BY
    catagory DESC;


#----------------------------------------------------------------------------------

#Are expensive product popular?

SELECT 
	product_id, price, COUNT(order_id)
FROM
	order_items
GROUP BY product_id , price
ORDER BY price DESC;

#----------------------------------------------------------------------------------

#Regarding the sellers

#Time in month cover in the magist data base

SELECT 
	MAX(order_purchase_timestamp) AS latest_purchase,
    MIN(order_purchase_timestamp) AS earliest_purchase,
	ROUND(DATEDIFF(MAX(order_purchase_timestamp),
		MIN(order_purchase_timestamp)) / 30,2) 
        AS difference_month,
	ROUND(DATEDIFF(MIN(order_purchase_timestamp),
		MAX(order_purchase_timestamp)) / 30 / 12,2) 
        AS difference_years
FROM
	orders;

#----------------------------------------------------------------------------------

#Number of sellers

SELECT 
	COUNT(DISTINCT seller_id) as total_sellers
FROM
	sellers;


#----------------------------------------------------------------------------------

#Total amount earned by sellers
#a. by individual seller
SELECT DISTINCT
	oi.seller_id AS Seller,
	ROUND(SUM(op.payment_value), 2) AS Total
FROM
	order_items AS oi
		LEFT JOIN
	order_payments AS op ON oi.order_id = op.order_id
GROUP BY Seller
ORDER BY Total DESC;


#b. total earned all sellors

SELECT 
	ROUND(SUM(op.payment_value), 2) AS Total
FROM
	order_items AS oi
		LEFT JOIN
	order_payments AS op ON oi.order_id = op.order_id
ORDER BY Total DESC;



#----------------------------------------------------------------------------------

#Average monthly income of all sellers


SELECT 
	ROUND(SUM(op.payment_value), 2) AS Total,
	ROUND(SUM(op.payment_value) / 25.77, 2) AS PerMonth
FROM
	order_items AS oi
		LEFT JOIN
	order_payments AS op ON oi.order_id = op.order_id
ORDER BY Total DESC;


#----------------------------------------------------------------------------------

#Regaring delivery time

#Average time from order to delivery

SELECT 
	round(STDDEV_POP(DATEDIFF(order_delivered_customer_date,
		order_purchase_timestamp)),2) AS stand_div_delivery_days,
	round(AVG(DATEDIFF(order_delivered_customer_date,
		order_purchase_timestamp)),2) AS average_delivery_days
FROM
	orders
WHERE
	order_delivered_customer_date IS NOT NULL
		AND order_purchase_timestamp IS NOT NULL;


#----------------------------------------------------------------------------------

#Number of orders "Delivered in time"

SELECT
             order_estimated_delivery_date AS est,
             order_delivered_customer_date AS customer,
             DATEDIFF(order_estimated_delivery_date,
                           order_delivered_customer_date) AS difference_days
FROM
             orders
WHERE DATEDIFF(order_estimated_delivery_date,
                           order_delivered_customer_date) > 0;
#=============================================================
#Delivered with delay

SELECT
             order_estimated_delivery_date AS est,
             order_delivered_customer_date AS customer,
             DATEDIFF(order_estimated_delivery_date,
                           order_delivered_customer_date) AS difference_days
FROM
             orders
WHERE DATEDIFF(order_estimated_delivery_date,
                           order_delivered_customer_date) < 0;
                           
#total orders delayed

SELECT
             count(DATEDIFF(order_estimated_delivery_date,
                           order_delivered_customer_date)) AS difference_days
FROM
             orders
WHERE DATEDIFF(order_estimated_delivery_date,
                           order_delivered_customer_date) < 0;


#8. What are the highest and lowest payment values?

select 
	round(MIN(price+freight_value),2) 
as 
	Cheapest, round(MAX(price+freight_value),2) 
as 
	most_expensive 
from 
	order_items;

#!!!!!!!!!!==================================OOOOOOOOOO=======================================!!!!!!!!!!





