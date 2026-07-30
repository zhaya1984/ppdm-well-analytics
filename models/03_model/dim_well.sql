with well_enriched as (

    select *
    from {{ ref('int_well_enriched') }}

),

final as (

    select
        well_id,
        well_name,
        country,
        state_province,
        basin,
        well_profile,
        business_unit_code,
        jv_contract_name,
        santos_interest_pct,
        jv_mapping_status,
        well_source_last_updated_at

    from well_enriched

)

select *
from final