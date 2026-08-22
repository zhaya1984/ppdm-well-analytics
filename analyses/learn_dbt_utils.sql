select
    {{ dbt_utils.generate_surrogate_key([
        "'WELL-001'",
        "'2026-08-21'"
    ]) }} as surrogate_key