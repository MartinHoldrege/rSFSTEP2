#Bash script to compile csv files into a sqlite database using makedatabase.R
#To run this script, in the terminal type : ./run_local_database.sh <number_of_sites>

#!/bin/bash
for ((i=1;i<=$1;i++));do (
        cd StepWat_R_Wrapper_$i
        Rscript makedatabase.R
	wait
        cd ..)&
done
wait
