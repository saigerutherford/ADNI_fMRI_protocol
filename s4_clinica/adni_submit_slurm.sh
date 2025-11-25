#!/bin/bash

while IFS= read -r i; do
    sbatch "${i}_adni_clinica.slurm"
done < adni_subs.txt
