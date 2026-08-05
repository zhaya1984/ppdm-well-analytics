with effective_records as (

    select
        status_id,
        well_id,
        source_system,
        status_type,
        status_value,
        effective_date,
        expiry_date,
        active_ind,
        remark,
        row_created_by,
        row_created_at,
        row_changed_by,
        row_changed_at

    from {{ ref('stg_ppdm__well_status_native') }}

    where effective_date <= current_date()
      and (
          expiry_date is null
          or expiry_date > current_date()
      )

),

ranked_records as (

    select
        *,

        count(*) over (
            partition by well_id, status_type
        ) as current_record_count,

        row_number() over (
            partition by well_id, status_type
            order by
                effective_date desc,
                row_changed_at desc,
                status_id desc
        ) as current_record_rank

    from effective_records

)

select
    status_id,
    well_id,
    source_system,
    status_type,
    status_value,
    effective_date,
    expiry_date,
    active_ind,
    remark,
    row_created_by,
    row_created_at,
    row_changed_by,
    row_changed_at,

    current_record_count,

    case
        when current_record_count = 1 then 'RESOLVED'
        else 'MULTIPLE_CURRENT_RECORDS'
    end as current_resolution_status

from ranked_records

where current_record_rank = 1
