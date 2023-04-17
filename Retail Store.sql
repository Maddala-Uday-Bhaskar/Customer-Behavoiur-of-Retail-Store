--1. what is the total no of rows in each of 3 tables in Database?
 
 select Count(*) as Total_no_of_Rows from [dbo].[prod_cat_info]
 select Count (*) as Total_no_of_Rows from [dbo].[Customer]
 select Count(*) as Total_no_of_Rows from [dbo].[Transactions]

-- 2.what is the total no Transactions that have returns?

 select Count(*) as Total_Return_Transactions from Transactions
 where Qty < 0

--3. Which Product_category does the Sub_category "DIY" Belongs to?

select [prod_cat] from [dbo].[prod_cat_info]
where [prod_subcat] = 'DIY'

--Data Analysis

--1.Which channel is most frequently used for Transactions?

select  top 1 store_type, count(*) as Count_of_Channel from Transactions
group by Store_type 
order by count(*) desc

--2. What is the count of male and female customers from Database?

select Gender, count (*) as Total_count from [dbo].[Customer]
group by Gender
having Gender in ('m','f')

or 

select Gender, count (*) as Total_count from [dbo].[Customer]
group by Gender
having Gender ='M' or Gender ='F'


--3. From which city do we have the maximum no of customers and how?

select top 1 c.[city_code], count(*) as no_of_customers from [dbo].[Transactions] as t
left join [dbo].[Customer] as c
on t.cust_id=c.customer_Id
 group by c.[city_code]
 order by count(*) desc

 --4. how many sub_category are there under Books Category?

 select prod_subcat ,count(prod_subcat)as Under_Books_Cat from prod_cat_info
 where prod_cat='Books'
 group by prod_subcat
 --Or
 select [prod_cat] ,[prod_subcat] from [dbo].[prod_cat_info]
 where lower([prod_cat]) ='books'


--5. what is the maximum quantity of products ever ordered?

select prod_cat ,prod_subcat ,Max(qty) from Transactions t 
 left join prod_cat_info as p
 on p.prod_cat_code=t.prod_cat_code
 group by prod_cat, prod_subcat
 ---or

select p.[prod_cat],max([Qty]) from [dbo].[prod_cat_info] as p
left join [dbo].[Transactions] as t
on t.[prod_cat_code]=p.[prod_sub_cat_code]
group by p.[prod_cat]



--6. what is the Total net revenue generated in categories Electronics and Books?

select p.prod_cat, sum(total_amt) from prod_cat_info p
left join Transactions t
on t.prod_cat_code=p.prod_cat_code
where p.prod_cat in ('Electronics', 'Books')
group by p.prod_cat


select p.[prod_cat], sum(total_amt) as Revenue from [dbo].[Transactions] as t
left join [dbo].[prod_cat_info] as p
on t.[prod_cat_code]=p.[prod_sub_cat_code]
where p.[prod_cat] in ('electronics','books')
group by p.[prod_cat]


select sum(total_amt) from Transactions
ALTER TABLE Transactions
ALTER COLUMN total_amt float;


--7. how many customers have more than 10 transactions with us excluding returns

select cust_id,count(*) as no_of_Trans from Transactions
group by cust_id
having count(*) >10 


select [cust_id], count ([transaction_id]) as No_of_trxs from [dbo].[Transactions]
where [Qty]>0
group by [cust_id]
having count ([transaction_id]) > 10

--8. what is the combined revenue earned from "Electronics" and "Clothing" categories from "Flagship 
--stores?"

select round(sum(cast([total_amt] as float)),2) as Combined_Revenue
from 
		[dbo].[Transactions] as t
left join
		[dbo].[prod_cat_info] as p
	on t.[prod_cat_code]= p.[prod_cat_code] 
and t.[prod_subcat_code] = p.[prod_sub_cat_code]
where [Store_type]='Flagship store' and (p.prod_cat = 'Electronics' or p.prod_cat = 'Clothing')


--9. what is the Total revenue generated from 'Male' customers in 'Electronics' Category ? 
--output should display in total revenue by Prod_sub_Cat?


select p.prod_subcat, round(sum(cast(total_amt as Float)),3) as Total_revenue
from Transactions t
inner join Customer c on t.cust_id = c.customer_Id  
inner join prod_cat_info p on t.prod_cat_code = p.prod_cat_code 
	and t.prod_subcat_code = p.prod_sub_cat_code 
where c.Gender = 'm' and p.prod_cat = 'Electronics'
group by p.prod_subcat

--10. what is the % of sales and returns by prod_sub_cat; Display only top 5 sub_categories		
--in terms of sales?


with sales_t as 
(
select t.prod_subcat_code,
sum(case when cast(total_amt as float) > 0.0 then cast(total_amt as float)end) as Total_sales
,sum(cast(total_amt as float)) as sales
,sum(case when cast(total_amt as float) < 0.0 then cast(total_amt as float) end) "returns"
from Transactions t
group by prod_subcat_code
)

select top 5 prod_subcat_code, (sales/total_sales) *100.0 as sales_percentage,
("returns"/total_sales)*100.0 as "return_percentage"
from sales_t
order by Total_sales desc


--11. Which Product Category has seen the Max Value of Returns in LAst 3 months of Transactions?


select prod_cat, max(qty) from Transactions
where lookup_date(tran_date) >= lookup_date(date_sub(current_date,90))
and lookup_date(tran_date) < lookup_date(date_sub(current_date,0))
group by prod_cat
having max(qty)<0


 -- 12. which store type sells the maximum products; By value of sales amount and Quantity Sold?

 Select store_type, count(prod_cat_code) as Max_products
 from Transactions
 group by store_type
 order by sum(cast(total_amt as float))  Desc, sum(cast(Qty as Float)) desc


 --13. what are the categories for which average revenue is above the overall average

 select p.prod_cat
 from Transactions t 
 left join prod_cat_info p 
 on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
 group by p.prod_cat
 having avg(cast(t.total_amt as float)) > 
 (select avg(cast(total_amt as float)) from Transactions)

 --14. Find the Average and total Revenue by each sub category for the categories which are the among top 5 
 -- categories in terms of quantity sold


 select p.prod_subcat, avg(total_amt) as Avg_revenue, sum(cast(total_amt as float)) as Total_revenue
 from Transactions t 
 left join prod_cat_info p 
 on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
 where t.prod_cat_code in 
 (
 select top 5 prod_cat_code
 from Transactions 
 group by prod_cat_code
 order by sum(Qty) desc
 )
 group by p.prod_subcat



