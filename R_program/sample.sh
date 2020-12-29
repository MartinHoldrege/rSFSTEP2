#!/bin/bash

#Assign Job Name
#SBATCH --job-name=stepwat2

#Assign Account Name
#SBATCH --account=kulmatiski

#Set Max Wall Time
#days-hours:minutes:seconds
#SBATCH --time=48:00:00

#Specify Resources Needed
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
# switch to 14 later, now just 4 for test
#SBATCH --cpus-per-task=14
#SBATCH --mem=128000

#Load Required Modules
#module load gcc/7.3.0
#module load swset/2018.05
module load R

srun Rscript Main.R
echo "Site noid done!" >> ~/stepwat/sitedata/jobs.txt

