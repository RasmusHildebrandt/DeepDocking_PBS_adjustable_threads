#!/bin/bash
#PBS -l walltime=48:00:00

#PBS -N final_extraction

cd $file_path
module load anaconda3/personal

source ~/.bashrc
conda activate dd-env

start=`date +%s`

if [ $mols = 'all_mol' ]; then
   echo "Extracting all SMILES"
   python DD_protocol/utilities/final_extraction.py -smile_dir $smile_d -prediction_dir $prediction_d -processors $cpu_n
else
   python DD_protocol/utilities/final_extraction.py -smile_dir $smile_d -prediction_dir $prediction_d -processors $cpu_n -mols_to_dock $mols
fi

end=`date +%s`
runtime=$((end-start))
echo $runtime
