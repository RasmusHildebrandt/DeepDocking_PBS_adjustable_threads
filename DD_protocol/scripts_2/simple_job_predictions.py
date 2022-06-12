import argparse
import glob
import os

parser = argparse.ArgumentParser()
parser.add_argument('-pt', '--project_name', required=True, help='Name of DD project')
parser.add_argument('-fp', '--file_path', required=True, help='Path to project folder without project folder name')
parser.add_argument('-n_it', '--n_iteration', required=True, help='Number of current iteration')
parser.add_argument('-mdd', '--morgan_directory', required=True, help='Path to Morgan fingerprint directory')
parser.add_argument('-gp','--gpu_part',required=True,help='name(s) of GPU partitions')
parser.add_argument('-tf_e','--tensorflow_env',required=True,help='name of tensorflow-gpu environment')

# adding parameter for where to save all the data to:
parser.add_argument('-save', '--save_path', required=False, default=None)

io_args = parser.parse_args()

protein = io_args.project_name
n_it = int(io_args.n_iteration)
mdd = io_args.morgan_directory
gpu_part = str(io_args.gpu_part)
env  = str(io_args.tensorflow_env)

DATA_PATH = io_args.file_path
DATA_PATH = DATA_PATH + '/' + protein
SAVE_PATH = io_args.save_path
# if no save path is provided we just save it in the same location as the data
if SAVE_PATH is None: SAVE_PATH = DATA_PATH

add = mdd

try:
    os.mkdir(SAVE_PATH + '/iteration_' + str(n_it) + '/simple_job_predictions')
except OSError:
    pass

for f in glob.glob(SAVE_PATH + '/iteration_' + str(n_it) + '/simple_job_predictions/*'):
    os.remove(f)

time = '0-10:30'

# temp = []
part_files = []

for i, f in enumerate(glob.glob(add + '/*.txt')):
    part_files.append(f)

ct = 1
for f in part_files:
    with open(SAVE_PATH + '/iteration_' + str(n_it) + '/simple_job_predictions/simple_job_' + str(ct) + '.sh', 'w') as ref:
        ref.write('#!/bin/bash\n')
        ref.write('#PBS -l select=1:ncpus=1:mem=12gb:ngpus=1\n')
        ref.write('#PBS -N phase_5\n')
        ref.write('#PBS -l walltime=12:00:00\n')
        ref.write('cd $PBS_O_WORKDIR\n')
        ref.write('module load anaconda3/personal\n')
        cwd = os.getcwd()
        ref.write('cd {}/DD_protocol/scripts_2\n'.format(cwd))
        ref.write('source ~/.bashrc\n')
        ref.write('conda activate %s\n'%env)
        ref.write('python -u ' + 'Prediction_morgan_1024.py' + ' ' + '-fn' + ' ' + f.split('/')[
            -1] + ' ' + '-protein' + ' ' + protein + ' ' + '-it' + ' ' + str(n_it) + ' ' + '-mdd' + ' ' + str(
            mdd) + ' ' + '-file_path' + ' ' + SAVE_PATH + '\n')
        ref.write("\n echo complete")

    ct += 1
