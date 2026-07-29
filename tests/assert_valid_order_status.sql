{{ config(
    severity='warn'
) }}

SELECT

    order_id,
    order_status

FROM {{ ref('stg_orders') }}

WHERE order_status NOT IN
(
    'COMPLETED',
    'CANCELLED',
    'PENDING'
)