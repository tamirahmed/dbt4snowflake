{{ config(
    materialized='incremental',
    unique_key='product_id'
) }}

SELECT

    product_id,
    product_name,
    category,
    supplier,
    cost,
    selling_price,
    active_flag,
    updated_at

FROM {{ source("raw", "products") }}


{% if is_incremental() %}

WHERE updated_at >=
(
    SELECT MAX(updated_at)
    FROM {{ this }}
)

{% endif %}