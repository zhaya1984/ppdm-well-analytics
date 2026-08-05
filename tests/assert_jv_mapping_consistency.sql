select *
from {{ ref('dim_well') }}
where
    (
        jv_mapping_status = 'MAPPED'
        and santos_interest_pct is null
    )
    or
    (
        jv_mapping_status = 'UNMAPPED'
        and santos_interest_pct is not null
    )