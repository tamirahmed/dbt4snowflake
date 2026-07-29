{{ config(
    severity='warn'
) }}

SELECT

    order_id,
    COUNT(*) AS cnt

FROM {{ ref('stg_orders') }}

GROUP BY order_id

HAVING COUNT(*) > 1