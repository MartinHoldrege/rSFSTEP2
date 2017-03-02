#!/bin/bash
site=51
path=/project/arccinterns/ksodhi/sitedata/
for ((i=1;i<=$site;i++));do (
	cd StepWat_R_Wrapper_$i
	cp Output_site_* $path
	cd ..)&
done
wait

