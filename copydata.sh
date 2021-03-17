#Script to copy all Output_site_databases to a particular location
#!/bin/bash
site=14
path=~/stepwat/sitedata/
for ((i=1;i<=$site;i++));do (
	cd R_program_$i
	mv Output_site* $path
	cd ..)&
done
wait

