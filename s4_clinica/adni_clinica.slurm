#!/usr/bin/env bash
#SBATCH --partition=general
#SBATCH --account=r01313
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=5:00:00
#SBATCH --mem=90G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=saiwolf@iu.edu
#SBATCH --job-name=ADNI_clinica
#SBATCH -o cl-ADNI-%j.out-%N
#SBATCH -e cl-ADNI-%j.err-%N

# * Environment
base="/N/project/statadni"
ddir="${base}/ImagingData/dicomUnzipped/"
odir="${base}BIDS/"
cdir="${base}/ClinicalData"
sdir="${base}/Scripts/Clinica/"
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
    --subjects_list "${sdir}/adni_subs.txt" \
    "${ddir}" \
    "${cdir}" \
    "${odir}" \
    | tee "${ldir}/adni_clinica_log.txt"

exit

