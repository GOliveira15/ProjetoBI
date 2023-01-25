SELECT
TABLE_SCHEMA,
TABLE_NAME

FROM
INFORMATION_SCHEMA.TABLES

WHERE
TABLE_SCHEMA = 'sales' AND

TABLE_NAME in (
    'customers',
    'order_items',
    'orders',
    'staffs',
    'stores'
)

SELECT
TABLE_SCHEMA,
TABLE_NAME

FROM
INFORMATION_SCHEMA.TABLES

WHERE
TABLE_SCHEMA = 'production' AND

TABLE_NAME in (
    'brands',
    'categories',
    'products',
    'stocks'
)