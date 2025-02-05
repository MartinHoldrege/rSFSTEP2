#!/bin/bash

#Assign Job Name
#SBATCH --job-name=stepwat2

#Assign Account Name
#SBATCH --account=swbsc

#Set Max Wall Time
#days-hours:minutes:seconds
#SBATCH --time=18:00:00

#Specify Resources Needed
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=14
#SBATCH --mem=128000

#Load Required Modules
#module load arcc/1.0
module load gcc-native
module load cray-R

srun Rscript Main.R
echo "Site noid done! $(date '+%Y-%m-%d %H:%M:%S')" >> ../../jobs.txt

