#!/bin/bash
#PBS -l walltime=01:00:00
#PBS -l select=1:ncpus=1:mem=2gb
#PBS -N adjust_library

cd $file_path/library

max_jobs=`sed -n '11p' $file_path/projects/project_name/logs.txt`
max_threading=`sed -n '10p' $file_path/projects/project_name/logs.txt`
job_n = max_job - 1

cat *smi > library/library.smi
rm -v !("library.smi")
smile_n = wc -l library.smi
smile_pf = smile_n / max_jobs

if max_jobs < 10: 
	n_z = 1
elif max_jobs > 9 && max_Jobs < 100:
	n_z = 2
elif max_Jobs > 99 && max_Jobs < 1000:
	n_z = 3
elif max_Jobs > 999 && max_Jobs < 10000
	n_z = 4
elif max_Jobs > 9999 && max_Jobs < 100000
	n_z = 5

split -d -l smile_pf -a n_z library.smi smiles_all_ --additional-suffix=.smi

array_header = "#PBS -J 0-${job_n}" 
max_header - "#PBS -l select=1:ncpus=${max_threading}:mem=${max_threading}gb"

sed -i '2s/$/array_header/' $file_path/DD_protocol/utilities/compute_states.sh
sed -i '3s/$/max_header/' $file_path/DD_protocol/utilities/compute_morgan_fp.sh
sed -i '4s/$/ $max_threading/' $file_path/DD_protocol/utilities/compute_morgan_fp.sh
sed -i '3s/$/max_header/' $file_path/DD_protocol/phase_1.sh
sed -i '35s/$/array_header/' $file_path/DD_protocol/phase_2_fred.sh
sed -i '40s/$/array_header/' $file_path/DD_protocol/phase_3_fred.sh
sed -i '3s/$/max_header/' $file_path/DD_protocol/utilities/final_extraction.sh
