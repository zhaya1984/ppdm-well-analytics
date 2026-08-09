with snapshot_versions as (

    select
        well_id,
        lifecycle,
        valid_from,
        source_last_updated_at,
        status_version_id,

        lag(lifecycle) over (
            partition by well_id
            order by valid_from
        ) as previous_lifecycle,

        row_number() over (
            partition by well_id
            order by valid_from
        ) as version_sequence

    from {{ ref('well_status_history') }}

),

lifecycle_change_points as (

    select
        well_id,
        lifecycle,
        valid_from,
        source_last_updated_at,
        status_version_id

    from snapshot_versions

    where version_sequence = 1
       or lifecycle is distinct from previous_lifecycle

),

lifecycle_periods as (

    select
        well_id,
        lifecycle,

        valid_from as snapshot_valid_from,

        lead(valid_from) over (
            partition by well_id
            order by valid_from
        ) as snapshot_valid_to,

        source_last_updated_at,
        status_version_id as starting_status_version_id

    from lifecycle_change_points

)

select
    well_id,
    lifecycle,
    snapshot_valid_from,
    snapshot_valid_to,

    case
        when snapshot_valid_to is null then true
        else false
    end as is_current,

    source_last_updated_at,
    starting_status_version_id

from lifecycle_periods