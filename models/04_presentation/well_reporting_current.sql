

    select
        w.well_id,
        w.well_name,
        w.country,
        w.state_province,
        w.basin,
        w.well_profile,
        w.business_unit_code,
        w.jv_contract_name,
        w.santos_interest_pct,
        w.jv_mapping_status,

        s.well_status_id,

        -- Legacy classification
        s.current_class,
        s.current_status,
        s.well_intent,

        -- Multidimensional classification
        s.lifecycle,
        s.business_intention,
        s.outcome,
        s.play_type,
        s.well_role,
        s.well_condition,
        s.product_type,
        s.product_significance,


        w.well_source_last_updated_at,
        s.status_source_last_updated_at

    from {{ ref('dim_well') }} w

    left join {{ ref('well_current_status') }} s
        on w.well_id = s.well_id

