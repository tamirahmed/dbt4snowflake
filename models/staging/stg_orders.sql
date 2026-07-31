{{ config(
    materialized='incremental',
    unique_key='order_id'
) }}

SELECT

    order_id,
    customer_id,
    order_date,
    store_id,
    sales_channel,
    payment_method,
    order_status,
    updated_at

FROM {{ source("raw", "orders") }}


{% if is_incremental() %}

WHERE updated_at >=
(
    SELECT MAX(updated_at)
    FROM {{ this }}
)

{% endif %}