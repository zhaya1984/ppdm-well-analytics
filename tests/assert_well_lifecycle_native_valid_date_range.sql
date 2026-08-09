select *
from {{ ref('int_well_lifecycle_history_native') }}
where expiry_date is not null
  and expiry_date < effective_date