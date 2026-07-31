{{ config(
    severity='warn'
) }}

SELECT
    o.*,
    ARRAY_TO_STRING(
        ARRAY_CONSTRUCT_COMPACT(

            /* Duplicate order */
            IFF(
                EXISTS (
                    SELECT 1
                    FROM KIWIMART_DB.RAW.ORDERS o2
                    WHERE o2.order_id <> o.order_id
                      AND o2.customer_id = o.customer_id
                      AND o2.order_date = o.order_date
                ),
                'Duplicate Order',
                NULL
            ),

            /* Missing customer */
            IFF(
                o.customer_id IS NULL,
                'Missing Customer',
                NULL
            ),

            /* Invalid customer reference */
            IFF(
                o.customer_id IS NOT NULL
                AND c.customer_id IS NULL,
                'Invalid Customer',
                NULL
            ),

            /* Future order date */
            IFF(
                o.order_date > CURRENT_DATE(),
                'Future Order Date',
                NULL
            ),

            /* Invalid status */
            IFF(
                o.order_status NOT IN (
                    'Pending',
                    'Completed',
                    'Cancelled'
                ),
                'Invalid Order Status',
                NULL
            )

        ),
        ', '
    ) AS quality_issue_reason

FROM KIWIMART_DB.RAW.ORDERS o

LEFT JOIN KIWIMART_DB.RAW.CUSTOMERS c
    ON o.customer_id = c.customer_id

WHERE

    EXISTS (
        SELECT 1
        FROM KIWIMART_DB.RAW.ORDERS o2
        WHERE o2.order_id <> o.order_id
          AND o2.customer_id = o.customer_id
          AND o2.order_date = o.order_date
    )

    OR o.customer_id IS NULL

    OR (o.customer_id IS NOT NULL AND c.customer_id IS NULL)

    OR o.order_date > CURRENT_DATE()

    OR o.order_status NOT IN (
        'Returned',
        'Completed',
        'Cancelled'
    )