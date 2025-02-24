#Script to copy all Output_site_databases to a particular location
#!/bin/bash
site=200
path=../../results/sitedata/temp2rename/

# Ensure the directory exists
cd R_program
mkdir -p "$path"
cd ..

for ((i=1;i<=$site;i++));do (
	cd R_program_$i
	mv Output_site* $path
	cd ..)&
done
wait

