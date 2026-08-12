with native_lifecycle as (

    select
        status_id as native_status_id,
        well_id,
        lifecycle as native_lifecycle,
        effective_date as native_effective_date,
        expiry_date as native_expiry_date,
        active_ind as native_active_ind

    from {{ ref('int_well_lifecycle_history_native') }}

),

snapshot_lifecycle as (

    select
        well_id,
        lifecycle as snapshot_lifecycle,
        snapshot_valid_from,
        snapshot_valid_to,
        starting_status_version_id

    from {{ ref('well_lifecycle_history_snapshot') }}

),

snapshot_observation_start as (

    select
        well_id,
        min(snapshot_valid_from) as first_snapshot_observed_at

    from snapshot_lifecycle

    group by well_id

),

coverage as (

    select
        n.native_status_id,
        n.well_id,
        n.native_lifecycle,
        n.native_effective_date,
        n.native_expiry_date,
        n.native_active_ind,

        o.first_snapshot_observed_at,

        s.snapshot_lifecycle,
        s.snapshot_valid_from,
        s.snapshot_valid_to,
        s.starting_status_version_id

    from native_lifecycle n

    left join snapshot_observation_start o
        on n.well_id = o.well_id

    left join snapshot_lifecycle s
        on n.well_id = s.well_id

        -- same lifecycle, ignoring formatting-only differences
        and upper(trim(n.native_lifecycle))
            = upper(trim(s.snapshot_lifecycle))

        -- native and snapshot periods overlap
        and n.native_effective_date
            < coalesce(s.snapshot_valid_to, '9999-12-31'::timestamp)

        and s.snapshot_valid_from
            < coalesce(n.native_expiry_date, '9999-12-31'::date)

)
, classified as (

    select
        *,

        greatest(
            native_effective_date::timestamp,
            first_snapshot_observed_at
        ) as observable_from,

        case
            when native_expiry_date is null
                then '9999-12-31'::timestamp
            else native_expiry_date::timestamp
        end as observable_to

    from coverage

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

    case

    when native_expiry_date is not null
     and native_expiry_date::timestamp <= first_snapshot_observed_at
        then 'BEFORE_SNAPSHOT_OBSERVATION'

    when snapshot_lifecycle is null
        then 'MISSED_WITHIN_SNAPSHOT_WINDOW'

    when snapshot_valid_from <= observable_from
     and coalesce(
            snapshot_valid_to,
            '9999-12-31'::timestamp
         ) >= observable_to
        then 'OBSERVED_WITHIN_SNAPSHOT_WINDOW'

    else 'PARTIALLY_OBSERVED_WITHIN_SNAPSHOT_WINDOW'

end as coverage_status

from classified
