# rSFSTEP2

# Cloning the repository:
```
git clone --branch master https://github.com/DrylandEcology/rSFSTEP2.git
```

# Instructions for running rSFSTEP2

Required R packages for rSFSTEP2: 
DBI, RSQLite, rSOILWAT2, doParallel

On a super computer:
--
1. Make sure all the scripts are executable (i.e. given executable permissions) prior to following the steps below: chmod +x nameoffile
2. Copy the weather database to the inputs folder within rSFSTEP2.
3. Set the location of the weather database in the Main.R script of the R_program folder (where it says set database location), along with the name of the weather database (where it says Provide the name of the database in quotes).
4. Add site ids, you wish to run the wrapper on, to the siteid variable (third line from top) in the generate_rSFSTEP2_structure.sh script. Site 1 and 2 are present as examples.
5. Edit jobname, accountname and the location of results.txt (last line) in the sample.sh script, located in the R_program folder. Adjust wall time and nodes/cpus required if necessary.
6. Edit jobname and accountname in the outputdatabase.sh script, located in R_program folder.
7. Run the cloneSTEPWAT2.sh script.
8. Run the generate_rSFSTEP2_structure.sh script. The parameters are <Location of R_program> <number_of_sites> <number_of_scenario>
9. Run the call_sbatch.sh script.

Once the sbatch tasks have been succesfully completed, follow the steps below to compile all output.csv files into a SQLite database:

9. Reset the number of GCMs used in OutputDatabase.R if not 14.
10. Run the call_sbatch_database.sh script.
11. Once the data is compiled into a SQLite database (for individual sites), edit the number of sites (variable site) and location (variable path) where you wish to collect the data, in the copydata.sh script.
12. Run the copydata.sh script to copy the SQLite databases from each folder into a master folder.

On a local machine:
--
1. Make sure all the scripts are executable (i.e. given executable permissions) prior to following the steps below: chmod +x nameoffile
2. Copy the weather database to the inputs folder within rSFSTEP2.
3. Set the location of the weather database in the Main.R script of the R_program folder (where it says set database location), along with the name of the weather database (where it says Provide the name of the database in quotes).
4. Add site ids, you wish to run the wrapper on, to the siteid variable (third line from top) in the generate_rSFSTEP2_structure.sh script. Site 1 and 2 are present as examples.
5. Run the cloneSTEPWAT2.sh script.
6. Run the generate_rSFSTEP2_structure.sh script. The parameters are <Location of R_program> <number_of_sites> <number_of_scenario>
7. Run the run_local.sh script.

Once the sbatch tasks have been succesfully completed, follow the steps below to compile all output.csv files into a SQLite database:

7. Reset the number of GCMs used in OutputDatabase.R if not 14.
8. Run the run_local_database.sh script.
9. Once the data is compiled into a SQLite database (for individual sites), edit the number of sites (variable site) and location (variable path) where you wish to collect the data, in the copydata.sh script.
10. Run the copydata.sh script to copy the SQLite databases from each folder into a master folder.

Note: The method to run a shell script is present as a comment in the respective script. 

## Comparing generated files
rSFSTEP2 has the options to scale phenology and/or space based on site and climate. After running the simulation you can get some statistics on how the inputs were modified by running
```
./compare_files.sh <number of sites>
```
The results will be stored in `rSFSTEP2/R_program_??/STEPWAT_DIST/output/` where ?? is the site number. The generated comparison files essentially compare how the input text files were modified.

## Note: repository renamed from StepWat_R_Wrapper_parallel to rSFSTEP2 on Feb 23, 2017

All existing information should [automatically be redirected](https://help.github.com/articles/renaming-a-repository/) to the new name.

Contributors are encouraged, however, to update local clones to [point to the new URL](https://help.github.com/articles/changing-a-remote-s-url/), i.e., 
```
git remote set-url origin https://github.com/Burke-Lauenroth-Lab/rSFSTEP2.git
```


See syntax_inputs.txt in the inputs folder for a description of the input options and how to specify site-specific and fixed inputs
