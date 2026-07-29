{{ config(materialized='table') }}

SELECT

    ROW_NUMBER() OVER (ORDER BY store_id) AS store_key,

    store_id,

    store_name,

    city,

    region,

    manager,

    opened_date,

    CURRENT_TIMESTAMP() AS created_at

FROM {{ ref('stg_stores') }}