with source as (

    select *
    from {{ source('ppdm', 'well_status_native') }}

),

renamed as (

    select
        status_id::varchar as status_id,
        uwi::varchar as well_id,
        source::varchar as source_system,

        upper(trim(status_type::varchar)) as status_type,
        status::varchar as status_value,

        effective_date::date as effective_date,
        expiry_date::date as expiry_date,

        active_ind::varchar as active_ind,
        remark::varchar as remark,

        row_created_by::varchar as row_created_by,
        row_created_date::timestamp_ntz as row_created_at,
        row_changed_by::varchar as row_changed_by,
        row_changed_date::timestamp_ntz as row_changed_at

    from source

)

select *
from renamed