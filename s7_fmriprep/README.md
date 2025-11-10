# AD_biomarkers
Repo for all AD fMRI data preprocessing, QC, analysis

## Stage 1. Data Download, Clinica (BIDS conversion), & initial QC

Step 1.) DICOM imaging data and phenotypic data is downloaded from [LONI](https://adni.loni.usc.edu/data-samples/adni-data/#AccessData). Vincent was responsible for downloading the data and it is stored here: `/N/project/statadni/20231212_UtahBackup/`. The scripts for the data download are here: `/N/project/statadni/20231212_UtahBackup/github/20210625_DataDownload/scripts/download_data.sh`.  

Step 2.) [Clinica](https://aramislab.paris.inria.fr/clinica/docs/public/dev/Converters/ADNI2BIDS/) is run on DICOMS to convert to NIFTI and reorganize the data into BIDS format.

Step 3.) Run QC (Zeshawn's [scripts](https://github.com/vnckppl/R01_AD_sup/tree/master/20240508_Scripts)).

## Stage 2. More QC (mriqc) & Preprocessing (fMRIPrep)

Step 1.) Run [MRIQC](https://mriqc.readthedocs.io/en/latest/index.html) to generate automated metrics and qc reports.

Step 2.) Run [fMRIPrep](https://fmriprep.org/en/stable/index.html) on data that passed initial QC. 
