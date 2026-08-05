select
    status_id,
    well_id,
    source_system,
    status_value as lifecycle,
    effective_date,
    expiry_date,
    active_ind,
    remark,
    row_created_by,
    row_created_at,
    row_changed_by,
    row_changed_at

from {{ ref('stg_ppdm__well_status_native') }}

where status_type = 'LIFECYCLE'