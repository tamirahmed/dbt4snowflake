{{ config(
    materialized='incremental',
    unique_key='order_item_id'
) }}

SELECT

    ROW_NUMBER() OVER (
        ORDER BY oi.order_item_id
    ) AS sales_key,


    -- Degenerate dimensions
    o.order_id,
    oi.order_item_id,

    o.order_date,


    -- Dimension keys
    c.customer_key,
    p.product_key,
    s.store_key,


    -- Measures
    oi.quantity,

    oi.unit_price,

    oi.discount,


    -- Revenue calculations
    oi.quantity * oi.unit_price 
        AS gross_sales_amount,


    (oi.quantity * oi.unit_price) 
        * COALESCE(oi.discount,0) 
        AS discount_amount,


    (oi.quantity * oi.unit_price)
        -
    ((oi.quantity * oi.unit_price) 
        * COALESCE(oi.discount,0))
        AS net_sales_amount,


    -- Cost
    oi.quantity * p.cost
        AS cost_amount,


    -- Profit
    (
        (oi.quantity * oi.unit_price)
        -
        ((oi.quantity * oi.unit_price) 
        * COALESCE(oi.discount,0))
    )
    -
    (oi.quantity * p.cost)
        AS profit_amount,


    -- Operational attributes
    o.sales_channel,

    o.payment_method,

    o.order_status,


    CURRENT_TIMESTAMP() AS created_at


FROM {{ ref('stg_orders') }} o


INNER JOIN {{ ref('stg_order_items') }} oi
    ON o.order_id = oi.order_id


LEFT JOIN {{ ref('dim_customer') }} c
    ON o.customer_id = c.customer_id


LEFT JOIN {{ ref('dim_product') }} p
    ON oi.product_id = p.product_id


LEFT JOIN {{ ref('dim_store') }} s
    ON o.store_id = s.store_id

LEFT JOIN {{ ref('quarantined_sales') }} q
    ON o.order_id = q.order_id


WHERE 1=1
AND q.order_id IS NULL
AND q.order_id IS NULL


{% if is_incremental() %}

AND o.order_date >
(
    SELECT MAX(order_date)
    FROM {{ this }}
)

{% endif %}