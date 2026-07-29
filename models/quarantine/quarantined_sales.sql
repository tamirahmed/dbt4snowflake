{{ config(
    materialized='table'
) }}


-- =====================================================
-- ORDER LEVEL QUALITY ISSUES
-- =====================================================


-- Missing customer

SELECT

    o.order_id,

    NULL AS order_item_id,

    'ORDER' AS record_type,

    'MISSING_CUSTOMER' AS error_code,

    'Order has no customer reference' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_orders') }} o

WHERE o.customer_id IS NULL



UNION ALL



-- Invalid customer reference

SELECT

    o.order_id,

    NULL AS order_item_id,

    'ORDER' AS record_type,

    'INVALID_CUSTOMER_REFERENCE' AS error_code,

    'Customer does not exist in customer master' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_orders') }} o

LEFT JOIN {{ ref('stg_customers') }} c

    ON o.customer_id = c.customer_id

WHERE o.customer_id IS NOT NULL
AND c.customer_id IS NULL



UNION ALL



-- Future order date

SELECT

    o.order_id,

    NULL AS order_item_id,

    'ORDER' AS record_type,

    'FUTURE_ORDER_DATE' AS error_code,

    'Order date is greater than current date' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_orders') }} o

WHERE o.order_date > CURRENT_DATE()



UNION ALL



-- Duplicate order id

SELECT

    o.order_id,

    NULL AS order_item_id,

    'ORDER' AS record_type,

    'DUPLICATE_ORDER' AS error_code,

    'Duplicate order identifier detected' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_orders') }} o

GROUP BY o.order_id

HAVING COUNT(*) > 1



UNION ALL



-- =====================================================
-- ORDER ITEM LEVEL QUALITY ISSUES
-- =====================================================



-- Invalid quantity

SELECT

    oi.order_id,

    oi.order_item_id,

    'ORDER_ITEM' AS record_type,

    'INVALID_QUANTITY' AS error_code,

    'Quantity must be greater than zero' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_order_items') }} oi

WHERE oi.quantity <= 0



UNION ALL



-- Invalid product reference

SELECT

    oi.order_id,

    oi.order_item_id,

    'ORDER_ITEM' AS record_type,

    'INVALID_PRODUCT_REFERENCE' AS error_code,

    'Product does not exist in product master' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_order_items') }} oi

LEFT JOIN {{ ref('stg_products') }} p

    ON oi.product_id = p.product_id

WHERE p.product_id IS NULL



UNION ALL



-- Invalid discount

SELECT

    oi.order_id,

    oi.order_item_id,

    'ORDER_ITEM' AS record_type,

    'INVALID_DISCOUNT' AS error_code,

    'Discount must be between 0 and 1' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_order_items') }} oi

WHERE oi.discount < 0
   OR oi.discount > 1



UNION ALL



-- Selling below cost

SELECT

    oi.order_id,

    oi.order_item_id,

    'ORDER_ITEM' AS record_type,

    'SELLING_BELOW_COST' AS error_code,

    'Selling price is lower than product cost' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_order_items') }} oi

JOIN {{ ref('stg_products') }} p

    ON oi.product_id = p.product_id

WHERE oi.unit_price < p.cost