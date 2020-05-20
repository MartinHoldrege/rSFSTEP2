#!/bin/bash

#Assign Job Name
#SBATCH --job-name=stepwat2

#Assign Account Name
#SBATCH --account=sagebrush

#Set Max Wall Time
#days-hours:minutes:seconds
#SBATCH --time=1:00:00

#Specify Resources Needed
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=128000

#Load Required Modules
module load gcc/7.3.0
module load swset/2018.05
module load r/3.5.0

srun Rscript compareFiles.R
echo "Site noid done!" >> /project/sagebrush/kpalmqu1/jobs.txt

