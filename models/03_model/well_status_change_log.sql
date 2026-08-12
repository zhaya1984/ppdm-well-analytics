{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['status_version_id', 'changed_field']
) }}
with affected_wells as (

select distinct well_id
from {{ ref('well_status_history') }}

{% if is_incremental() %}
where valid_from > dateadd(
    day,
    -7,
    (
        select coalesce(
            max(changed_at),
            '1900-01-01'::timestamp
        )
        from {{ this }}
    )
)
{% endif %}

),

version_comparison as (


    select
        h.well_id,
        h.status_version_id,

        lag(h.status_version_id) over (
            partition by h.well_id
            order by h.valid_from
        ) as previous_status_version_id,

        h.well_status_id,
        h.valid_from as changed_at,

        lag(h.lifecycle) over (
            partition by h.well_id
            order by h.valid_from
        ) as previous_lifecycle,
        h.lifecycle,

        lag(h.business_intention) over (
            partition by h.well_id
            order by h.valid_from
        ) as previous_business_intention,
        h.business_intention,

        lag(h.outcome) over (
            partition by h.well_id
            order by h.valid_from
        ) as previous_outcome,
        h.outcome,

        lag(h.play_type) over (
            partition by h.well_id
            order by h.valid_from
        ) as previous_play_type,
        h.play_type,

        lag(h.well_role) over (
            partition by h.well_id
            order by h.valid_from
        ) as previous_well_role,
        h.well_role,

        lag(h.well_condition) over (
            partition by h.well_id
            order by h.valid_from
        ) as previous_well_condition,
        h.well_condition,

        lag(h.product_type) over (
            partition by h.well_id
            order by h.valid_from
        ) as previous_product_type,
        h.product_type,

        lag(h.product_significance) over (
            partition by h.well_id
            order by h.valid_from
        ) as previous_product_significance,
        h.product_significance,

        h.source_last_updated_at


    from {{ ref('well_status_history') }} h

inner join affected_wells a
    on h.well_id = a.well_id

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
from classified_changes
