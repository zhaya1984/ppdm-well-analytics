select *
from {{ ref('int_well_enriched') }}
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