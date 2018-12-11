#Bash script to run the wrapper for all specified sites on local machine
#To run this script, in the terminal type : ./run_local.sh <number_of_sites>

#!/bin/bash
for ((i=1;i<=$1;i++));do (
        cd R_program_$i
        Rscript Main.R
	wait
        cd ..)&
done
wait
