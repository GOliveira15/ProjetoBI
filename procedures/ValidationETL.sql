--> Prod
SELECT COUNT(*) FROM [stg].[Prod_brands] --> 9
SELECT COUNT(*) FROM [dw].[Prod_DIM_Brands] --> 9

SELECT COUNT(*) FROM [stg].[Prod_categories] --> 7
SELECT COUNT(*) FROM [dw].[Prod_DIM_Categories] --> 7

SELECT COUNT(*) FROM [stg].[Prod_products] --> 321
SELECT COUNT(*) FROM [dw].[Prod_DIM_Products] --> 321

SELECT COUNT(*) FROM [stg].[Prod_stocks] --> 939
SELECT COUNT(*) FROM [dw].[Prod_FACT_Stocks] --> 939

--> Sales
SELECT COUNT(*) FROM [stg].[Sales_Customers] --> 1445
SELECT COUNT(*) FROM [dw].[Sales_DIM_Customers] --> 1445

SELECT COUNT(*) FROM [stg].[Sales_stores] --> 3
SELECT COUNT(*) FROM [dw].[Sales_DIM_Stores] --> 3

SELECT COUNT(*) FROM [stg].[Sales_staffs] --> 10
SELECT COUNT(*) FROM [dw].[Sales_DIM_Staffs] --> 10

SELECT COUNT(*) FROM [stg].[Sales_orders] --> 1615
SELECT COUNT(*) FROM [dw].[Sales_FACT_Orders] --> 1615

SELECT COUNT(*) FROM [stg].[Sales_order_items] --> 4722
SELECT COUNT(*) FROM [dw].[Sales_FACT_OrderItems] --> 4722

--> DW
SELECT * FROM [dw].[Prod_DIM_Brands]
SELECT * FROM [dw].[Prod_DIM_Categories]
SELECT * FROM [dw].[Prod_DIM_Products]
SELECT * FROM [dw].[Prod_FACT_Stocks]

SELECT * FROM [dw].[Sales_DIM_Customers]
SELECT * FROM [dw].[Sales_DIM_Stores]
SELECT * FROM [dw].[Sales_DIM_Staffs]
SELECT * FROM [dw].[Sales_FACT_OrderItems]
SELECT * FROM [dw].[Sales_FACT_Orders]