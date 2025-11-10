#!/bin/bash

cd /N/project/statadni/20250922_Saige/Clinica/ADNI2_F/

for i in `cat adni2_f_subs.txt`
do
    echo ${i}
    echo ${i} >> ${i}.txt
    cp adni2_f_clinica.slurm ./${i}_adni2_f_clinica.slurm
    sed -i "s|job-name=ADNI2_F|job-name=ADNI2_F_${i}|" ${i}_adni2_f_clinica.slurm
    sed -i "s|cl-ADNI2_F|cl-ADNI2_F_${i}|" ${i}_adni2_f_clinica.slurm
    sed -i "s|adni2_f_subs|${i}|" ${i}_adni2_f_clinica.slurm
    sed -i "s|adni2_f_clinica_log|adni2_f_${i}_clinica_log|" ${i}_adni2_f_clinica.slurm
done
