#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=32:mem=32gb


cd $PBS_O_WORKDIR
module load anaconda3/personal

source ~/.bashrc
conda activate dd-env

start=`date +%s`

python -u DD_protocol/utilities/morgan_fp.py -sfp library_prepared -fn library_prepared_fp -tp 32

end=`date +%s`
runtime=$((end-start))
echo $runtime


