#!/bin/bash

# 1. Set paths
base="/N/project/statadni/20250922_Saige"
idir="${base}/adni_db/bids/participants"
odir="${base}/fmriprep/results"
sdir="${odir}/scripts"
logdir="${sdir}/logs"
filterdir="${sdir}/filters"
csv_path="${base}/fmriprep/slurm/final_heuristics_applied_all_subjects_sessions_grouped_CLEAN.csv"
tmp_work_root="${odir}/tmp_workdirs"
donedir="${sdir}/done" 

export TEMPLATEFLOW_HOST_HOME=$HOME/.cache/templateflow
mkdir -p ${TEMPLATEFLOW_HOST_HOME}

# 2. Ensure required dirs
mkdir -p "$sdir" "$logdir" "$filterdir" "$odir/derivatives" "$base/singularity_images" "${odir}/tmp_workdirs" "$donedir"

# 3. Set Apptainer image path
module load apptainer
img_path="${base}/singularity_images/fmriprep-25.2.3.simg"
if [ ! -f "$img_path" ]; then
    echo "Building container..."
    apptainer build "$img_path" "docker://nipreps/fmriprep:25.2.3"
fi

# 4. Write dataset_description.json
cat <<EOF > "$idir/dataset_description.json"
{
  "Name": "ADNI Mejia",
  "BIDSVersion": "1.10.1"
}
EOF

# 5. Write license file
cat <<EOF > "$odir/license.txt"
zzahid@iu.edu
83913
 *CULSlnbSTYW.
 FSTVdTV4sMyNc
 9VJ6HnL28eMs4F8rL+u9eCvGcvrKG0Ui7FCd2K/yAFE=
EOF

# 6. Extract subject-session pairs
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



# 7. Write job array input file
split_prefix="${sdir}/job_array_input_part_" # Split input into chunks of 499 (SLURM max is 500)
printf "%s\n" "${pairs[@]}" | split -l 499 - "$split_prefix"


# 8. Write job array script
for chunk_file in ${split_prefix}*; do
  part_name=$(basename "$chunk_file")
  part_suffix="${part_name##*_}"  # e.g., 'aa', 'ab', etc.
  input_file="$chunk_file"
  job_script="${sdir}/fmriprep_array_${part_suffix}.slurm"
  num_jobs=$(wc -l < "$input_file")
  max_index=$((num_jobs - 1))

  cut -d',' -f1 "$input_file" | sort -u | while read subid; do
    mkdir -p "${logdir}/${subid}"
  done

  echo "Submitting fMRIPrep job array part ${part_suffix} with $num_jobs entries..."

  cat <<EOF > "$job_script"
#!/bin/bash
#SBATCH --account=r01313
#SBATCH --mail-user=saiwolf@iu.edu
#SBATCH --partition=general
#SBATCH --job-name=fmriprep_array_${part_suffix}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=80:00:00
#SBATCH --array=0-${max_index}%400
#SBATCH -o /dev/null
#SBATCH -e /dev/null # Setting it manually down below

module load apptainer

# 1. Grab the subject ID from the input file
IFS=',' read -r subid <<< \$(sed -n "\$((SLURM_ARRAY_TASK_ID + 1))p" $input_file)

logfile="${logdir}/\${subid}/log_\${SLURM_ARRAY_JOB_ID}_\${SLURM_ARRAY_TASK_ID}"
exec > "\$logfile.out"
exec 2> "\$logfile.err"

echo "Task ID: \$SLURM_ARRAY_TASK_ID"
echo "Parsed subid=\$subid"

# 2. Clean up any previous outputs from failed runs.
rm -rf "${odir}/derivatives/\${subid}/" 2>/dev/null || true
rm -rf "${odir}/derivatives/sourcedata/freesurfer/\${subid}/" 2>/dev/null || true

# 3. Create per-session log, work and freesurfer directories and filter file.
#filter_subdir="${filterdir}/\${subid}"
log_subdir="${logdir}/\${subid}"
mkdir -p "\$log_subdir"

workdir=\$(mktemp -d "${tmp_work_root}/work_\${subid}_XXXXXX")
freesurfer_dir="${odir}/derivatives/sourcedata/freesurfer/\${subid}"
mkdir -p "\$freesurfer_dir"

donefile="${donedir}/\${subid}.done"


# 4. Run fMRIPrep
apptainer run \\
  --cleanenv \\
  --bind ${idir}:/data:ro \\
  --bind ${odir}/derivatives:/out \\
  --bind ${odir}/license.txt:/license.txt:ro \\
  --bind ${TEMPLATEFLOW_HOST_HOME}:/opt/templateflow \\
  --bind "\$workdir":/work \\
  --bind "\$freesurfer_dir":/fsdir \\
  ${img_path} \\
  /data \\
  /out \\
  participant \\
  --participant-label \${subid} \\
  --force syn-sdc \\
  --ignore fieldmaps \\
  --subject-anatomical-reference sessionwise \\
  --output-spaces MNI152NLin6Asym:res-2 MNI152NLin2009cAsym fsnative \\
  --output-spaces fsaverage:den-10k \\
  --cifti-output 91k \\
  --output-spaces func \\
  --write-graph \\
  --notrack \\
  --random-seed 357 \\
  -vv \\
  --fs-license-file /license.txt \\
  --fs-subjects-dir /fsdir \\
  --skip-bids-validation \\
  --nprocs 16 \\
  --stop-on-first-crash \\
  --work-dir "/work" \\
  --clean-workdir

# 5. Check for success and cleanup
status=\$?
if [ "\$status" -eq 0 ]; then
  echo "fMRIPrep completed successfully for \${subid}"
  touch "\$donefile"
  rm -rf "\$workdir"
  echo "Marked \${subid} as done."
else
  echo "fMRIPrep failed for \${subid} with exit code \$status"
  exit \$status
fi
EOF

  # 9. Submit job array
#  sbatch "$job_script"
done
