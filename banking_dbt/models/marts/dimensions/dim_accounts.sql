{{config(materialized='table')}}

with latest as (
    SELECT
        account_id
        customer_id,
        account_type,
        balance,
        currency,
        created_at,
        dbt_valid_from as effective_from,
        dbt_valid_to as effective_to,
        CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current
    FROM {{ref('accounts_snapshot')}}
)

SELECT * FROM latest