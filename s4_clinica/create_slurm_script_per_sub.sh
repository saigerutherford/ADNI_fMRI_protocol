#!/bin/bash

cd /N/project/statadni/Scripts/Clinica/

for i in `cat adni_subs.txt`
do
    echo ${i}
    echo ${i} >> ${i}.txt
    cp adni_clinica.slurm ./${i}_adni_clinica.slurm
    sed -i "s|job-name=ADNI|job-name=ADNI_${i}|" ${i}_adni_clinica.slurm
    sed -i "s|cl-ADNI|cl-ADNI_${i}|" ${i}_adni_clinica.slurm
    sed -i "s|adni_subs|${i}|" ${i}_adni_clinica.slurm
    sed -i "s|adni_clinica_log|adni_${i}_clinica_log|" ${i}_adni_clinica.slurm
done
