Following are the steps to run the wrapper on MT Moran, and get the results in a SQLite Database:

Note: The method to run a shell script, is present as a comment in the respective script. 

Note: Make sure all the scripts are executable (i.e. given executable permissions) prior to following the steps below: chmod +x nameoffile

1. Copy the weather database to the inputs folder.
2. Set the location of the weather database in the STEPWAT.Wrapper.MAIN_V3.R script of the StepWat_R_Wrapper_Parallel folder (where it says set database location), along with the name of the weather database (where it says provide the name of the database in quotes).
3. Add site ids, you wish to run the wrapper on, to the siteid variable (third line from top) in the generate_stepwat_sites.sh script. Site id 1 is present, as an example.
3. Edit jobname, accountname and the location of results.txt (last line) in the sample.sh script, located in StepWat_R_Wrapper_Parallel. Adjust wall time and nodes/cpus required if necessary.
5. Edit jobname and accountname in the makedatabase.sh script, located in StepWat_R_Wrapper_Parallel folder.
6. Run the generate_stepwat_sites.sh script.
7. Run the call_sbatch.sh script.

Once the sbatch tasks have been successfully run on MT Moran, follow the steps below:

8. Run the call_sbatch_database.sh script.
9. Once the data is compiled into a sqlite database (for individual sites), edit the number of sites (variable site) and location (variable path) where you wish to collect the data, in the copydata.sh script.
10. Run the copydata.sh script.

Note: You could also use globus to copy the data, into the desired folder.

%------------------------------------------------------------------------------------------------------------------------------------------------------------------------%

Following are the steps to run the wrapper on a local machine, and get the results in a SQLite Database:

Note: The method to run a shell script, is present as a comment in the respective script. 

Note: Make sure all the scripts are executable (i.e. given executable permissions) prior to following the steps below.

1. Copy the weather database to the inputs folder.
2. Set the location of the weather database in the STEPWAT.Wrapper.MAIN_V3.R script of the StepWat_R_Wrapper_Parallel folder (where it says set database location), along with the name of the weather database (where it says provide the name of the database in quotes).
3. Add site ids, you wish to run the wrapper on, to the siteid variable (third line from top) in the generate_stepwat_sites.sh script. Site id 1 is present, as an example.
4. Run the generate_stepwat_sites.sh script.
5. Run the run_local.sh script.

Once the sbatch tasks have been succesfully run on MT Moran, follow the steps below:

6. Run the run_local_database.sh script.