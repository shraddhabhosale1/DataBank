create database DBank;
use DBank;

/* How many different nodes make up the Data Bank network */

select count(distinct node_id) as 'Distinct Node' from customer_nodes;

/* How many nodes are there in each region */

select count(cn.node_id) as 'Distinct Node', r.region_id from customer_nodes cn
join regions r on cn.region_id = r.region_id group by region_id order by region_id;

/* How many customers are divided among the regions */

select r.region_id, r.region_name, count(distinct cn.customer_id) as 'Customer Count'
from customer_nodes cn inner join regions r on r.region_id = cn.region_id
group by r.region_id, r.region_name
order by r.region_id;

/* Determine the total amount of transactions for each region name */

select r.region_name, sum(ct.txn_amount) as 'Total Txn Amount' from regions r 
join customer_nodes cn on r.region_id = cn.region_id
join customer_transactions ct on cn.customer_id = ct.customer_id
group by r.region_name;

/* How long does it take on an average to move clients to a new node? */

select round(avg(datediff(end_date, start_date))) as 'Days Taken' 
from customer_nodes where end_date != "9999-12-31";

/* What is unique count and total amount for each transaction type */

select txn_type, count(*) as 'Unique_Count', count(distinct txn_type) as 'Unique Count', sum(txn_amount) as 'Total Amount' 
from customer_transactions group by txn_type;

/* What is the average number and size of past deposits across all customers? */

select round(count(customer_id)/(select count(distinct customer_id) from customer_transactions)) as 'Avg Deposite'
from customer_transactions where txn_type = 'Deposit';

/* For each month how many Data Bank customer make more than 1 deposit and
at least either 1 purchase or 1 withdrawal iin a single month? */

with transaction_count_per_month_cte as 
(select customer_id, month(txn_date) as txn_month,
sum(if(txn_type='deposit',1,0)) as deposit_count,
sum(if(txn_type='withdrawal',1,0)) as withdrawal_count,
sum(if(txn_type='purchase',1,0)) as purchase_count
from customer_transactions
group by customer_id, month(txn_date))
select txn_month, count(distinct customer_id) as Customer_count
from transaction_count_per_month_cte
where deposit_count>1 and
purchase_count = 1 or withdrawal_count= 1
group by txn_month;