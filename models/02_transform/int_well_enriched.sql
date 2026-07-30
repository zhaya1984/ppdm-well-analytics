with wells as (

    select *
    from {{ ref('stg_ppdm__well') }}

),

well_statuses as (

    select *
    from {{ ref('stg_ppdm__well_status') }}

),

jv_interests as (

    select *
    from {{ ref('jv_interest') }}

),

joined as (

    select
        w.well_id,
        w.well_name,
        w.country,
        w.state_province,
        w.basin,
        w.current_class,
        w.current_status,
        w.well_intent,
        w.well_profile,
        w.business_unit_code,
        w.jv_contract_name,

        ws.well_status_id,
        ws.lifecycle,
        ws.business_intention,
        ws.outcome,
        ws.play_type,
        ws.well_role,
        ws.well_condition,
        ws.product_type,
        ws.product_significance,

        jv.santos_interest_pct,

        case
            when jv.jv_contract_name is null then 'UNMAPPED'
            else 'MAPPED'
        end as jv_mapping_status,

        w.source_last_updated_at as well_source_last_updated_at,
        ws.source_last_updated_at as status_source_last_updated_at

    from wells w

    left join well_statuses ws
        on w.well_id = ws.well_id

    left join jv_interests jv
        on w.jv_contract_name = jv.jv_contract_name

)

select *
from joined