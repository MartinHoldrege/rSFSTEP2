#Bash script to submit file comparison to a super computer
#To run this script: ./compare_sbatch.sh <number_of_sites>
#!/bin/bash

for ((i=1;i<=$1;i++));do (
        cd R_program_$i/STEPWAT_DIST
        sbatch sample.sh
        cd ..)&
done
wait
