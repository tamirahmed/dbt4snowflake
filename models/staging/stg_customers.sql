{{ config(
    materialized='incremental',
    unique_key='customer_id'
) }}

WITH customers AS (

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

    WHERE updated_at >= (
        SELECT max_updated_at
        FROM (
            SELECT MAX(updated_at) AS max_updated_at
            FROM {{ this }}
        )
    )

    {% endif %}

)

SELECT *
FROM customers