select
    a.well_id,

    a.status_version_id as version_a,
    a.valid_from as a_valid_from,
    a.valid_to as a_valid_to,

    b.status_version_id as version_b,
    b.valid_from as b_valid_from,
    b.valid_to as b_valid_to

from {{ ref('well_status_history') }} a

join {{ ref('well_status_history') }} b
    on a.well_id = b.well_id
    and a.status_version_id < b.status_version_id

where
    a.valid_from < coalesce(
        b.valid_to,
        to_timestamp_ntz('9999-12-31 00:00:00')
    )
    and b.valid_from < coalesce(
        a.valid_to,
        to_timestamp_ntz('9999-12-31 00:00:00')
    )
