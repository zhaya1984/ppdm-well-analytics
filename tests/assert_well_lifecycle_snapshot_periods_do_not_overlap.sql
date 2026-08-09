select
    a.well_id,

    a.starting_status_version_id as status_version_id_a,
    a.lifecycle as lifecycle_a,
    a.snapshot_valid_from as valid_from_a,
    a.snapshot_valid_to as valid_to_a,

    b.starting_status_version_id as status_version_id_b,
    b.lifecycle as lifecycle_b,
    b.snapshot_valid_from as valid_from_b,
    b.snapshot_valid_to as valid_to_b

from {{ ref('well_lifecycle_history_snapshot') }} a

join {{ ref('well_lifecycle_history_snapshot') }} b
    on a.well_id = b.well_id
    and a.starting_status_version_id < b.starting_status_version_id

where
    a.snapshot_valid_from
        < coalesce(b.snapshot_valid_to, '9999-12-31'::timestamp)
    and b.snapshot_valid_from
        < coalesce(a.snapshot_valid_to, '9999-12-31'::timestamp)