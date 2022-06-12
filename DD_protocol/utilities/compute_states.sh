#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=1:mem=2gb
#PBS -J 0-255

cd $PBS_O_WORKDIR


name_in=$(echo library/smiles_all_$PBS_ARRAY_INDEX.smi | cut -d'.' -f1)
name_out=$(echo $name_in | rev | cut -d'/' -f1 | rev)

echo "Calculating states for $name_in"

start=`date +%s`

mkdir -p library_prepared

$openeye flipper -in library/smiles_all_$PBS_ARRAY_INDEX.smi -out $name_in'_'isom.smi -warts
wait

$openeye tautomers -in $name_in'_'isom.smi -out $name_in'_'states.smi -maxtoreturn 1 -warts false
wait

rm $name_in'_'isom.smi
mv $name_in'_'states.smi library_prepared/$name_out'.'txt

end=`date +%s`
runtime=$((end-start))
echo $runtime
