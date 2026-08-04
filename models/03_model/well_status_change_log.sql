with version_comparison as (

    select
        well_id,
        status_version_id,

        lag(status_version_id) over (
            partition by well_id
            order by valid_from
        ) as previous_status_version_id,

        well_status_id,
        valid_from as changed_at,

        lag(lifecycle) over (
            partition by well_id
            order by valid_from
        ) as previous_lifecycle,
        lifecycle,

        lag(business_intention) over (
            partition by well_id
            order by valid_from
        ) as previous_business_intention,
        business_intention,

        lag(outcome) over (
            partition by well_id
            order by valid_from
        ) as previous_outcome,
        outcome,

        lag(play_type) over (
            partition by well_id
            order by valid_from
        ) as previous_play_type,
        play_type,

        lag(well_role) over (
            partition by well_id
            order by valid_from
        ) as previous_well_role,
        well_role,

        lag(well_condition) over (
            partition by well_id
            order by valid_from
        ) as previous_well_condition,
        well_condition,

        lag(product_type) over (
            partition by well_id
            order by valid_from
        ) as previous_product_type,
        product_type,

        lag(product_significance) over (
            partition by well_id
            order by valid_from
        ) as previous_product_significance,
        product_significance,

        source_last_updated_at

    from {{ ref('well_status_history') }}

)

, change_log as (

    select
        well_id,
        status_version_id,
        previous_status_version_id,
        well_status_id,
        changed_at,
        'lifecycle' as changed_field,
        previous_lifecycle as old_value,
        lifecycle as new_value
    from version_comparison
    where previous_status_version_id is not null
      and previous_lifecycle is distinct from lifecycle

    union all

    select
        well_id,
        status_version_id,
        previous_status_version_id,
        well_status_id,
        changed_at,
        'business_intention' as changed_field,
        previous_business_intention as old_value,
        business_intention as new_value
    from version_comparison
    where previous_status_version_id is not null
      and previous_business_intention is distinct from business_intention

    union all

    select
        well_id,
        status_version_id,
        previous_status_version_id,
        well_status_id,
        changed_at,
        'outcome' as changed_field,
        previous_outcome as old_value,
        outcome as new_value
    from version_comparison
    where previous_status_version_id is not null
      and previous_outcome is distinct from outcome

    union all

    select
        well_id,
        status_version_id,
        previous_status_version_id,
        well_status_id,
        changed_at,
        'play_type' as changed_field,
        previous_play_type as old_value,
        play_type as new_value
    from version_comparison
    where previous_status_version_id is not null
      and previous_play_type is distinct from play_type

    union all

    select
        well_id,
        status_version_id,
        previous_status_version_id,
        well_status_id,
        changed_at,
        'well_role' as changed_field,
        previous_well_role as old_value,
        well_role as new_value
    from version_comparison
    where previous_status_version_id is not null
      and previous_well_role is distinct from well_role

    union all

    select
        well_id,
        status_version_id,
        previous_status_version_id,
        well_status_id,
        changed_at,
        'well_condition' as changed_field,
        previous_well_condition as old_value,
        well_condition as new_value
    from version_comparison
    where previous_status_version_id is not null
      and previous_well_condition is distinct from well_condition

    union all

    select
        well_id,
        status_version_id,
        previous_status_version_id,
        well_status_id,
        changed_at,
        'product_type' as changed_field,
        previous_product_type as old_value,
        product_type as new_value
    from version_comparison
    where previous_status_version_id is not null
      and previous_product_type is distinct from product_type

    union all

    select
        well_id,
        status_version_id,
        previous_status_version_id,
        well_status_id,
        changed_at,
        'product_significance' as changed_field,
        previous_product_significance as old_value,
        product_significance as new_value
    from version_comparison
    where previous_status_version_id is not null
      and previous_product_significance is distinct from product_significance

) , 

classified_changes as (

    select
        *,
        case
            when old_value is null and new_value is not null
                then 'VALUE_POPULATED'

            when old_value is not null and new_value is null
                then 'VALUE_CLEARED'

            when upper(trim(old_value)) = upper(trim(new_value))
                 and old_value is distinct from new_value
                then 'FORMAT_ONLY_CHANGE'

            else 'VALUE_CHANGE'
        end as change_type

    from change_log

)


select *
from change_log