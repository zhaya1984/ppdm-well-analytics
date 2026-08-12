with coverage as (

    select *
    from {{ ref('well_lifecycle_native_snapshot_coverage') }}

)

select
    native_status_id,
    well_id,
    native_lifecycle,
    native_effective_date,
    native_expiry_date,
    native_active_ind,

    first_snapshot_observed_at,

    snapshot_lifecycle,
    snapshot_valid_from,
    snapshot_valid_to,
    starting_status_version_id,

    coverage_status as observation_coverage_status,

    case
        when snapshot_lifecycle is not null
         and snapshot_valid_from::date = native_effective_date
            then true
        else false
    end as start_boundary_matches,

    case
        when snapshot_lifecycle is not null
         and coalesce(
                snapshot_valid_to::date,
                '9999-12-31'::date
             )
             =
             coalesce(
                native_expiry_date,
                '9999-12-31'::date
             )
            then true
        else false
    end as end_boundary_matches,

    case

        when native_expiry_date is not null
         and native_expiry_date::timestamp <= first_snapshot_observed_at
            then 'BEFORE_SNAPSHOT_OBSERVATION'

        when snapshot_lifecycle is null
            then 'MISSED_NATIVE_PERIOD'

        when snapshot_valid_from::date = native_effective_date
         and coalesce(
                snapshot_valid_to::date,
                '9999-12-31'::date
             )
             =
             coalesce(
                native_expiry_date,
                '9999-12-31'::date
             )
            then 'FULLY_RECONSTRUCTED'

        else 'PARTIALLY_RECONSTRUCTED'

    end as reconstruction_status

from coverage