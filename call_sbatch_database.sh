#Bash script to submit all sites to Teton for database assembly after runs have completed
#To run this script: ./call_sbatch_database.sh <number_of_sites>
#!/bin/bash

for ((i=1;i<=$1;i++));do (
        cd R_program_$i
        sbatch outputdatabase.sh
        cd ..)&
done
wait
