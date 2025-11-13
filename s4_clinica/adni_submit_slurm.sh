#!/bin/bash

for i in `cat adni_subs.txt`
do
    sbatch ${i}_adni_clinica.slurm
done
