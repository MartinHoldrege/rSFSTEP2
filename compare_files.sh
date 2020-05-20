#Bash script to compare dynamically derived values (phenology, space) for all sites. 
#Results output to 'output' directory in the respective STEPWAT_DIST directories.
#Syntax: ./compare_files.sh <number of sites>

for ((i=1;i<=$1;i++));do (
        cd R_program_$i/STEPWAT_DIST
        Rscript compareFiles.R
	wait
        cd ..)&
done
wait
