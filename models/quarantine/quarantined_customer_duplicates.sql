{{ config(
    materialized='incremental',
    unique_key='quality_issue_id'
) }}


WITH changed_customers AS (

    SELECT *

    FROM {{ source('raw','customers') }}

    {% if is_incremental() %}

    WHERE updated_at >= (
        SELECT MAX(updated_at)
        FROM {{ this }}
    )

    {% endif %}

),


duplicate_emails AS (

    SELECT
        c.email

    FROM {{ source('raw','customers') }} c

    INNER JOIN changed_customers cc
        ON c.email = cc.email

    WHERE c.email IS NOT NULL

    GROUP BY c.email

    HAVING COUNT(*) > 1

),


duplicate_phones AS (

    SELECT
        c.phone

    FROM {{ source('raw','customers') }} c

    INNER JOIN changed_customers cc
        ON c.phone = cc.phone

    WHERE c.phone IS NOT NULL

    GROUP BY c.phone

    HAVING COUNT(*) > 1

),


email_issues AS (

    SELECT

        c.customer_id,

        'DUPLICATE_EMAIL' AS issue_type,

        'Email exists on multiple customers' AS issue_description,

        c.email AS duplicate_value,

        c.updated_at

    FROM {{ source('raw','customers') }} c

    INNER JOIN duplicate_emails d
        ON c.email = d.email

),


phone_issues AS (

    SELECT

        c.customer_id,

        'DUPLICATE_PHONE' AS issue_type,

        'Phone exists on multiple customers' AS issue_description,

        c.phone AS duplicate_value,

        c.updated_at

    FROM {{ source('raw','customers') }} c

    INNER JOIN duplicate_phones d
        ON c.phone = d.phone

)


SELECT

    MD5(
        CONCAT(
            customer_id,
            issue_type,
            duplicate_value
        )
    ) AS quality_issue_id,

    customer_id,
    issue_type,
    issue_description,
    duplicate_value,
    updated_at,

    CURRENT_TIMESTAMP() AS detected_at


FROM email_issues


UNION ALL


SELECT

    MD5(
        CONCAT(
            customer_id,
            issue_type,
            duplicate_value
        )
    ),

    customer_id,
    issue_type,
    issue_description,
    duplicate_value,
    updated_at,
    CURRENT_TIMESTAMP()

FROM phone_issues