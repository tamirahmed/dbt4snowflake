{{ config(
    materialized='incremental',
    unique_key='return_id'
) }}

SELECT

    return_id,
    order_id,
    product_id,
    return_date,
    return_reason,
    refund_amount,
    updated_at

FROM {{ source("raw", "returns") }}


{% if is_incremental() %}

WHERE updated_at >=
(
    SELECT MAX(updated_at)
    FROM {{ this }}
)

{% endif %}