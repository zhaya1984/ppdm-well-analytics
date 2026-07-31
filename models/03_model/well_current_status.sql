with well_enriched as (

    select *
    from {{ ref('int_well_enriched') }}

),

final as (

    select
        well_id,
        well_status_id,

        -- Legacy well classification
        current_class,
        current_status,
        well_intent,

        -- Target multidimensional classification
        lifecycle,
        business_intention,
        outcome,
        play_type,
        well_role,
        well_condition,
        product_type,
        product_significance,

        status_source_last_updated_at

    from well_enriched

)

select *
from final