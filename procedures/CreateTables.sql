CREATE SCHEMA dw;
go

CREATE SCHEMA stg;
go

--> Sales <--

--> Customers
DROP TABLE IF EXISTS [dw].[Sales_DIM_Customers]
GO

CREATE TABLE [dw].[Sales_DIM_Customers](
    [SKCustomer] [int] IDENTITY NOT NULL,
    [NKCustomer] [varchar](500) NOT NULL,
    [FirstName] [varchar](250) NOT NULL,
    [LastName] [varchar](250) NOT NULL,
    [Phone] [varchar](50) NOT NULL,
    [Email] [varchar](100) NOT NULL,
    [Street] [varchar](100) NOT NULL,
    [City] [varchar](100) NOT NULL,
    [State] [varchar](100) NOT NULL,
    [ZipCode] [varchar](50) NOT NULL,
    [InsertDate] [datetime] NOT NULL,
    [UpdatedDate] [datetime] NULL,
    [isActive] [bit] NOT NULL
)

SELECT * FROM [dw].[Sales_DIM_Customers]
GO

--> Stores
DROP TABLE IF EXISTS [dw].[Sales_DIM_Stores]
GO

CREATE TABLE [dw].[Sales_DIM_Stores](
    [SKStore] [int] IDENTITY NOT NULL,
    [NKStore] [varchar](500) NOT NULL,
    [StoreName] [varchar](250) NOT NULL,
    [Phone] [varchar](50) NOT NULL,
    [Email] [varchar](100) NOT NULL,
    [Street] [varchar](100) NOT NULL,
    [City] [varchar](100) NOT NULL,
    [State] [varchar](100) NOT NULL,
    [ZipCode] [varchar](50) NOT NULL,
    [InsertDate] [datetime] NOT NULL,
    [UpdatedDate] [datetime] NULL,
    [isActive] [bit] NOT NULL
)

SELECT * FROM [dw].[Sales_DIM_Stores]
GO

--> Staffs
DROP TABLE IF EXISTS [dw].[Sales_DIM_Staffs]
GO

CREATE TABLE [dw].[Sales_DIM_Staffs](
    [SKStaff] [int] IDENTITY NOT NULL,
    [NKStaff] [varchar](500) NOT NULL,
    [FirstName] [varchar](250) NOT NULL,
    [LastName] [varchar](250) NOT NULL,
    [Email] [varchar](100) NOT NULL,
    [Phone] [varchar](50) NOT NULL,
    [Active] [bit] NOT NULL,
    [SKStore] [int] NOT NULL,
    [SKManager] [int] NOT NULL,
    [InsertDate] [datetime] NOT NULL,
    [UpdatedDate] [datetime] NULL,
    [isActive] [bit] NOT NULL
)

SELECT * FROM [dw].[Sales_DIM_Staffs]
GO

--> Orders
DROP TABLE IF EXISTS [dw].[Sales_FACT_Orders]
GO

CREATE TABLE [dw].[Sales_FACT_Orders](
    [SKOrder] [int] IDENTITY NOT NULL,
    [NKOrder] [varchar](500) NOT NULL,
    [SKCustomer] [int] NOT NULL,
    [OrderStatus] [int] NOT NULL,
    [OrderDate] [datetime] NOT NULL,
    [RequiredDate] [datetime] NOT NULL,
    [ShippedDate] [datetime] NOT NULL,
    [SKStore] [int] NOT NULL,
    [SKStaff] [int] NOT NULL,
    [InsertDate] [datetime] NOT NULL,
    [UpdatedDate] [datetime] NULL,
    [isActive] [bit] NOT NULL
)

SELECT * FROM [dw].[Sales_FACT_Orders]
GO

--> Prod <--

--> Brands
DROP TABLE IF EXISTS [dw].[Prod_DIM_Brands]
GO

CREATE TABLE [dw].[Prod_DIM_Brands](
    [SKBrand] [int] IDENTITY NOT NULL,
    [NKBrand] [varchar](500) NOT NULL,
    [BrandName] [varchar](250) NOT NULL,
    [InsertDate] [datetime] NOT NULL,
    [UpdatedDate] [datetime] NULL,
    [isActive] [bit] NOT NULL
)

SELECT * FROM [dw].[Prod_DIM_Brands]
GO

--> Categories
DROP TABLE IF EXISTS [dw].[Prod_DIM_Categories]
GO

CREATE TABLE [dw].[Prod_DIM_Categories](
    [SKCategory] [int] IDENTITY NOT NULL,
    [NKCategory] [varchar](500) NOT NULL,
    [CategoryName] [varchar](250) NOT NULL,
    [InsertDate] [datetime] NOT NULL,
    [UpdatedDate] [datetime] NULL,
    [isActive] [bit] NOT NULL
)

SELECT * FROM [dw].[Prod_DIM_Categories]
GO

--> Products
DROP TABLE IF EXISTS [dw].[Prod_DIM_Products]
GO

CREATE TABLE [dw].[Prod_DIM_Products](
    [SKProduct] [int] IDENTITY NOT NULL,
    [NKProduct] [varchar](500) NOT NULL,
    [ProductName] [varchar](250) NOT NULL,
    [SKBrand] [int] NOT NULL,
    [SKCategory] [int] NOT NULL,
    [ModelYear] [int] NOT NULL,
    [ListPrice] [decimal](18,2) NOT NULL,
    [InsertDate] [datetime] NOT NULL,
    [UpdatedDate] [datetime] NULL,
    [isActive] [bit] NOT NULL
)

SELECT * FROM [dw].[Prod_DIM_Products]
GO

--> Para controle <--

--> OrderItems
DROP TABLE IF EXISTS [dw].[Sales__OrderItems]
GO

CREATE TABLE [dw].[Sales__OrderItems](
    [SKOrder] [int] NOT NULL,
    [SKItem] [int] IDENTITY NOT NULL,
    [SKProduct] [int] NOT NULL,
    [Quantity] [int] NOT NULL,
    [ListPrice] [decimal](18,2) NOT NULL,
    [Discount] [decimal](18,2) NOT NULL,
    [InsertDate] [datetime] NOT NULL,
    [UpdatedDate] [datetime] NULL,
    [isActive] [bit] NOT NULL
)

SELECT * FROM [dw].[Sales__OrderItems]
GO

--> Stocks
DROP TABLE IF EXISTS [dw].[Prod__Stocks]
GO

CREATE TABLE [dw].[Prod__Stocks](
    [SKStore] [int] NOT NULL,
    [SKProduct] [int] NOT NULL,
    [Quantity] [int] NOT NULL,
    [InsertDate] [datetime] NOT NULL,
    [UpdatedDate] [datetime] NULL,
    [isActive] [bit] NOT NULL
)

SELECT * FROM [dw].[Prod__Stocks]
GO