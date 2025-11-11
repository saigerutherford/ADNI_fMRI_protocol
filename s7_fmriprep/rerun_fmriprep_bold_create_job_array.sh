#!/bin/bash

BASE=/N/project/statadni/20250922_Saige
OUTDIR=$BASE/fmriprep/results/scripts
BIDS=$BASE/adni_db/bids/participants
DERIV=$BASE/fmriprep/results/derivatives/fmriprep
REPORT=$OUTDIR/reports/fmriprep_error_report_ALL.csv   # from the classifier

#mkdir -p "$OUTDIR"

# 1) Subjects implicated by “no BOLD” or “filtered out” categories (from the CSV)
AFFECTED=$OUTDIR/subs_needing_rerun_from_report.txt
awk -F, 'NR>1 && ($5 ~ /no BOLD|filtered out/) {print $3}' "$REPORT" \
  | sed 's/"//g' \
  | sort -u > "$AFFECTED"

# 2) Subjects that HAVE BOLD on disk in BIDS
VALID_SUBS=$OUTDIR/valid_subjects_have_bold.txt
find "$BIDS" -type f -path "*/ses-*/func/*bold.nii.gz" \
 | sed -E 's#.*/(sub-[^/]+)/ses-.*#\1#' \
 | sort -u > "$VALID_SUBS"

# Intersect: affected AND valid
AFFECTED_VALID=$OUTDIR/affected_and_valid.txt
grep -F -f "$AFFECTED" "$VALID_SUBS" > "$AFFECTED_VALID" || true

# 3) Keep only those that do NOT yet have preproc outputs in derivatives
RERUN_SUBS=$OUTDIR/job_array_input_RERUN_subjects.txt
: > "$RERUN_SUBS"

while IFS= read -r sub; do
  # If any preproc BOLD exists, skip; else include
  if ! find "$DERIV/$sub" -path "*/ses-*/func/*desc-preproc_bold.nii.gz" -print -quit 2>/dev/null | grep -q .; then
    echo "$sub" >> "$RERUN_SUBS"
  fi
done < "$AFFECTED_VALID"

echo "Affected subs (from report): $(wc -l < "$AFFECTED")"
echo "Affected & have BOLD:        $(wc -l < "$AFFECTED_VALID")"
echo "Rerun list:                  $(wc -l < "$RERUN_SUBS")"
head "$RERUN_SUBS"
