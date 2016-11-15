#!/bin/bash
#./generate_stepwat_sites.sh <wrapper_folder_to_copy> <number_of_sites> <number_of_scenario>
siteid=(1 2 3 4 5 6 7 8 9 10) #add site ids here

cd StepWat_R_Wrapper_Parallel
module load git/2.9.2
wait
git clone https://github.com/Burke-Lauenroth-Lab/StepWat.git --branch SoilWat31_drs --single-branch StepWatv31 
wait
cd StepWatv31
git submodule update --init --recursive
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
		cp -r StepWatv31 Stepwat.Site.$i.$j
	done
	cd .. ) &
done
wait
touch jobs.txt
