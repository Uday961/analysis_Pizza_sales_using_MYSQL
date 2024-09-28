create database pizzahut;
 use pizzahut;
 select *
 from pizzas;
 create table orders(order_id int primary key,order_date date,order_time time);
 select * 
 from orders;
 create table orders_details(order_details_id int not null ,
 order_id int not null,
 pizza_id text not null,
 quantity int,
 primary key(order_details_id,order_id,pizza_id));
 drop table orders_details;
 create table orders_details(order_details_id int not null ,
 order_id int not null,
 pizza_id varchar(250) not null,
 quantity int,
 primary key(order_details_id,order_id,pizza_id));
 select *
 from orders_details;
 
 -- Retrieve the total number of orders placed.
 select count(order_id) as total_order
 from orders;
 
 -- Calculate the total revenue generated from pizza sales. and use ctrl + b from beautify the code
 SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            0)
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;
 
 -- Identify the highest-priced pizza.
 select max(price) as highest_price
 from pizzas
 limit 5;
 
-- another method with highest price
select pizza_types.name,pizzas.price
from  pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1;
 
 -- another method with lowest price
 select pizza_types.name,pizzas.price
 from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
 order by pizzas.price
 limit 1;
 
 -- Identify the most common pizza size ordered.
 select pizza_types.name,pizzas.size
 from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
 order by pizzas.size desc
 limit 1;
 
SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS count_size
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY count_size DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,sum(orders_details.quantity) quantity
from pizza_types join  pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.name
order by quantity desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category,sum(orders_details.quantity) as total_qty
from orders_details join pizzas on pizzas.pizza_id = orders_details.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.category
order by total_qty desc;

-- Determine the distribution of orders by hour of the day.
select extract(hour from order_time) as hour_count,count(*) as order_count
from orders
group by hour_count
order by order_count;

-- Join relevant tables to find the category-wise distribution of pizzas.
-- select pizza_types.category,sum(orders_details.order_id) as pizza_ditr
-- from pizzas join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
-- join orders_details on pizzas.pizza_id = orders_details.pizza_id
-- group by pizza_types.category
-- order by pizza_ditr;
select category, count(name) as total_count
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(total_qty) ,0) as avg_qty_per_day from
(select orders.order_date,sum(orders_details.quantity) as total_qty
from orders_details join orders on orders.order_id = orders_details.order_id
group by orders.order_date ) as qty;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name,round(sum(orders_details.quantity*pizzas.price),0) as total_pizza_order
from pizzas join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.name
order by total_pizza_order desc
limit 3;

-- it is based on quantity by counting the quantity of name
select pizza_types.name,round(count(orders_details.quantity),0) as total_pizza_order
from pizzas join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.name
order by total_pizza_order desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price),
            0) / (SELECT 
            ROUND(SUM(orders_details.quantity * pizzas.price),
                        0) AS total_sales
        FROM
            orders_details
                JOIN
            pizzas ON pizzas.pizza_id = orders_details.pizza_id) * 100,
    0 AS total_revenu
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY total_revenu;

-- Analyze the cumulative revenue generated over time.
select order_date,sum(revenu) over(order by order_date) as cumulative_revenu
from
(select orders.order_date,sum(orders_details.quantity*pizzas.price) as revenu
from orders_details join pizzas on pizzas.pizza_id = orders_details.pizza_id
join orders on orders_details.order_id = orders.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,category,revenu,rank_wise
from
(select category,name,revenu,
rank() over(partition by category order by revenu desc) as rank_wise
from
(select pizza_types.category,pizza_types.name,round(sum(orders_details.quantity*pizzas.price),0) as revenu
from pizzas join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.category,pizza_types.name) as ntg) as ntgg
where rank_wise <= 3;

-- project completed 


