with source as (

    select *
    from {{ source('ppdm', 'well') }}

),

renamed as (

    select
        uwi::varchar as well_id,
        well_name::varchar as well_name,
        country::varchar as country,
        state_province::varchar as state_province,
        basin::varchar as basin,
        current_class::varchar as current_class,
        current_status::varchar as current_status,
        well_intent::varchar as well_intent,
        well_profile::varchar as well_profile,
        business_unit_code::varchar as business_unit_code,
        jv_contract_name::varchar as jv_contract_name,
        last_updated_at::timestamp_ntz as source_last_updated_at

    from source

)

select *
from renamed