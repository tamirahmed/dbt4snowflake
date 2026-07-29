{{ config(
    materialized='incremental',
    unique_key='store_id'
) }}

SELECT

    store_id,
    store_name,
    city,
    region,
    manager,
    opened_date,
    updated_at

FROM {{ source("raw", "stores") }}


{% if is_incremental() %}

WHERE updated_at >=
(
    SELECT MAX(updated_at)
    FROM {{ this }}
)

{% endif %}