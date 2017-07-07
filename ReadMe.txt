Following are the steps to run the wrapper on MT Moran, and get the results in a SQLite Database:

Note: The method to run a shell script, is present as a comment in the respective script. 

Note: Make sure all the scripts are executable (i.e. given executable permissions) prior to following the steps below: chmod +x nameoffile

1. Change working directory to the StepWat_R_Wrapper_Parallel folder. Make sure to set the location of the database in the main script of this folder.
2. Add site ids, you wish to run the wrapper on, to the siteid variable (third line from top) in the generate_stepwat_sites.sh script. Site ids 1-10 are already present, as examples.
3. Edit jobname, accountname and the location of results.txt (last line) in the sample.sh script, located in StepWat_R_Wrapper_Parallel.
4. Edit jobname and accountname in the makedatabase.sh script, located in StepWat_R_Wrapper_Parallel folder.
5. Run the generate_stepwat_sites.sh script.
6. Run the call_sbatch.sh script.

Once the sbatch tasks have been succesfully run on MT Moran, follow the steps below:

7. Run the call_sbatch_database.sh script.
8. Once the data is compiled into a sqlite database (for individual sites), edit the number of sites (variable site) and location (variable path) where you wish to collect the data, in the copydata.sh script.
9. Run the copydata.sh script.

Note: You could also use globus to copy the data, into the desired folder.

%------------------------------------------------------------------------------------------------------------------------------------------------------------------------%

Following are the steps to run the wrapper on a local machine, and get the results in a SQLite Database:

Note: The method to run a shell script, is present as a comment in the respective script. 

1. Extract/Copy the contents of the tar file, in a folder.

Note: Make sure all the scripts are executable (i.e. given executable permissions) prior to following the steps below.

2. Copy the input database to the StepWat_R_Wrapper_Parallel folder.
3. Add site ids, you wish to run the wrapper on, to the siteid variable (third line from top) in the generate_stepwat_sites.sh script. Site ids 1-10 are already present, as examples.
4. Run the generate_stepwat_sites.sh script.
5. Run the run_local.sh script.

Once the sbatch tasks have been succesfully run on MT Moran, follow the steps below:

8. Run the call_sbatch_database.sh script.
9. Once the data is compiled into a sqlite database (for individual sites), edit the number of sites (variable site) and location (variable path) where you wish to collect the data, in the copydata.sh script.
10. Run the copydata.sh script.

Note: You could also use globus to copy the data, into the desired folder.
