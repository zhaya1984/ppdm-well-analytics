select
    a.well_id,

    a.status_id as status_id_a,
    a.lifecycle as lifecycle_a,
    a.effective_date as effective_date_a,
    a.expiry_date as expiry_date_a,

    b.status_id as status_id_b,
    b.lifecycle as lifecycle_b,
    b.effective_date as effective_date_b,
    b.expiry_date as expiry_date_b

from {{ ref('int_well_lifecycle_history_native') }} a

join {{ ref('int_well_lifecycle_history_native') }} b
    on a.well_id = b.well_id
    and a.status_id < b.status_id

where
    a.effective_date < coalesce(b.expiry_date, '9999-12-31'::date)
    and b.effective_date < coalesce(a.expiry_date, '9999-12-31'::date)