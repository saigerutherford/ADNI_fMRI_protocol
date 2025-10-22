# AD_biomarkers
Repository for the ADNI fMRI data download, curation, preprocessing and QC.

## Stage 1. Data Download, Clinica (BIDS conversion), & initial QC

### 1.1) DICOM imaging data and phenotypic data is downloaded from [LONI](https://adni.loni.usc.edu/data-samples/adni-data/#AccessData). 

The DICOM data is stored here: `/N/project/statadni/20231212_UtahBackup/ImagingData/dicomUnzipped/`. 

-Vincent data download scripts stored here: `/N/project/statadni/20231212_UtahBackup/github/20210625_DataDownload/scripts/download_data.sh`.

-Add script to unzip dicom zipfiles.

### 1.2) [Clinica](https://aramislab.paris.inria.fr/clinica/docs/public/dev/Converters/ADNI2BIDS/) is run on DICOMS to convert to NIFTI and reorganize the data into BIDS format.

-Create subject list from data download CSV

-Run create_clinica_subject_level.sh to create subject level scripts 

-Run submit_all_subs_clinica.sh to submit all subject level scripts to SLURM.

-Merge individual-level BIDS directories into one BIDS directory (combine participants.tsv, fmri_paths.tsv, t1_paths.tsv, flair_paths.tsv).

### 1.3) Run initial QC (Zeshawn's [scripts](https://github.com/vnckppl/R01_AD_sup/tree/master/20240508_Scripts)).

-create failed subjects list from Zeshawn QC script (based on heuristics). 

-try to automate "saving" the subjects who can be saved (49 missing T1 subs, etc.)

## Stage 2. MRIQC 

### 2.1) Run [MRIQC](https://mriqc.readthedocs.io/en/latest/index.html) to generate automated metrics and qc reports.

-adni_mriqc_create_slurm.sh

-submit mriqc_batch_aa.slurm, mriqc_batch_ab.slurm, mriqc_batch_ac.slurm to SLURM.

-run group level mriqc (adni_mriqc_group.slurm)

-make included subject list to pass on to fMRIPrep.

## Stage 3. fMRIPrep Preprocessing

### 3.1) Run [fMRIPrep](https://fmriprep.org/en/stable/index.html) on data that passed initial QC. 

-adni_fmriprep_create_slurm.sh

-submit fmriprep_batch_aa.slurm, fmriprep_batch_ab.slurm, fmriprep_batch_ac.slurm to SLURM 

### 3.2) Summarize + visualize final included subjects and QC metrics

-summarize pass/fail. Resubmit jobs as needed.

-visualize final table of included subjects, summarize dropped subjects at each step (and why they were dropped). 
