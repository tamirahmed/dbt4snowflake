{{ config(
    materialized='table'
) }}


-- Duplicate emails

SELECT

    customer_id,

    'DUPLICATE_EMAIL' AS error_code,

    'Customer email is duplicated' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_customers') }}

GROUP BY customer_id, email

HAVING COUNT(*) > 1



UNION ALL



-- Missing region

SELECT

    customer_id,

    'MISSING_REGION' AS error_code,

    'Customer region is missing' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_customers') }}

WHERE region IS NULL



UNION ALL



-- Missing phone

SELECT

    customer_id,

    'MISSING_PHONE' AS error_code,

    'Customer phone is missing' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_customers') }}

WHERE phone IS NULL



UNION ALL



-- Future signup date

SELECT

    customer_id,

    'FUTURE_SIGNUP_DATE' AS error_code,

    'Customer signup date is in the future' AS error_description,

    CURRENT_TIMESTAMP() AS detected_at

FROM {{ ref('stg_customers') }}

WHERE signup_date > CURRENT_DATE()