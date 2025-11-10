#!/bin/bash

# 1. Set paths
base="/N/project/statadni/20250922_Saige"
idir="${base}/adni_db/bids/participants"
odir="${base}/mriqc/results"
sdir="${odir}/scripts"
logdir="${sdir}/logs"
csv_path="${base}/fmriprep/slurm/final_heuristics_applied_all_subjects_sessions_grouped_CLEAN.csv"
tmp_work_root="${odir}/tmp_workdirs"
donedir="${sdir}/done" 

# 2. Ensure required dirs
mkdir -p "$sdir" "$logdir" "$odir/derivatives" "$base/singularity_images" "${odir}/tmp_workdirs" "$donedir"

# 3. Set Apptainer image path
module load apptainer
img_path="${base}/singularity_images/mriqc-24.0.2.simg"
if [ ! -f "$img_path" ]; then
    echo "Building container..."
    apptainer build "$img_path" "docker://nipreps/mriqc:24.0.2"
fi


# 4. Extract subject id
pairs=()
echo "Parsing CSV to create job array..."
while IFS=, read -r subj_raw v1 _; do
    [[ -z "$subj_raw" || -z "$v1" ]] && continue
    subid="sub-ADNI${subj_raw//_/}"
    sessid=${v1}
    donefile="${donedir}/${subid}.done"
    if [ ! -f "$donefile" ]; then
        pairs+=("${subid}")
    fi
done < <(tail -n +2 "$csv_path")


# 5. Write job array input file
split_prefix="${sdir}/job_array_input_part_" # Split input into chunks of 499 (SLURM max is 500)
printf "%s\n" "${pairs[@]}" | split -l 499 - "$split_prefix"


# 6. Write job array script
for chunk_file in ${split_prefix}*; do
  part_name=$(basename "$chunk_file")
  part_suffix="${part_name##*_}"  # e.g., 'aa', 'ab', etc.
  input_file="$chunk_file"
  job_script="${sdir}/mriqc_array_${part_suffix}.slurm"
  num_jobs=$(wc -l < "$input_file")
  max_index=$((num_jobs - 1))

  cut -d',' -f1 "$input_file" | sort -u | while read subid; do
    mkdir -p "${logdir}/${subid}"
  done

  echo "Submitting MRIQC job array part ${part_suffix} with $num_jobs entries..."

  cat <<EOF > "$job_script"
#!/bin/bash
#SBATCH --account=r01313
#SBATCH --mail-user=saiwolf@iu.edu
#SBATCH --partition=general
#SBATCH --job-name=mriqc_array_${part_suffix}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --array=0-${max_index}%50
#SBATCH -o /dev/null
#SBATCH -e /dev/null # Setting it manually down below

module load apptainer


## MRIqc script for ADNI fMRI data on IU Big Red 200 HPC
#
# written by Saige Rutherford Wolfers

# 1. Grab the subject ID from the input file
IFS=',' read -r subid <<< \$(sed -n "\$((SLURM_ARRAY_TASK_ID + 1))p" $input_file)

logfile="${logdir}/\${subid}/log_\${SLURM_ARRAY_JOB_ID}_\${SLURM_ARRAY_TASK_ID}"
exec > "\$logfile.out"
exec 2> "\$logfile.err"

echo "Task ID: \$SLURM_ARRAY_TASK_ID"
echo "Parsed subid=\$subid"

# 2. Clean up any previous outputs from failed runs.
rm -rf "${odir}/derivatives/\${subid}/" 2>/dev/null || true

# 3. Create log and work directories.
log_subdir="${logdir}/\${subid}"
mkdir -p "\$log_subdir"

workdir=\$(mktemp -d "${tmp_work_root}/work_\${subid}_XXXXXX")
donefile="${donedir}/\${subid}.done"

# 4. Run MRIQC
apptainer run \\
  --bind ${idir}:/data:ro \\
  --bind ${odir}/derivatives:/out \\
  --bind "\$workdir":/work \\
  ${img_path} \\
  /data \\
  /out \\
  participant \\
  --participant-label \${subid} \\
  --nprocs 16 \\
  --omp-nthreads 8 \\
  --work-dir "/work" \\
  --no-sub \\

# 5. Check for success and cleanup
status=\$?
if [ "\$status" -eq 0 ]; then
  echo "MRIQC completed successfully for \${subid}"
  touch "\$donefile"
  rm -rf "\$workdir"
  echo "Marked \${subid} as done."
else
  echo "MRIQC failed for \${subid} with exit code \$status"
  exit \$status
fi
EOF

  # 9. Submit job array
#  sbatch "$job_script"
done

