{{ config(
    materialized='incremental',
    unique_key='duplicate_issue_id'
) }}


WITH customers AS (
    SELECT
        customer_id,email,phone,updated_at
    FROM {{ source('raw','customers') }}

    {% if is_incremental() %}
    WHERE updated_at >= (
        SELECT COALESCE(MAX(source_updated_at), '1900-01-01')
        FROM {{ this }}
    )

    {% endif %}
),


duplicate_customers AS (
    -- Same email
    SELECT
        customer_id, 'DUPLICATE_EMAIL' AS issue_type,
        email AS duplicate_value,
        updated_at AS source_updated_at
    FROM customers
    WHERE email IS NOT NULL
    QUALIFY COUNT(*) OVER (PARTITION BY email) > 1

    UNION ALL

    -- Same phone
    SELECT
        customer_id,'DUPLICATE_PHONE' AS issue_type,
        phone AS duplicate_value,updated_at AS source_updated_at
    FROM customers
    WHERE phone IS NOT NULL
    QUALIFY COUNT(*) OVER (PARTITION BY phone) > 1

)

SELECT
    MD5(
        CONCAT(customer_id,issue_type,duplicate_value)
    ) AS duplicate_issue_id,
    customer_id,issue_type,duplicate_value,source_updated_at,
    CURRENT_TIMESTAMP() AS detected_at
FROM duplicate_customers