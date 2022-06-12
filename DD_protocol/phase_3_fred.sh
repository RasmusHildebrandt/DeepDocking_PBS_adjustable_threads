#!/bin/bash
#PBS -l walltime=01:00:00
#PBS -l select=1:ncpus=1:mem=1gb
#PBS -N phase_3

cd $PBS_O_WORKDIR
source ~/.profile
module load anaconda3/personal

t_nod=$t_node
c_mem=2
unit="gb"
t_mem="$((t_node * c_mem))$unit"
sdf_file="_sdf.oeb.gz"
Iteration_name=
iteration_dir="iteration_$iteration"

file_path=`sed -n '1p' $project_dir/$project_name/logs.txt`
protein=`sed -n '2p' $project_dir/$project_name/logs.txt`
grid_file=`sed -n '3p' $project_dir/$project_name/logs.txt`

morgan_directory=`sed -n '4p' $project_dir/$project_name/logs.txt`
smile_directory=`sed -n '5p' $project_dir/$project_name/logs.txt`


python DD_protocol/jobid_writer.py -pt $protein -fp $file_path -n_it $iteration -jid $PBS_JOBNAME -jn $PBS_JOBNAME.txt

cd $file_path/$protein/iteration_$iteration
mkdir -p docked
cd docked

for f in ../smile/*_smiles_final_updated
do
    temp=$(echo $f | rev | cut -d'/' -f1 | rev)
    temp=$(echo $temp | cut -d'_' -f1)
    if [ $temp = train ];then name=training;fi
    if [ $temp = valid ];then name=validation;fi
    if [ $temp = test ];then name=testing;fi
    echo "#!/bin/bash
#PBS -l walltime=24:00:00
#PBS -J 0-255
cd \$PBS_O_WORKDIR
echo \$PBS_O_WORKDIR
echo \$grid
echo \$d_base
echo \$temp_1
echo \$t_nod1
fred -mpi_np 4 -receptor \$grid -dbase $file_path/$protein/iteration_$iteration/sdf/\$name1\_\$PBS_ARRAY_INDEX\_sdf.oeb.gz -docked_molecule_file $file_path/$protein/iteration_$iteration/docked/phase_3_\$temp_1\_docked/phase_3_\$temp_1\_docked_\$PBS_ARRAY_INDEX.sdf -hitlist_size 0 -prefix \$temp_1\_\$PBS_ARRAY_INDEX
rm *undocked*sdf">>$temp'_'docking.sh
    
    qsub -N $PBS_JOBNAME -l select=1:ncpus=$t_node:mem=$t_mem:cpu_type=ivy -v grid="$grid_file",temp_1="$temp",name1="$name",t_nod1="$t_nod" $temp'_'docking.sh

done
wait
 
qdel $PBS_JOBID

