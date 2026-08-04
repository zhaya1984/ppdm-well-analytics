with wells as (

    select *
    from {{ ref('stg_ppdm__well') }}

),

jv_interest_mapping as (

    select *
    from {{ ref('jv_interest') }}

)

select
    w.well_id,
    w.well_name,
    w.country,
    w.state_province,
    w.basin,
    w.well_profile,
    w.business_unit_code,
    w.jv_contract_name,

    j.santos_interest_pct,

    case
        when j.jv_contract_name is not null then 'MAPPED'
        else 'UNMAPPED'
    end as jv_mapping_status,

    w.source_last_updated_at as well_source_last_updated_at

from wells w

left join jv_interest_mapping j
    on w.jv_contract_name = j.jv_contract_name