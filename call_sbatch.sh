#Bash script to submit all sites to Mount Moran
#To run this script, in the terminal type : ./call_sbatch.sh <number_of_sites>
#!/bin/bash

for ((i=1;i<=$1;i++));do (
        cd StepWat_R_Wrapper_$i
        sbatch sample.sh
        cd ..)&
done
wait
