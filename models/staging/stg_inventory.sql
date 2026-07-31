{{ config(
    materialized='incremental',
    unique_key='inventory_id'
) }}

SELECT

    inventory_id,
    product_id,
    store_id,
    quantity_on_hand,
    reorder_level,
    updated_at

FROM {{ source("raw", "inventory") }}


{% if is_incremental() %}

WHERE updated_at >=
(
    SELECT MAX(updated_at)
    FROM {{ this }}
)

{% endif %}