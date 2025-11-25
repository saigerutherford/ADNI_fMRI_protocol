# Alzheimer's Disease Neuroimaging Initiative (ADNI) resting-state functional MRI protocol
This repository contains detailed instructions and scripts for accessing, downloading, converting DICOMs to NIfTI, organizing data into BIDS format, running MRIQC, preprocessing data with fMRIPrep, and QC-ing the ADNI resting-state fMRI data.

This protocol is for ADNI 2, GO, and 3 resting-state fMRI (it also uses the T1w and, if available, T2w images for subjects with fMRI). ADNI 1 does not have rs-fMRI and we did not (yet) process ADNI 4 because Clinica (the software we use for converting DICOM to NIfTI and BIDS-ifying the data) does not yet handle ADNI 4.

The output of this protocol is high-quality, preprocessed rs-fMRI data in fs-LR 91k (plus MNI, fsnative, and fsaverage5) space, ready for downstream analyses.

## Quick start

1. Obtain ADNI access and sign the DUA.
2. Clone this repository and create an environment from `env/env_adni.yml`.
3. Edit `config/config_adni.yaml` with your local paths, container locations, and cluster settings.
4. (Optional but recommended) Skim the step-specific READMEs below to understand manual vs automated pieces.
5. Download data via the LONI IDA web UI following `s1_setup_account/README.md` and `s2_download/README.md`.
6. Run the automated steps via the `Makefile`, for example:
   - `make organize` (or `make step3`)
   - `make clinica` (or `make step4`)
   - `make post_clinica_qc` (or `make step5`)
   - `make mriqc` (or `make step6`)
   - `make fmriprep` (or `make step7`)
   - `make final_qc` (or `make step8`)
7. Inspect QC reports and tables in `s5_post_clinica_qc/`, `s6_mriqc/`, `s7_fmriprep/`, and `s8_final_qc/`.
8. Use the final inclusion tables (for example, `included_sessions.tsv`) for downstream analyses.

All automated steps are driven by `config/config_adni.yaml`. Paths, container images, and most Slurm settings are read at runtime via `utils.config_tools` rather than hardcoded in scripts. Adjust that YAML for your environment instead of editing code where possible.

We attempted to make this process as automated and reproducible as possible. We document the errors we encountered at every step, provide insight on how we troubleshoot and fix the errors, and describe where manual intervention is needed. At some steps, like quality checking, there are decisions that may differ across research groups running this protocol. We attempted to justify and transparently explain all decisions made on inclusion/exclusion based on automated QC metrics. We provide tables describing the sample size at every step, including how many subjects/sessions were dropped after a QC decision was made.

The repo is organized around eight steps (described and linked below). Each step has its own subdirectory with a `README.md` that contains detailed instructions for that step, including the relevant scripts.

<div>
<img src="ADNI_protocol_overview.png" width="900"/>
</div>

## Step 1.) Account and Access

See `s1_setup_account/README.md`.

## Step 2.) Build and download image collection

See `s2_download/README.md`.

## Step 3.) Unzip, organize, and QC download

See `s3_organize/README.md`.

## Step 4.) Run Clinica (DICOM→NIfTI and BIDS-ify)

See `s4_clinica/README.md`.

## Step 5.) Post-Clinica Quality Control

See `s5_post_clinica_qc/README.md`.

## Step 6.) MRIQC

See `s6_mriqc/README.md`.

## Step 7.) fMRIPrep

See `s7_fmriprep/README.md`.

## Step 8.) Final Quality Control

See `s8_final_qc/README.md`.
