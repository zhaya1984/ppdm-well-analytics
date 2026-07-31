select
    UWI as well_id,
    WELL_STATUS_ID as well_status_id,

    LIFECYCLE as lifecycle,
    BUSINESS_INTENTION as business_intention,
    OUTCOME as outcome,
    PLAY_TYPE as play_type,
    ROLE as well_role,
    CONDITION as well_condition,
    PRODUCT_TYPE as product_type,
    PRODUCT_SIGNIFICANCE as product_significance,

    DBT_VALID_FROM as valid_from,
    DBT_VALID_TO as valid_to,

    case
        when DBT_VALID_TO is null then true
        else false
    end as is_current,

    LAST_UPDATED_AT as source_last_updated_at,
    DBT_SCD_ID as status_version_id

from {{ ref('snap_well_status') }}