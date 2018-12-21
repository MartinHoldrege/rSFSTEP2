#Bash script to submit all sites to a super computer
#To run this script: ./call_sbatch.sh <number_of_sites>
#!/bin/bash

for ((i=1;i<=$1;i++));do (
        cd R_program_$i
        sbatch sample.sh
        cd ..)&
done
wait
