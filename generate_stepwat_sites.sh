#!/bin/bash
#./generate_stepwat_sites.sh <R_program> <number_of_sites> <number_of_scenario>
siteid=(1) #add site ids here


cd R_program
#module load git/2.17.1
wait
git clone --branch master --recursive https://github.com/DrylandEcology/STEPWAT2.git
wait
cd STEPWAT2
make
wait
rm -rf .git*
wait
cd ../..

for ((i=1;i<=$2;i++));do (
	cp -r $1 R_program_$i
	cd R_program_$i
	python assignsiteid.py $(pwd) ${siteid[$(($i-1))]} $i
	for((j=1;j<=$3;j++));do
		cp -r STEPWAT2 Stepwat.Site.$i.$j
	done
	rm -rf STEPWAT2
	cd .. ) &
done
wait
touch jobs.txt

rm -rf R_program
wait

