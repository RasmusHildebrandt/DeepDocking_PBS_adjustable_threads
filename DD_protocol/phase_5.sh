#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -N phase_5

cd $file_path
module load anaconda3/personal


env=dd-env

source ~/.bashrc
conda activate $env

file_path=`sed -n '1p' $file_path/projects/$project_name/logs.txt`
protein=`sed -n '2p' $file_path/projects/$project_name/logs.txt`    # name of project folder

morgan_directory=`sed -n '4p' $file_path/projects/$project_name/logs.txt`

num_molec=`sed -n '8p' $file_path/projects/$project_name/logs.txt`

gpu_part=gp_p

python DD_protocol/jobid_writer.py -pt $protein -fp $file_path -n_it $iteration -jid $PBS_JOBNAME -jn $PBS_JOBNAME.txt

echo "Starting Evaluation"
python -u DD_protocol/scripts_2/hyperparameter_result_evaluation.py -n_it $iteration -d_path $file_path/$protein -mdd $morgan_directory -n_mol $num_molec -ct $recall_v
echo "Creating simple_job_predictions"
python DD_protocol/scripts_2/simple_job_predictions.py -pt $protein -fp $file_path -n_it $iteration -mdd $morgan_directory -gp $gpu_part -tf_e $env

cd $file_path/$protein/iteration_$iteration/simple_job_predictions/
echo "running simple_jobs"
for f in *.sh;do qsub $f;done

