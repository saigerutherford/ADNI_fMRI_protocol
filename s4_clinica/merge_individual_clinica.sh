#!/bin/bash

cd /N/project/statadni/BIDS_individual/ # path to Clinica BIDS output directory (where indidividual subject folders are located)

mkdir -p /N/project/statadni/BIDS_individual/BIDS_all
mkdir -p /N/project/statadni/BIDS_individual/BIDS_all/conversion_info
mkdir -p /N/project/statadni/BIDS_individual/BIDS_all/conversion_info/v0

for i in `cat adni_subs.txt`
do
    echo "Merging subject ${i} BIDS folder"
    if [[ -e /N/project/statadni/BIDS_individual/${i} ]]; then
        cp -r /N/project/statadni/BIDS_individual/${i} /N/project/statadni/BIDS_individual/BIDS_all/sub-${i}
        if [[ ! -e /N/project/statadni/BIDS_individual/BIDS_all/${i}/conversion_info/v0/fmri_paths.tsv ]]; then
            cat /N/project/statadni/BIDS_individual/${i}/conversion_info/v0/fmri_paths.tsv >> /N/project/statadni/BIDS_individual/BIDS_all/conversion_info/v0/fmri_paths.tsv
        fi
        if [[ ! -e /N/project/statadni/BIDS_individual/BIDS_all/${i}/conversion_info/v0/t1w_paths.tsv ]]; then
            cat /N/project/statadni/BIDS_individual/${i}/conversion_info/v0/t1w_paths.tsv >> /N/project/statadni/BIDS_individual/BIDS_all/conversion_info/v0/t1w_paths.tsv
        fi
        if [[ ! -e /N/project/statadni/BIDS_individual/BIDS_all/${i}/conversion_info/v0/flair_paths.tsv ]]; then
            cat /N/project/statadni/BIDS_individual/${i}/conversion_info/v0/flair_paths.tsv >> /N/project/statadni/BIDS_individual/BIDS_all/conversion_info/v0/flair_paths.tsv
        fi
        if [[ ! -e /N/project/statadni/BIDS_individual/BIDS_all/${i}/conversion_info/v0/participants.tsv ]]; then
            cat /N/project/statadni/BIDS_individual/${i}/conversion_info/v0/participants.tsv >> /N/project/statadni/BIDS_individual/BIDS_all/conversion_info/v0/participants.tsv
        fi
    else
        echo "Subject ${i} BIDS folder not found, skipping."
    fi
