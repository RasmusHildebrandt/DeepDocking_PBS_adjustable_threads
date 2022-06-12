#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -N phase_1

cd $PBS_O_WORKDIR

module load anaconda3/personal

source ~/.bashrc
conda activate $environment

start=`date +%s`

file_path=`sed -n '1p' $project_dir/$project_name/logs.txt`
protein=`sed -n '2p' $project_dir/$project_name/logs.txt`
n_mol=`sed -n '8p' $project_dir/$project_name/logs.txt`

pr_it=$(($iteration-1)) 

t_cpu=$cpus

mol_to_dock=$mol

if [ $iteration == 1 ]
then 
     	to_d=$((n_mol+n_mol+mol_to_dock))
else
    	to_d=$mol_to_dock
fi

echo $to_d
echo $t_cpu

python DD_protocol/jobid_writer.py -pt $protein -fp $file_path -n_it $iteration -jid $PBS_JOBNAME -jn $PBS_JOBNAME.txt

morgan_directory=`sed -n '4p' $project_dir/$project_name/logs.txt`
smile_directory=`sed -n '5p' $project_dir/$project_name/logs.txt`
sdf_directory=`sed -n '6p' $project_dir/$project_name/logs.txt`

if [ $iteration == 1 ];then pred_directory=$morgan_directory;else pred_directory=$file_path/$protein/iteration_$pr_it/morgan_1024_predictions;fi

python DD_protocol/scripts_1/molecular_file_count_updated.py -pt $protein -it $iteration -cdd $pred_directory -t_pos $t_cpu -t_samp $to_d
python DD_protocol/scripts_1/sampling.py -pt $protein -fp $file_path -it $iteration -dd $pred_directory -t_pos $t_cpu -tr_sz $mol_to_dock -vl_sz $n_mol
python DD_protocol/scripts_1/sanity_check.py -pt $protein -fp $file_path -it $iteration
python DD_protocol/scripts_1/extracting_morgan.py -pt $protein -fp $file_path -it $iteration -md $morgan_directory -t_pos $t_cpu
python DD_protocol/scripts_1/extracting_smiles.py -pt $protein -fp $file_path -it $iteration -smd $smile_directory -t_pos $t_cpu

end=`date +%s`
runtime=$((end-start))
echo $runtime
