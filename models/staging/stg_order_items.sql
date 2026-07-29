{{ config(
    materialized='incremental',
    unique_key='order_item_id'
) }}

SELECT

    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount,
    updated_at

FROM {{ source("raw", "order_items") }}


{% if is_incremental() %}

WHERE updated_at >=
(
    SELECT MAX(updated_at)
    FROM {{ this }}
)

{% endif %}