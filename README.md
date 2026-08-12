# dbt Analytics Engineering Portfolio

This project demonstrates analytics engineering patterns using Snowflake and dbt.

The model architecture follows:

00_source → 01_stage → 02_transform → 03_model → 04_presentation

Current project themes include:

- staging and source standardisation
- dimensional and current-state modelling
- dbt snapshots and SCD2 history
- field-level change detection
- source-native effective-dated history
- reconciliation between native and snapshot-derived history
- data quality testing
- incremental modelling
- orchestration and CI/CD
- Power BI consumption design

## Lifecycle History Reconciliation

The project models well lifecycle history using two different mechanisms:

- source-native effective-dated history
- snapshot-reconstructed history from a mutable current-state source

These histories are not assumed to be equivalent.

The native history represents business-effective periods using
`effective_date` and `expiry_date`.

The snapshot-derived history represents versions captured from the mutable
current-state source. Under the timestamp strategy, SCD2 validity is driven
by the source update timestamp, while historical completeness still depends
on snapshot execution frequency.

Reconciliation is therefore performed in two directions:

1. **Snapshot → Native Alignment**  
   Validates whether each snapshot-observed lifecycle agrees with the
   source-native lifecycle effective at that point in time.

2. **Native → Snapshot Coverage**  
   Evaluates whether each source-native lifecycle period was represented
   in snapshot-derived history.

Native lifecycle periods are classified as:

- `OBSERVED`
- `PARTIALLY_OBSERVED`
- `MISSED_NATIVE_PERIOD`
- `BEFORE_SNAPSHOT_OBSERVATION`

Periods that ended before snapshot observation began are not treated as
snapshot failures.