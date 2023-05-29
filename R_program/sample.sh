#!/bin/bash

#Assign Job Name
#SBATCH --job-name=stepwat2

#Assign Account Name
#SBATCH --account=sagebrush

#Set Max Wall Time
#days-hours:minutes:seconds
#SBATCH --time=24:00:00

#Specify Resources Needed
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=14
#SBATCH --mem=128000

#Load Required Modules
module load arcc/1.0
module load gcc/12.2.0
module load r/4.2.2

srun Rscript Main.R
echo "Site noid done!" >> /project/sagebrush/kpalmqu1/jobs.txt

