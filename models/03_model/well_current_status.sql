with wells as (

    select *
    from {{ ref('stg_ppdm__well') }}

),

well_status as (

    select *
    from {{ ref('stg_ppdm__well_status') }}

)

select
    s.well_id,
    s.well_status_id,

    -- Legacy classification from WELL
    w.current_class,
    w.current_status,
    w.well_intent,

    -- Multidimensional classification from WELL_STATUS
    s.lifecycle,
    s.business_intention,
    s.outcome,
    s.play_type,
    s.well_role,
    s.well_condition,
    s.product_type,
    s.product_significance,

    s.source_last_updated_at as status_source_last_updated_at

from well_status s

left join wells w
    on s.well_id = w.well_id