{{ config(
    materialized='incremental',
    unique_key='customer_id'
) }}

SELECT

    customer_id,
    first_name,
    last_name,
    LOWER(email) AS email,
    phone,
    city,
    region,
    signup_date,
    customer_segment,
    status,
    updated_at

FROM {{ source("raw", "customers") }}


{% if is_incremental() %}

WHERE updated_at >=
(
    SELECT MAX(updated_at)
    FROM {{ this }}
)

{% endif %}