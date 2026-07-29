{{ config(
    severity='warn'
) }}

SELECT
    inventory_id,
    product_id,
    store_id,
    quantity_on_hand

FROM {{ ref('stg_inventory') }}

WHERE quantity_on_hand < 0