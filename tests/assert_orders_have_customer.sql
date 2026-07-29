{{ config(
    severity='warn'
) }}

SELECT

    order_id,
    customer_id

FROM {{ ref('stg_orders') }}

WHERE customer_id IS NULL