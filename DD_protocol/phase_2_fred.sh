#!/bin/bash
#PBS -l walltime=01:00:00
#PBS -l select=1:ncpus=1:mem=1gb
#PBS -N phase_2

cd $file_path
source ~/.profile
module load anaconda3/personal

t_nod=$t_node
c_mem=2
unit="gb"
t_mem="$((t_node * c_mem))$unit"

file_path=`sed -n '1p' $file_path/projects/$project_name/logs.txt`
protein=`sed -n '2p' $file_path/projects/$project_name/logs.txt`

morgan_directory=`sed -n '4p' $file_path/projects/$project_name/logs.txt`
smile_directory=`sed -n '5p' $file_path/projects/$project_name/logs.txt`


python DD_protocol/jobid_writer.py -pt $protein -fp $file_path -n_it $iteration -jid $PBS_JOBNAME -jn $PBS_JOBNAME.txt

cd $file_path/$protein/iteration_$iteration
mkdir -p sdf
for f in smile/*_smiles_final_updated.smi
do
   tmp="$(cut -d'/' -f2 <<<"$f")"
   tmp="$(cut -d'_' -f1 <<<"$tmp")"
   if [ $tmp = train ];then name=training;fi
   if [ $tmp = valid ];then name=validation;fi
   if [ $tmp = test ];then name=testing;fi
   echo "#!/bin/bash
#PBS -l walltime=12:00:00

cd $PBS_O_WORKDIR
echo \$f_1
echo \$name1
echo \$t_nod1
oeomega pose -in $file_path/$protein/iteration_$iteration/smile/\$tmp1\_smiles_final_updated/\$tmp1\_smiles_final_updated_\$PBS_ARRAY_INDEX.smi -out $file_path/$protein/iteration_$iteration/sdf/\$name1\_ame1\_\$PBS_ARRAY_INDEX\_sdf.oeb.gz -strictstereo false -log \$name1.log -prefix \$name1\_\$PBS_ARRAY_INDEX">> $name'_'conf.sh

   qsub -N $PBS_JOBNAME -l select=1:ncpus=$t_node:mem=$t_mem -v f_1="$f",name1="$name",t_nod1="$t_nod",tmp1="$tmp" $name'_'conf.sh
done
wait

qdel $PBS_JOBID
