# Transform models

This layer contains reusable transformations that sit between staging models in `01_stage` and business-facing marts in `03_model`.

Add a SQL model and its schema YAML here when a transformation is shared by more than one downstream model or needs to be separated from the final business grain.
