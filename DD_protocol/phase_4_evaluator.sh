#!/bin/bash
#PBS -l walltime=48:00:00
#PBS -l select=1:ncpus=1:mem=2gb
#PBS -N phase_4_eval


cd $file_path
module load anaconda3/personal
env=${en}
time=${tim2}

source ~/.bashrc
conda activate dd-env

file_path=$(sed -n '1p' $file_path/projects/$project_name/logs.txt)
protein=$(sed -n '2p' $file_path/projects/$project_name/logs.txt)

morgan_directory=$(sed -n '4p' $file_path/projects/$project_name/logs.txt
smile_directory=$(sed -n '5p' $file_path/projects/$project_name/logs.txt)
nhp=$(sed -n '7p' $file_path/projects/$project_name/logs.txt) # number of hyperparameters
sof=$(sed -n '6p' $file_path/projects/$project_name/logs.txt) # The docking software used

rec=$recall_v2

num_molec=$(sed -n '8p' $eval_l2/$project_n2/logs.txt)

echo "writing jobs"
python DD_protocol/jobid_writer.py -pt $protein -fp $file_path -n_it $iteration -jid $PBS_JOBNAME -jn $PBS_JOBNAME.txt

t_pos=$p_pos # total number of processers available
echo "Extracting labels"

if [ $sof = 'Glide' ]; then
  kw='r_i_docking_score'
elif [ $sof = 'FRED' ]; then
  kw='FRED Chemgauss4 score'
fi

python DD_protocol/scripts_2/extract_labels.py -n_it $iteration -pt $protein -fp $file_path -t_pos $t_pos -score "$kw"

if [ $? != 0 ]; then
  echo "Extract_labels failed... terminating"
  exit
fi

part_gpu=gpu_p2

if [ next_it = $iteration ]; then
  last='True'
else
  last='False'
fi

echo "Creating simple jobs"
python DD_protocol/scripts_2/simple_job_models.py -n_it $iteration -mdd $morgan_directory -time $time -file_path $file_path/$protein -nhp $nhp -titr $next_it -n_mol $num_molec -pfm $percent_fm2 -plm $per$
python3 -u DD_protocol/scripts_2/progressive_evaluator.py --sample_size ${size2} --project_name $protein --project_path $file_path --mode add_train_num_mol

cd $file_path/$protein/iteration_$iteration
rm model_no.txt
cd simple_job

echo "Running simple jobs"
#Executes all the files that were created in the simple_jobs directory
for f in simple_job_*.sh;do qsub $f;done
