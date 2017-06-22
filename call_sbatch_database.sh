#Bash script to submit all sites to Mount Moran for database assembly after runs have completed
#To run this script: ./call_sbatch_database.sh <number_of_sites>
#!/bin/bash

for ((i=1;i<=$1;i++));do (
        cd StepWat_R_Wrapper_$i
        sbatch makedatabase.sh
        cd ..)&
done
wait
