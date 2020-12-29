#Bash script to compile csv files into a sqlite database using OutputDatabase.R
#To run this script, in the terminal type : ./run_local_database.sh <number_of_sites>

#!/bin/bash
for ((i=1;i<=$1;i++));do (
        cd R_program_$i
        Rscript OutputDatabase.R
	wait
        cd ..)&
done
wait
