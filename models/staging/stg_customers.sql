with
    customers as (
        select
            customer_id,
            first_name,
            last_name,
            lower(email) as email,
            phone,
            city,
            region,
            signup_date,
            customer_segment,
            status
        from {{ source("raw", "customers") }}
    )

select *
from customers
