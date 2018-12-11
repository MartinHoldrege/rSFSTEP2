#Script to copy all Output_site_databases to a particular location on Teton or a local machine
#!/bin/bash
site=51
path=/project/sagebrush/kpalmqu1/sitedata/
for ((i=1;i<=$site;i++));do (
	cd R_program_$i
	cp Output_site_* $path
	cd ..)&
done
wait

