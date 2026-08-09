with snapshot_lifecycle as (

    select
        well_id,
        lifecycle as snapshot_lifecycle,
        snapshot_valid_from,
        snapshot_valid_to,
        is_current as snapshot_is_current,
        source_last_updated_at,
        starting_status_version_id

    from {{ ref('well_lifecycle_history_snapshot') }}

),

native_lifecycle as (

    select
        status_id as native_status_id,
        well_id,
        lifecycle as native_lifecycle,
        effective_date as native_effective_date,
        expiry_date as native_expiry_date,
        active_ind as native_active_ind

    from {{ ref('int_well_lifecycle_history_native') }}

)

select
    s.well_id,

    s.snapshot_lifecycle,
    s.snapshot_valid_from,
    s.snapshot_valid_to,
    s.snapshot_is_current,
    s.starting_status_version_id,

    n.native_status_id,
    n.native_lifecycle,
    n.native_effective_date,
    n.native_expiry_date,
    n.native_active_ind,
    case
    when native_status_id is null then 'NO_NATIVE_PERIOD'
    when snapshot_lifecycle = native_lifecycle then 'EXACT_MATCH'
    when upper(trim(snapshot_lifecycle)) = upper(trim(native_lifecycle))
        then 'FORMAT_ONLY_MATCH'
    else 'VALUE_MISMATCH'
end as alignment_status

from snapshot_lifecycle s

left join native_lifecycle n
    on s.well_id = n.well_id
    and s.snapshot_valid_from::date >= n.native_effective_date
    and (
        n.native_expiry_date is null
        or s.snapshot_valid_from::date < n.native_expiry_date
    )