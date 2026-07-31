{{ config(
    materialized='incremental',
    unique_key='quality_issue_key'
) }}


-- =====================================================
-- CUSTOMER LEVEL QUALITY ISSUES
-- =====================================================


-- Duplicate emails

SELECT

    HASH(
        customer_id,
        'DUPLICATE_EMAIL'
    ) AS quality_issue_key,

    customer_id,

    updated_at AS source_updated_at,

    'DUPLICATE_EMAIL' AS error_code,

    'Customer email is duplicated' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_customers') }}

WHERE email IN
(
    SELECT email

    FROM {{ ref('stg_customers') }}

    WHERE email IS NOT NULL

    GROUP BY email

    HAVING COUNT(*) > 1
)


{% if is_incremental() %}

AND updated_at >
(
    SELECT MAX(source_updated_at)
    FROM {{ this }}
)

{% endif %}



UNION ALL



-- Missing region

SELECT

    HASH(
        customer_id,
        'MISSING_REGION'
    ) AS quality_issue_key,

    customer_id,

    updated_at AS source_updated_at,

    'MISSING_REGION' AS error_code,

    'Customer region is missing' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_customers') }}

WHERE region IS NULL


{% if is_incremental() %}

AND updated_at >
(
    SELECT MAX(source_updated_at)
    FROM {{ this }}
)

{% endif %}



UNION ALL



-- Missing phone

SELECT

    HASH(
        customer_id,
        'MISSING_PHONE'
    ) AS quality_issue_key,

    customer_id,

    updated_at AS source_updated_at,

    'MISSING_PHONE' AS error_code,

    'Customer phone is missing' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_customers') }}

WHERE phone IS NULL


{% if is_incremental() %}

AND updated_at >
(
    SELECT MAX(source_updated_at)
    FROM {{ this }}
)

{% endif %}



UNION ALL



-- Future signup date

SELECT

    HASH(
        customer_id,
        'FUTURE_SIGNUP_DATE'
    ) AS quality_issue_key,

    customer_id,

    updated_at AS source_updated_at,

    'FUTURE_SIGNUP_DATE' AS error_code,

    'Customer signup date is in the future' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_customers') }}

WHERE signup_date > CURRENT_DATE()


{% if is_incremental() %}

AND updated_at >
(
    SELECT MAX(source_updated_at)
    FROM {{ this }}
)

{% endif %}