#Script to copy all Output_site_databases to a particular location
#!/bin/bash
site=4
path=/uufs/chpc.utah.edu/common/home/kulmatiski-group1/stepwat/sitedata/
for ((i=1;i<=$site;i++));do (
	cd R_program_$i
	mv Output_site* $path
	cd ..)&
done
wait

