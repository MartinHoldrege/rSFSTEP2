#Bash script to run the wrapper for all specified sites on local machine
#To run this script, in the terminal type : ./run_local.sh <number_of_sites>

#!/bin/bash
for ((i=1;i<=$1;i++));do (
        cd StepWat_R_Wrapper_$i
        Rscript STEPWAT.Wrapper.MAIN_V3.R
	wait
        cd ..)&
done
wait
