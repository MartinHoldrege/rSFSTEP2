#!/bin/bash

#Assign Job Name
#SBATCH --job-name=makeoutputdatabases

#Assign Account Name
#SBATCH --account=sagebrush

#Set Max Wall Time
#days-hours:minutes:seconds
#SBATCH --time=48:00:00

#Specify Resources Needed
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1

#Load Required Modules

module load intel/18.0.1
module load gcc/7.3.0
module load swset/2018.05
module load r/3.5.0

srun Rscript makedatabase.R

