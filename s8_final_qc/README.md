# Step 8.) Final QC

This final step combines outputs from MRIQC and fMRIPrep to make inclusion/exclusion decisions for downstream analyses.

Typical tasks in this step include:

- Reviewing MRIQC group reports for obvious outliers or systematic issues.
- Inspecting fMRIPrep HTML reports for a subset of subjects, focusing on registration quality, susceptibility distortion correction, and surface reconstruction.
- Applying quantitative QC thresholds (for example, on motion, temporal SNR, or other image-quality metrics).
- Generating final inclusion/exclusion tables (for example, `included_sessions.tsv`) referenced in `config/config_adni.yaml` under `qc.*`.

The exact QC criteria will depend on your scientific goals. We recommend documenting your thresholds and decisions in a lab-specific notebook or markdown document alongside this directory so others can reproduce your final sample selection.
