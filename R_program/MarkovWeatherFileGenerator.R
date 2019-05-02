#Markov script that generates two site-specific files (mkv_covar.in and mkv_prob.in) required by the markov weather generator in SOILWAT2

#Set up system for parallel processing
library(doParallel)
registerDoParallel(proc_count)

  #Loop through all sites
  #load a particular site
  site<-site[1] 
  s<-1

  foreach (h = 1:H) %dopar%
    { #h = number of GCM X RCP X Times (scenarios)
    scen<-temp[h] #load a particular scenario

    res <- rSOILWAT2::dbW_estimate_WeatherGenerator_coefficients(sw_weatherList[[s]][[h]])

    print_mkv_files(DF = res[["DF"]], DF_covar = res[["DF_covar"]],
      path = file.path(assembly_output, paste0("Site", "_", site, "_", scen)))
 }

#reset directory to project level
setwd(assembly_output)

stopImplicitCluster()
