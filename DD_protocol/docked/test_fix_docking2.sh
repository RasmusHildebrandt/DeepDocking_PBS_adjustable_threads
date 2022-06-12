#!/bin/bash
#PBS -l walltime=24:00:00
cd $PBS_O_WORKDIR
echo $PBS_O_WORKDIR
echo $grid
echo $d_base
echo $temp_1
echo $t_nod1
fred -mpi 8 -receptor $grid -dbase //iteration_/sdf/$temp_1\_smiles_final_updated/$name1\_91\_sdf.oeb.gz -docked_molecule_file //iteration_/docked/phase_3_$temp_1\_docked/phase_3_$temp_1\_docked_\91.sdf -hitlist_size 0 -prefix $temp_1\_\91
rm *undocked*sdf
