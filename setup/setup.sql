-- Enhanced setup script for MySQL Workbench
-- Run this after connecting to your RDS instance

-- Create the dev schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS dev;
USE dev;

-- Drop tables if they exist (for clean setup)
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS dev.orderDetails;
DROP TABLE IF EXISTS dev.Orders;
DROP TABLE IF EXISTS dev.Customer;
DROP TABLE IF EXISTS dev.Product;
SET FOREIGN_KEY_CHECKS=1;

-- Create Product Table
CREATE TABLE dev.Product (
    productId VARCHAR(36) NOT NULL PRIMARY KEY,
    productName VARCHAR(255) NOT NULL,
    brandName VARCHAR(255),
    productDescription TEXT,
    price DECIMAL(10, 2) NOT NULL,
    productCategory VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Customer Table
CREATE TABLE dev.Customer (
    customerId VARCHAR(36) NOT NULL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(20),
    Address VARCHAR(255),
    Country VARCHAR(100),
    City VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Orders Table
CREATE TABLE dev.Orders (
    orderId VARCHAR(36) NOT NULL PRIMARY KEY,
    orderCustomerId VARCHAR(36) NOT NULL,
    orderDate DATE NOT NULL,
    paymentMethod VARCHAR(50),
    orderPlatform VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (orderCustomerId) REFERENCES Customer(customerId)
);

-- Create Order Details Table
CREATE TABLE dev.orderDetails (
    orderDetailsId VARCHAR(36) NOT NULL PRIMARY KEY,
    orderId VARCHAR(36) NOT NULL,
    productId VARCHAR(36) NOT NULL,
    Quantity INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (orderId) REFERENCES Orders(orderId),
    FOREIGN KEY (productId) REFERENCES Product(productId)
);

-- Configure binary logging for CDC
-- CALL mysql.rds_set_configuration('binlog retention', 24);

-- Insert sample data for testing
INSERT INTO dev.Product (productId, productName, brandName, productDescription, price, productCategory) VALUES
('prod-001', 'Laptop Pro 15', 'TechBrand', '15-inch professional laptop', 1299.99, 'Electronics'),
('prod-002', 'Wireless Mouse', 'TechBrand', 'Ergonomic wireless mouse', 29.99, 'Electronics'),
('prod-003', 'Coffee Mug', 'HomeGoods', 'Ceramic coffee mug 12oz', 12.99, 'Home');

INSERT INTO dev.Customer (customerId, Name, Email, Phone, Address, Country, City) VALUES
('cust-001', 'John Doe', 'john.doe@email.com', '+1-555-0101', '123 Main St', 'USA', 'New York'),
('cust-002', 'Jane Smith', 'jane.smith@email.com', '+1-555-0102', '456 Oak Ave', 'USA', 'Los Angeles'),
('cust-003', 'Bob Wilson', 'bob.wilson@email.com', '+1-555-0103', '789 Pine St', 'USA', 'Chicago');

INSERT INTO dev.Orders (orderId, orderCustomerId, orderDate, paymentMethod, orderPlatform) VALUES
('order-001', 'cust-001', '2024-01-15', 'Credit Card', 'Web'),
('order-002', 'cust-002', '2024-01-16', 'PayPal', 'Mobile'),
('order-003', 'cust-003', '2024-01-17', 'Credit Card', 'Web');

INSERT INTO dev.orderDetails (orderDetailsId, orderId, productId, Quantity) VALUES
('detail-001', 'order-001', 'prod-001', 1),
('detail-002', 'order-001', 'prod-002', 2),
('detail-003', 'order-002', 'prod-003', 1),
('detail-004', 'order-003', 'prod-001', 1);

-- Verify tables and data
SELECT 'Product Table' as TableName, COUNT(*) as RecordCount FROM dev.Product
UNION ALL
SELECT 'Customer Table', COUNT(*) FROM dev.Customer
UNION ALL
SELECT 'Orders Table', COUNT(*) FROM dev.Orders
UNION ALL
SELECT 'OrderDetails Table', COUNT(*) FROM dev.orderDetails;

-- Show binary log status
SHOW VARIABLES LIKE 'log_bin';
SHOW VARIABLES LIKE 'binlog_format';
SHOW VARIABLES LIKE 'binlog_row_image';

-- Show current binary log retention setting
-- SELECT * FROM mysql.rds_configuration WHERE configuration = 'binlog retention hours';

-- Test query to verify relationships
SELECT 
    c.Name as CustomerName,
    o.orderId,
    o.orderDate,
    p.productName,
    od.Quantity,
    p.price,
    (od.Quantity * p.price) as LineTotal
FROM dev.Customer c
JOIN dev.Orders o ON c.customerId = o.orderCustomerId
JOIN dev.orderDetails od ON o.orderId = od.orderId
JOIN dev.Product p ON od.productId = p.productId
ORDER BY o.orderDate, c.Name;
