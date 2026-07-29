{{ config(
    severity='warn'
) }}

SELECT

    i.inventory_id,
    i.product_id

FROM {{ ref('stg_inventory') }} i

LEFT JOIN {{ ref('stg_products') }} p

    ON i.product_id = p.product_id

WHERE p.product_id IS NULL