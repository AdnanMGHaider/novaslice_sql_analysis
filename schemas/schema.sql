/* 
NovaSlice Pizza
Schema creation script

Creates core transactional tables and constraints
customers, pizza_types, pizzas, orders, order_details
*/

CREATE TABLE customers(
    custid INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone BIGINT NOT NULL,
    address VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code INT NOT NULL
);

CREATE TABLE pizza_types(
    pizza_type_id VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    ingredients VARCHAR(MAX) NOT NULL
);

CREATE TABLE pizzas (
    pizza_id VARCHAR(20) NOT NULL,
    pizza_type_id VARCHAR(20) NOT NULL,
    size VARCHAR(5) NOT NULL,
    price DECIMAL(5, 2) NOT NULL
);

CREATE TABLE orders(
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time VARCHAR(8) NOT NULL,
    custid INT NOT NULL,
    status VARCHAR(20) NOT NULL
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL
);


-- Primary Keys and Foreign Keys

-- 1 customers
ALTER TABLE customers
ADD CONSTRAINT pk_customers PRIMARY KEY (custid);

-- 2 pizza_types
ALTER TABLE pizza_types
ADD CONSTRAINT pk_pizza_types PRIMARY KEY (pizza_type_id);

-- 3 pizzas
ALTER TABLE pizzas
ADD CONSTRAINT pk_pizzas PRIMARY KEY (pizza_id);

-- Changing data type to match same data length as pizza_types(pizza_type_id)
ALTER TABLE pizzas
ALTER COLUMN pizza_type_id VARCHAR(50) NOT NULL;

ALTER TABLE pizzas
ADD CONSTRAINT fk_pizzas_pizza_types
FOREIGN KEY (pizza_type_id) REFERENCES pizza_types(pizza_type_id);

-- 4 orders
ALTER TABLE orders
ADD CONSTRAINT pk_orders PRIMARY KEY (order_id);

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (custid) REFERENCES customers(custid);

-- 5 order_details
ALTER TABLE order_details
ADD CONSTRAINT pk_order_details PRIMARY KEY (order_details_id);

ALTER TABLE order_details
ADD CONSTRAINT fk_order_details_pizzas
FOREIGN KEY (pizza_id) REFERENCES pizzas(pizza_id);

ALTER TABLE order_details
ADD CONSTRAINT fk_order_details_orders
FOREIGN KEY (order_id) REFERENCES orders(order_id);