{{ config(
    severity='warn'
) }}

SELECT *

FROM {{ ref('dim_customer') }}

WHERE data_quality_status = 'FAILED'