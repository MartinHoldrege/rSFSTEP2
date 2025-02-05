#Markov script that generates two site-specific files (mkv_covar.in and mkv_prob.in) required by the markov weather generator in SOILWAT2

#Three options for imputation of missing values due to insufficient weather data within function dbW_estimate_WGen_coefs via argument imputation_type: no imputation ("none"), imputation via mean using 5 values before and 5 values after the missing value ("mean"), and imputation by last-observation-carried-forward ("locf"). If the user wants to adjust the number of values used to calculate the mean, argument "imputation_span" must also be provided with an integer (ex: imputation_span = 3). See function dbW_estimate_WGen_coefs in rSOILWAT2 for additional details.

#Set up system for parallel processing
library(doParallel)
registerDoParallel(proc_count)

  s<-1

  foreach (h = 1:H) %dopar%
    { #h = number of GCM X RCP X Times (scenarios)
    scen<-temp[h] #load a particular scenario
    
    #Generate the necessary precipitation and temperature parameters for mkv_covar.in and mkv_prob.in based on historical weather data
    res <- rSOILWAT2::dbW_estimate_WGen_coefs(sw_weatherList[[s]][[h]], imputation_type = "mean", 
    propagate_NAs = FALSE)
    
    #Write the mkv_covar.in and mkv_prob.in files
    print_mkv_files(mkv_doy = res[["mkv_doy"]], mkv_woy = res[["mkv_woy"]],
      path = file.path(assembly_output, paste0("Site", "_", site, "_", scen)))
 }

#reset directory to project level
setwd(assembly_output)

stopImplicitCluster()
