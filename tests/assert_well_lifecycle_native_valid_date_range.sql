select *
from {{ ref('int_ppdm__well_status_native') }}
where expiry_date is not null
  and expiry_date < effective_date