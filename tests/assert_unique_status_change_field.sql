select
    status_version_id,
    changed_field,
    count(*) as record_count
from {{ ref('well_status_change_log') }}
group by
    status_version_id,
    changed_field
having count(*) > 1