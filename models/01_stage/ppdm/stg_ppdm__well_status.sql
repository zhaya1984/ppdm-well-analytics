with source as (

    select *
    from {{ source('ppdm', 'well_status') }}

),

renamed as (

    select
        well_status_id::varchar as well_status_id,
        uwi::varchar as well_id,
        lifecycle::varchar as lifecycle,
        business_intention::varchar as business_intention,
        outcome::varchar as outcome,
        play_type::varchar as play_type,
        role::varchar as well_role,
        condition::varchar as well_condition,
        product_type::varchar as product_type,
        product_significance::varchar as product_significance,
        last_updated_at::timestamp_ntz as source_last_updated_at

    from source

)

select *
from renamed