#Script to copy all Output_site_databases to a particular location
#!/bin/bash
site=2
path=~/stepwat/sitedata/
for ((i=1;i<=$site;i++));do (
	cd R_program_$i
	mv Output_site* $path
	cd ..)&
done
wait

