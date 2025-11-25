# Step 5.) Post-Clinica Quality Control

This step generates a quality report on the data after running Clinica. We provide insight into the heuristics we chose for including subjects based on scan parameters pulled from the DICOM and BIDS headers. The report also summarizes errors (for example, why Clinica failed for some subjects).

You first need to run the script that pulls parameters from the DICOM files and maps this information to the Clinica BIDS output.

The entry point is `analysis/create_mastersheet/main.py`. It is now fully config-driven:

1. Ensure `config/config_adni.yaml` has the correct paths for your Clinica `conversion_info` tables, BIDS root, and output locations used by the master-sheet code.
2. Install the required Python libraries into your active environment:
   - `cd s5_post_clinica_qc/analysis`
   - `pip install -r requirements.txt` (or `conda install --file requirements.txt`).
3. From `s5_post_clinica_qc/analysis/create_mastersheet/`, run:
   - `python main.py --config ../../../config/config_adni.yaml`

The script will take a few minutes to run because it needs to read representative DICOMs and NIfTI+JSON headers.

Once it has finished, there will be four files in `analysis/create_mastersheet/data/`:

- `anchor_plus_dicom_nifti_struct.csv`
- `anchor_df.csv`
- `anchor_hash.txt`
- `anchor_plus_dicom.csv`


Now you can run the report notebook to summarize the data and decide which subjects to pass on to the next steps.

There is a Jupyter notebook at `analysis/create_report/main.ipynb` that you can open and run to generate the quality report. It contains detailed, step-by-step instructions and documents the heuristic choices.

This notebook also generates the CSV file of subject/session heuristics required for MRIQC and fMRIPrep in Steps 6 and 7 (for example, the `paths.fmriprep_heuristics_csv` referenced in `config/config_adni.yaml`).

Now, continue on to Step 6 (`s6_mriqc/README.md`).
