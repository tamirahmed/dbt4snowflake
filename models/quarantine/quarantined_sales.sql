{{ config(
    materialized='incremental',
    unique_key='quality_issue_key'
) }}


-- =====================================================
-- ORDER LEVEL QUALITY ISSUES
-- =====================================================


-- Missing customer

SELECT

    HASH(
        'ORDER',
        o.order_id,
        NULL,
        'MISSING_CUSTOMER'
    ) AS quality_issue_key,

    o.order_id,

    NULL AS order_item_id,

    'ORDER' AS record_type,

    o.updated_at AS source_updated_at,

    'MISSING_CUSTOMER' AS error_code,

    'Order has no customer reference' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_orders') }} o

WHERE o.customer_id IS NULL


{% if is_incremental() %}

AND o.updated_at >
(
    SELECT MAX(source_updated_at)
    FROM {{ this }}
)

{% endif %}



UNION ALL



-- Invalid customer reference

SELECT

    HASH(
        'ORDER',
        o.order_id,
        NULL,
        'INVALID_CUSTOMER_REFERENCE'
    ) AS quality_issue_key,

    o.order_id,

    NULL AS order_item_id,

    'ORDER' AS record_type,

    o.updated_at AS source_updated_at,

    'INVALID_CUSTOMER_REFERENCE' AS error_code,

    'Customer does not exist in customer master' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_orders') }} o

LEFT JOIN {{ ref('stg_customers') }} c

    ON o.customer_id = c.customer_id

WHERE o.customer_id IS NOT NULL
AND c.customer_id IS NULL


{% if is_incremental() %}

AND o.updated_at >
(
    SELECT MAX(source_updated_at)
    FROM {{ this }}
)

{% endif %}



UNION ALL



-- Future order date

SELECT

    HASH(
        'ORDER',
        o.order_id,
        NULL,
        'FUTURE_ORDER_DATE'
    ) AS quality_issue_key,

    o.order_id,

    NULL AS order_item_id,

    'ORDER' AS record_type,

    o.updated_at AS source_updated_at,

    'FUTURE_ORDER_DATE' AS error_code,

    'Order date is greater than current date' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_orders') }} o

WHERE o.order_date > CURRENT_DATE()


{% if is_incremental() %}

AND o.updated_at >
(
    SELECT MAX(source_updated_at)
    FROM {{ this }}
)

{% endif %}



UNION ALL



-- Duplicate order id

SELECT

    HASH(
        'ORDER',
        o.order_id,
        NULL,
        'DUPLICATE_ORDER'
    ) AS quality_issue_key,

    o.order_id,

    NULL AS order_item_id,

    'ORDER' AS record_type,

    MAX(o.updated_at) AS source_updated_at,

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

    HASH(
        'ORDER_ITEM',
        oi.order_id,
        oi.order_item_id,
        'INVALID_QUANTITY'
    ) AS quality_issue_key,

    oi.order_id,

    oi.order_item_id,

    'ORDER_ITEM' AS record_type,

    oi.updated_at AS source_updated_at,

    'INVALID_QUANTITY' AS error_code,

    'Quantity must be greater than zero' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_order_items') }} oi

WHERE oi.quantity <= 0


{% if is_incremental() %}

AND oi.updated_at >
(
    SELECT MAX(source_updated_at)
    FROM {{ this }}
)

{% endif %}



UNION ALL



-- Invalid product reference

SELECT

    HASH(
        'ORDER_ITEM',
        oi.order_id,
        oi.order_item_id,
        'INVALID_PRODUCT_REFERENCE'
    ) AS quality_issue_key,

    oi.order_id,

    oi.order_item_id,

    'ORDER_ITEM' AS record_type,

    oi.updated_at AS source_updated_at,

    'INVALID_PRODUCT_REFERENCE' AS error_code,

    'Product does not exist in product master' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_order_items') }} oi

LEFT JOIN {{ ref('stg_products') }} p

    ON oi.product_id = p.product_id

WHERE p.product_id IS NULL


{% if is_incremental() %}

AND oi.updated_at >
(
    SELECT MAX(source_updated_at)
    FROM {{ this }}
)

{% endif %}



UNION ALL



-- Invalid discount

SELECT

    HASH(
        'ORDER_ITEM',
        oi.order_id,
        oi.order_item_id,
        'INVALID_DISCOUNT'
    ) AS quality_issue_key,

    oi.order_id,

    oi.order_item_id,

    'ORDER_ITEM' AS record_type,

    oi.updated_at AS source_updated_at,

    'INVALID_DISCOUNT' AS error_code,

    'Discount must be between 0 and 1' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_order_items') }} oi

WHERE oi.discount < 0
   OR oi.discount > 1


{% if is_incremental() %}

AND oi.updated_at >
(
    SELECT MAX(source_updated_at)
    FROM {{ this }}
)

{% endif %}



UNION ALL



-- Selling below cost

SELECT

    HASH(
        'ORDER_ITEM',
        oi.order_id,
        oi.order_item_id,
        'SELLING_BELOW_COST'
    ) AS quality_issue_key,

    oi.order_id,

    oi.order_item_id,

    'ORDER_ITEM' AS record_type,

    oi.updated_at AS source_updated_at,

    'SELLING_BELOW_COST' AS error_code,

    'Selling price is lower than product cost' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_order_items') }} oi

JOIN {{ ref('stg_products') }} p

    ON oi.product_id = p.product_id

WHERE oi.unit_price < p.cost


{% if is_incremental() %}

AND oi.updated_at >
(
    SELECT MAX(source_updated_at)
    FROM {{ this }}
)

{% endif %}