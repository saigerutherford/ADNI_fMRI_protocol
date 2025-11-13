# Step 5.) Post-Clinica Quality Control

This step will generate a quality report on the data after running Clinica. We provide insight into the heuristics we chose for including subjects based on their scan parameters that we pull from the DICOM files. This report also summarizes the errors (i.e., why Clinica failed for some subjects). 

You first need to run the script for pulling the parameters from the DICOM files and mapping this info with the Clinica BIDS output. 
This script is in `analysis/create_mastersheet/main.py`. 
Edit this script to match the path to your `BIDS/` and `conversion_info/` directories than were created in [step 4](https://github.com/saigerutherford/AD_biomarkers/blob/main/s4_clinica/README.md). 
Once you have edited the paths in `analysis/create_mastersheet/main.py` to match your data, then you should install the required python libraries (e.g., `pip install -r requirements.txt` or `conda install requirements.txt`)you can then run this script with `python main.py`. 
This script will take a few minutes to run because it needs to read all of the DICOM data. 
Once it has finished, there will be 4 files in `analysis/create_mastersheet/data/` (anchor_plus_dicom_nifti_struct.csv, anchor_df.csv, anchor_hash.txt, anchor_plus_dicom.csv). 


Now you can run the report to summarize the data and decide which subjects to pass onto the next step. 
There is a jupyter notebook here: `analysis/create_report/main.ipynb` that you can open and run to generate the quality report. 
There are a lot of instructions and details provided inside of this notebook.
This notebook will also generate the CSV file required to pass on the subject/sessions list to MRIQC and fMRIPrep in steps [6](https://github.com/saigerutherford/AD_biomarkers/blob/main/s6_mriqc/README.md) and [7](https://github.com/saigerutherford/AD_biomarkers/blob/main/s7_fmriprep/README.md). 


Now, continue on to [Step 6](https://github.com/saigerutherford/AD_biomarkers/blob/main/s6_mriqc/README.md).