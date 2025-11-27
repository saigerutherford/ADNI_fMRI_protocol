#!/bin/bash

# Create a CSV listing all DICOM directories for downstream QC.
# The root DICOM directory is read from config/config_adni.yaml
# (paths.raw_dicom_dir) via the utils.config_tools helper.
#
# Optional arguments:
#   --config PATH   Use a specific YAML config file instead of the default.

set -euo pipefail

CONFIG_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)
      CONFIG_PATH="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--config /path/to/config.yaml]" >&2
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: $0 [--config /path/to/config.yaml]" >&2
      exit 1
      ;;
  esac
done

if [[ -n "$CONFIG_PATH" ]]; then
  DICOM_ROOT=$(python -m utils.config_tools paths.raw_dicom_dir --config "$CONFIG_PATH")
else
  DICOM_ROOT=$(python -m utils.config_tools paths.raw_dicom_dir)
fi

if [[ -z "${DICOM_ROOT:-}" ]]; then
  echo "[create_dicom_dir_csv] paths.raw_dicom_dir is empty or not set in config" >&2
  exit 1
fi

cd "$DICOM_ROOT"

# Overwrite any existing file to avoid appending across runs.
: > dicom_dirs.csv

echo "sub_ID,scan_name,scan_date,leaf_dir" >> dicom_dirs.csv
for i in *; do
  for j in "${i}"/*; do
    [ -d "$j" ] || continue
    for k in "$j"/*; do
      [ -d "$k" ] || continue
      for l in "$k"/*; do
        [ -d "$l" ] || continue
        leaf=$(basename "$l")
        echo "${i},$(basename "$j"),$(basename "$k"),${leaf}" >> dicom_dirs.csv
      done
    done
  done
done
