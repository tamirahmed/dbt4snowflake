{% snapshot snap_customer %}

{{
    config(
        unique_key='customer_id',
        strategy='check',
        check_cols=[
            'first_name',
            'last_name',
            'email',
            'phone',
            'city',
            'region',
            'customer_segment',
            'status'
        ]
    )
}}

select
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    region,
    signup_date,
    customer_segment,
    status
from {{ ref('dim_customer') }}

{% endsnapshot %}