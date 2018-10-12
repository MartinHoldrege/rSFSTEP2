#!/bin/bash
#./generate_stepwat_sites.sh <wrapper_folder_to_copy> <number_of_sites> <number_of_scenario>
siteid=(1) #add site ids here


cd StepWat_R_Wrapper_Parallel
#module load git/2.17.1
wait
git clone --branch resource_partitioning_overhaul --recursive https://github.com/DrylandEcology/STEPWAT2.git
wait
cd STEPWAT2
make
wait
rm -rf .git*
wait
cd ../..

for ((i=1;i<=$2;i++));do (
	cp -r $1 StepWat_R_Wrapper_$i
	cd StepWat_R_Wrapper_$i
	python assignsiteid.py $(pwd) ${siteid[$(($i-1))]} $i
	for((j=1;j<=$3;j++));do
		cp -r STEPWAT2 Stepwat.Site.$i.$j
	done
	rm -rf STEPWAT2
	cd .. ) &
done
wait
touch jobs.txt

rm -rf StepWat_R_Wrapper_Parallel
wait

