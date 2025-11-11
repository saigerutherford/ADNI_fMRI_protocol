#!/bin/bash
#SBATCH --account=r01313
#SBATCH --mail-user=saiwolf@iu.edu
#SBATCH --partition=general
#SBATCH --job-name=mriqc_group
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH -o mriqc_group.out
#SBATCH -e mriqc_group.err

module load apptainer


## MRIqc group level script for ADNI fMRI data on IU Big Red 200 HPC
#
# written by Saige Rutherford Wolfers

# Run MRIQC
apptainer run \
  --bind /N/project/statadni/20250922_Saige/adni_db/bids/participants:/data:ro \
  --bind /N/project/statadni/20250922_Saige/mriqc/results/derivatives:/out \
  /N/project/statadni/20250922_Saige/singularity_images/mriqc-24.0.2.simg \
  /data /out group \
  --no-sub \
  --verbose-reports \

