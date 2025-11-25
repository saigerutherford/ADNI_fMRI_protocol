#!/bin/bash

# Create per-subject Clinica Slurm scripts from a template.
#
# Assumes this script lives alongside:
#   - adni_clinica.slurm          (template Slurm script)
#   - adni_subs.txt               (one subject ID per line)
#
# Usage:
#   bash create_slurm_script_per_sub.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SUB_LIST="adni_subs.txt"
TEMPLATE="adni_clinica.slurm"

if [[ ! -f "$SUB_LIST" ]]; then
  echo "[create_slurm_script_per_sub] Subject list not found: $SUB_LIST" >&2
  exit 1
fi

if [[ ! -f "$TEMPLATE" ]]; then
  echo "[create_slurm_script_per_sub] Template Slurm file not found: $TEMPLATE" >&2
  exit 1
fi

while IFS= read -r sub; do
  [[ -z "$sub" ]] && continue
  echo "$sub"
  echo "$sub" > "${sub}.txt"

  out_slurm="${sub}_adni_clinica.slurm"
  cp "$TEMPLATE" "$out_slurm"

  sed -i "s|job-name=ADNI|job-name=ADNI_${sub}|" "$out_slurm"
  sed -i "s|cl-ADNI|cl-ADNI_${sub}|" "$out_slurm"
  sed -i "s|adni_subs|${sub}|" "$out_slurm"
  sed -i "s|adni_clinica_log|adni_${sub}_clinica_log|" "$out_slurm"

done < "$SUB_LIST"
