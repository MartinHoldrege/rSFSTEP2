#!/bin/bash
#./generate_rSFSTEP2_structure.sh <R_program> <number_of_sites> <number_of_scenario>
siteid=(5 15) #site ids here

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
