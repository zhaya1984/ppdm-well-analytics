select
    well_id,
    count(*) as current_status_count
from {{ ref('well_status_history') }}
where is_current = true
group by well_id
having count(*) > 1
