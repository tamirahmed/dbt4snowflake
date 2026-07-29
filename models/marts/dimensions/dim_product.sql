{{ config(materialized='table') }}

SELECT

    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,

    product_id,

    product_name,

    category,

    supplier,

    cost,

    selling_price,

    selling_price - cost AS unit_profit,

    CASE
        WHEN selling_price > 0
        THEN ROUND(((selling_price - cost) / selling_price) * 100, 2)
        ELSE 0
    END AS profit_margin_pct,

    active_flag,

    CURRENT_TIMESTAMP() AS created_at

FROM {{ ref('stg_products') }}