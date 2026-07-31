{{ config(
    materialized='table'
) }}

SELECT

    ROW_NUMBER() OVER (
        ORDER BY c.customer_id
    ) AS customer_key,


    c.customer_id,

    c.first_name,

    c.last_name,

    c.email,

    c.phone,

    c.city,

    c.region,

    c.signup_date,

    c.customer_segment,

    c.status,


    CASE
        WHEN q.customer_id IS NOT NULL
        THEN 'FAILED'
        ELSE 'VALID'
    END AS data_quality_status,


    q.issue_type AS data_quality_issue,


    CURRENT_TIMESTAMP() AS created_at


FROM {{ ref('stg_customers') }} c


LEFT JOIN (

    SELECT

        customer_id,

        LISTAGG(issue_type, ', ')
            WITHIN GROUP (ORDER BY issue_type) AS issue_type

    FROM {{ ref('quarantined_customers') }}

    GROUP BY customer_id

) q

ON c.customer_id = q.customer_id