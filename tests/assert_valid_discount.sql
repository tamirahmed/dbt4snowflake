{{ config(
    severity='warn'
) }}

SELECT

    order_item_id,
    discount

FROM {{ ref('stg_order_items') }}

WHERE discount < 0
   OR discount > 1