-- how many orders do we have

select count(*) as total_orders
from orders;

-- what order status exists

select distinct(order_status)
from orders;

-- how many order in each status

select order_status, count(*) as total_orders
from orders
group by order_status
order by total_orders desc;