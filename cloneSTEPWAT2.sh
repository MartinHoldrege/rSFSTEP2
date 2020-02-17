#Clones STEPWAT2, compiles it, and then removes any files that are not necessary for running rSFSTEP2
#To run in a terminal: ./cloneSTEPWAT2.sh

cd R_program
#module load git/2.17.1
wait
git clone --branch feature_phenology_biomass_scaling --recursive https://github.com/DrylandEcology/STEPWAT2.git
wait
cd STEPWAT2
make
wait
#remove everything that is not needed after the make
rm -rf .git*
rm *.c
rm *.h
rm -rf tools
rm -rf sw_src
rm -rf obj
rm README.md
rm appveyor.yml
rm makefile
rm stepwat_test_job.sh
rm -rf sqlite-amalgamation
rm -rf Documentation
rm doxyfile
rm stepwat_test
rm -rf test 
wait
cd ../..
