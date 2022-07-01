#!/bin/bash
#PBS -l walltime=48:00:00
#PBS -N progressive_evaluation

cd $file_path
module load anaconda3/personal

eval_location=$eval_l
project_name=$project_n
name_gpu_partition=$gpu_p
percent_first_mols=$percent_fm
percent_last_mols=$percent_lm
recall_value=$recall_v
max_size=$max_s
min_size=$min_s
n_steps=$n_s
time=${tim}
env=${en}

source ~/.bashrc

morgan_path=$(sed -n '4p' $file_path/projects/$project_name/logs.txt)
n_mol_vt=$(sed -n '8p' $file_path/projects/$project_name/logs.txt)

# Calculate the step size
let step_size=($max_size-$min_size)/$(expr $n_steps - 1)

evaluation(){
  # Run the evaluation at each sample size
  echo ">> Running iteration $i with sample size $size"
  qsub -v iteration="1",p_pos="3",eval_l2="$eval_location",project_n2="$project_name",gpu_p2="$name_gpu_partition",next_it="2",percent_fm2="$percent_first_mols",percent_lm2="$percent_last_mols",recall_v2="$recall_value",tim2="$time",en="$env",size2="$size" DD_protocol/phase_4_evaluator.sh


  # Wait for phase 4 to complete
  python3 -u DD_protocol/scripts_2/progressive_evaluator.py --sample_size $size --project_name $project_name --project_path $eval_location --mode wait_phase_4

  # Activate the conda env and run the hyperparameter result eval script
  source activate $env
  python -u DD_protocol/scripts_2/hyperparameter_result_evaluation.py -n_it 1 -d_path $eval_location/$project_name -mdd $morgan_path -n_mol $n_mol_vt

  # Wait for phase 4 to complete
  python3 DD_protocol/scripts_2/progressive_evaluator.py --sample_size $size --project_name $project_name --project_path $eval_location --mode finished_iteration
}


# Run eval
# Loop through each value in the search
for ((i = 0 ; i < $n_steps ; i++)); do
   # Calculate sample size
   size=$(($min_size + $i*$step_size))
   echo $size
   evaluation
done
