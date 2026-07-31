{{ config(
    materialized='incremental',
    unique_key='quality_issue_id'
) }}


WITH customers AS (

    SELECT
        customer_id,first_name,last_name,email,phone,region,status,signup_date,updated_at
    FROM {{ source('raw','customers') }}

    {% if is_incremental() %}
    WHERE updated_at >= (
        SELECT COALESCE(MAX(updated_at), '1900-01-01')
        FROM {{ this }}
    )
    {% endif %}

),


issues AS (

    -- Missing phone
    SELECT
        customer_id,
        'MISSING_PHONE' AS issue_type,
        'Phone number is missing' AS issue_description,
        updated_at
    FROM customers
    WHERE phone IS NULL

    UNION ALL
    -- Missing region
    SELECT
        customer_id,'MISSING_REGION','Region is missing',
        updated_at
    FROM customers
    WHERE region IS NULL

    UNION ALL
    -- Invalid email
    SELECT
        customer_id,'INVALID_EMAIL','Email format is invalid',
        updated_at
    FROM customers
    WHERE email IS NULL OR email NOT LIKE '%@%'

    UNION ALL
    -- Invalid status
    SELECT
        customer_id,'INVALID_STATUS','Customer status is invalid',updated_at
    FROM customers
    WHERE status IS NULL OR status NOT IN ('Active','Inactive')

    UNION ALL

    -- Future signup date
    SELECT
        customer_id,'FUTURE_SIGNUP_DATE','Signup date is in the future',updated_at
    FROM customers
    WHERE signup_date > CURRENT_DATE()

)


SELECT
    MD5(
        CONCAT(
            COALESCE(customer_id,'UNKNOWN'),issue_type,updated_at
        )
    ) AS quality_issue_id,
    customer_id,issue_type,issue_description,updated_at,CURRENT_TIMESTAMP() AS detected_at
FROM issues