#!/usr/bin/env bash
#SBATCH --partition=general
#SBATCH --account=r01313
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=5:00:00
#SBATCH --mem=90G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=saiwolf@iu.edu
#SBATCH --job-name=ADNI2_F
#SBATCH -o cl-ADNI2_F-%j.out-%N
#SBATCH -e cl-ADNI2_F-%j.err-%N

# * Environment
base="/N/project/statadni"
ddir="${base}/20231212_ADR012021_UtahBackup/ImagingData/dicomUnzipped/ADNI2_proc_MRI_fMRI_F"
odir="${base}/20250922_Saige/BIDS/ADNI2_F"
cdir="${base}/20231219_ADNI/ClinicalData"
sdir="${base}/20250922_Saige/Clinica/ADNI2_F"
ldir="${sdir}/logs"
mkdir -p "${odir}"

# * Load conda as a module
module load conda

# * Initiate the virtual environment
source activate /N/u/saiwolf/Quartz/.conda/envs/clinica_env
export PATH="/N/project/statadni/20231213_Software/dcm2niix_v1.0.20240202:${PATH}"

# * Run Clinica
clinica \
    convert adni-to-bids \
    -m T1 \
    -m FMRI \
    -m FLAIR \
    --subjects_list "${sdir}/adni2_f_subs.txt" \
    "${ddir}" \
    "${cdir}" \
    "${odir}" \
    | tee "${ldir}/adni2_f_clinica_log.txt"

exit

