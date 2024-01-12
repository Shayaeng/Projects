IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'sengbuying')
CREATE DATABASE sengbuying;
GO
USE sengbuying;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'buying_groups')
CREATE TABLE buying_groups (
    [id] INT IDENTITY (1,1) NOT NULL PRIMARY KEY,
    [name] VARCHAR(50) NOT NULL,
    acronym VARCHAR(10),
    [type] VARCHAR(50)
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'payout_methods')
CREATE TABLE payout_methods (
    method VARCHAR(50) NOT NULL PRIMARY KEY,
    [description] VARCHAR(250)
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'group_payouts')
CREATE TABLE group_payouts (
    group_id INT,
    method VARCHAR(50),
    PRIMARY KEY (group_id, method),
    FOREIGN KEY (group_id) REFERENCES buying_groups(id),
    FOREIGN KEY (method) REFERENCES payout_methods(method) 
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'retailers')
CREATE TABLE retailers (
    code VARCHAR(25) NOT NULL PRIMARY KEY,
    retailer VARCHAR(100) NOT NULL
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'issues')
CREATE TABLE issues (
    id INT IDENTITY (1,1) PRIMARY KEY,
    [description] VARCHAR(200)
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'orders')
CREATE TABLE orders (
    order_number VARCHAR(100) NOT NULL,
    item VARCHAR(250) NOT NULL,
    buying_group INT,
    retailer VARCHAR(25),
    quantity_number VARCHAR(10),
    tracking_number VARCHAR(100),
    group_price MONEY,
    retailer_price MONEY,
    payment_method VARCHAR(25),
    [status] BIT,
    issue INT,
    [date] DATE DEFAULT CAST(GETDATE() AS DATE)
    FOREIGN KEY (buying_group) REFERENCES buying_groups(id),
    FOREIGN KEY (retailer) REFERENCES retailers(code),
    FOREIGN KEY (issue) REFERENCES issues(id)
);
GO

