#!/bin/bash

for i in `cat adni2_f_subs_pt1.txt`
do
    sbatch ${i}_adni2_f_clinica.slurm
done
