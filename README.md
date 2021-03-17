# rSFSTEP2

# Cloning the repository:
```
git clone --branch master https://github.com/DrylandEcology/rSFSTEP2.git
```

# Instructions for running rSFSTEP2

Required R packages for rSFSTEP2: 
DBI, RSQLite, [rSOILWAT2](https://github.com/DrylandEcology/rSOILWAT2#installation), [rSW2utils](https://github.com/DrylandEcology/rSW2utils#installation), doParallel, synchronicity

On a super computer:
--
1. Make sure all the scripts are executable (i.e. given executable permissions) prior to following the steps below: chmod +x nameoffile
2. Copy the weather database to the inputs folder within rSFSTEP2.
3. Set the location of the weather database in the Main.R script of the R_program folder (where it says set database location), along with the name of the weather database (where it says Provide the name of the database in quotes).
4. In Main.R, set the proc_count based on the number of CPUs on each node of the super computer. Also set simyears, which the number of STEPWAT2 simulation years provided in model.in. The default is 300.
5. Edit the default climate scenarios you wish to run, specified in climate.conditions. The number of GCMs listed here must match <number_of_scenarios> below in the call to generate_rSFSTEP2_structure.sh (RCPs and time periods are not counted).
	For example - if you have 10 GCMs for 2 RCPs and "Current" in climate.conditions, the correct <number_of_scenarios> = 11 in the generate_rSFSTEP2_structure.sh call.
6. Ensure that the weather database variables listed in Main.R match those in the weather database you are using. This includes: climate.conditions, simstartyr, endyr, climate.ambient, deltaFutureToSimStart_yr, downscaling.method, and YEARS.
7. Add site ids, you wish to run the wrapper on, to the siteid variable (third line from top) in the generate_rSFSTEP2_structure.sh script. Site 1 and 2 are present as examples.
8. Edit jobname, accountname and the location of results.txt (last line) in the sample.sh script, located in the R_program folder. Adjust wall time and nodes/cpus required if necessary.
9. Edit jobname and accountname in the outputdatabase.sh script, located in R_program folder. 
10. Run the cloneSTEPWAT2.sh script.
11. Run the generate_rSFSTEP2_structure.sh script. The parameters are <R_program> <number_of_sites> <number_of_scenarios>
12. Run the call_sbatch.sh script. The parameter is <number_of_sites>. 

Once the sbatch tasks have been succesfully completed, follow the steps below to compile all Output.sqlite files into a single database:

10. Once the data is compiled into a SQLite database (for individual sites), edit the number of sites (variable names `site`) and location (variable named `path`) where you wish to collect the data, in the copydata.sh script.
11. Run the copydata.sh script to copy the SQLite databases from each folder into a master folder.
12. In `CombineOutputDatabases.R` modify the `dir_db` variable with the loaction of the databases.
13. In `CombineOutputDatabases.R` modify the `sites` variable with the site ids you used.
14. Run (`Rscript CombineOutputDatabases.R`) to combine all of the databases into a single database.

On a local machine:
--
1. Make sure all the scripts are executable (i.e. given executable permissions) prior to following the steps below: chmod +x nameoffile
2. Copy the weather database to the inputs folder within rSFSTEP2.
3. Set the location of the weather database in the Main.R script of the R_program folder (where it says set database location), along with the name of the weather database (where it says Provide the name of the database in quotes).
4. In Main.R, set the proc_count based on the number of cores on the computer. Also set simyears, which the number of STEPWAT2 simulation years provided in model.in. The default is 300.
5. Edit the default climate scenarios you wish to run, specified in climate.conditions. The number of GCMs listed here must match <number_of_scenarios> below in the call to generate_rSFSTEP2_structure.sh (RCPs and time periods are not counted).
	For example - if you have 10 GCMs for 2 RCPs and "Current" in climate.conditions, the correct <number_of_scenarios> = 11 in the generate_rSFSTEP2_structure.sh call.
6. Ensure that the weather database variables listed in Main.R match those in the weather database you are using. This includes: climate.conditions, simstartyr, endyr, climate.ambient, deltaFutureToSimStart_yr, downscaling.method, and YEARS.
7. Add site ids, you wish to run the wrapper on, to the siteid variable (third line from top) in the generate_rSFSTEP2_structure.sh script. Site 1 and 2 are present as examples.
8. Run the cloneSTEPWAT2.sh script.
9. Run the generate_rSFSTEP2_structure.sh script. The parameters are <R_program> <number_of_sites> <number_of_scenarios>
10. Run the run_local.sh script. The parameter is <number_of_sites>. 

Once the sbatch tasks have been succesfully completed, follow the steps below to compile all Output.sqlite files into a single database:

8. Once the data is compiled into a SQLite database (for individual sites), edit the number of sites (variable site) and location (variable path) where you wish to collect the data, in the copydata.sh script.
9. Run the copydata.sh script to copy the SQLite databases from each folder into a master folder.
12. In `CombineOutputDatabases.R` modify the `dir_db` variable with the loaction of the databases.
13. In `CombineOutputDatabases.R` modify the `sites` variable with the site ids you used.
14. Run (`Rscript CombineOutputDatabases.R`) to combine all of the databases into a single database.

Note: The method to run a shell script is present as a comment in the respective script. 

## Comparing generated files
rSFSTEP2 has the options to scale phenological activity, biomass, litter, and % live fractions along with space based on site-specific current or future climate. After running the simulation you can generate statistics and graphics demonstrating how the input files were modified. 
### On a local computer:
```
./compare_files.sh <number of sites>
```
### On a supercomputer:
```
./compare_sbatch.sh <number of sites>
```

The results will be stored in `rSFSTEP2/R_program_??/STEPWAT_DIST/output/` where ?? is the site number.

## Note: repository renamed from StepWat_R_Wrapper_parallel to rSFSTEP2 on Feb 23, 2017

All existing information should [automatically be redirected](https://help.github.com/articles/renaming-a-repository/) to the new name.

Contributors are encouraged, however, to update local clones to [point to the new URL](https://help.github.com/articles/changing-a-remote-s-url/), i.e., 
```
git remote set-url origin https://github.com/Burke-Lauenroth-Lab/rSFSTEP2.git
```

All instructions and necessary parameters for running shell scripts are at the top of each file

See syntax_inputs.txt in the inputs folder for a description of the input options and how to specify site-specific and fixed inputs
