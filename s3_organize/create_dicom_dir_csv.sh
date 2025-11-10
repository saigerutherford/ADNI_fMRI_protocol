#!/bin/bash

cd /path/to/unzipped/dicom/directories/

echo “sub_ID, scan_name,scan_date” >> dicom_dirs.csv
for i in *
do 
  for j in `ls ${i}/`
  do 
    for k in `ls ${i}/${j}/`
    do 
      for l in `ls ${i}/${j}/${k}/` 
      do 
      echo “${i},${j},${k},${l}” >> dicom_dirs.csv
      done
    done
  done
done
