#!/bin/bash

#Assign Job Name
#SBATCH --job-name=stepwat2

#Assign Account Name
#SBATCH --account=kulmatiski

#Set Max Wall Time
#days-hours:minutes:seconds
#SBATCH --time=01:30:00

# using shared nodes
#SBATCH --partition=kingspeak-shared

#Specify Resources Needed
# #SBATCH --nodes=1
# #SBATCH --ntasks-per-node=1
# switch to 14 later, now just 4 for test
# #SBATCH --cpus-per-task=1

# number of cores requested--I have changeed this because am using shared
#SBATCH --ntasks=1
#SBATCH --mem=16000

#Load Required Modules
#module load gcc/7.3.0
#module load swset/2018.05
module load R

start_time=$(date '+%d/%m/%Y %H:%M:%S') # I'm adding this so can see long it takes to run
srun Rscript Main.R
now=$(date '+%d/%m/%Y %H:%M:%S')
echo "Site noid done! run started: $start_time ended: $now" >> /uufs/chpc.utah.edu/common/home/kulmatiski-group1/stepwat/sitedata/jobs.txt
