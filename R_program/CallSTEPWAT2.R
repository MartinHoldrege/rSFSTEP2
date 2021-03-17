#The Burke-Lauenroth Laboratory 
#STEPWAT R Wrapper
#Wrapper script to to loop through and run STEPWAT2 for all of the sites and GCM/PERIOD/RCP combinations

#Load libraries
library(doParallel)
registerDoParallel(proc_count)
library(plyr)
library(RSQLite)
library(synchronicity)

databaseMutex <- boost.mutex()
dailySWMutex <- boost.mutex()

setwd(directory)

output_database <- paste(source.dir, "Output_site_", notassigned, ".sqlite", sep="")

# Before running parallel instances we need to make sure that the database exists.
# This will attempt to connect to the database, and if no database exists it will
# create one
db <- dbConnect(SQLite(), output_database)
# We can disconnect immediately. We need a separate connection for each instance.
dbDisconnect(db)
rm(db)

s<-site[1]
w<-sites[1]

foreach (g = 1:length(GCM)) %dopar% { # loop through all the GCMs
  
  db <- dbConnect(SQLite(), output_database)
  setwd(dist.directory)

  #Copy in the relevant species.in file for each site, as specified in the Main.R
  for(sp in species)
  {
    setwd(dist.directory)
    sp.filename <- paste(sp,".in",sep = "")
    system(paste0("cp ",sp.filename," ",directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input"))
    setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input"))
    system("rm species.in")
    system(paste0("mv ",sp.filename," species.in"))
    
    setwd(directory)      
    
    #Copy in the soils.in file that is specified by the user in TreatmentFiles
    for(soil in soil.types){
      setwd(dist.directory)
      soil.type.name<-paste0(soil,".in")
      system(paste0("cp ",soil.type.name," ",directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input"))
      setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input"))
      system("rm soils.in")
      system(paste0("mv ",soil.type.name," soils.in"))
      
      #Go to the weather directory
      setwd(assembly_output)
      
      # The sxw folder for scaling phenology
      STEPWAT.sxw.directory<-paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw")
      
      #If climate conditions = "Current", copy the current weather data files into the randomdata folder
      if (GCM[g]=="Current") {
        setwd(paste("Site_",w,"_",GCM[g],sep=""))
        weath.read<-paste(assembly_output,"Site_",w,"_",GCM[g],sep="")
        
        #Identify the directory the weather will be pasted into    
        weather.dir<-paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input/",sep="")
        weather.dir2<-paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input/randomdata/",sep="")
        
        if(rescale_phenology){
          ################ Copy phen and prod files generated for current conditions #################
          setwd(dist.directory)
          # Copy the phenology file generated for this specific GCM, RCP and YEAR.
          system(paste0("cp ", "sxwphen.", GCM[g], ".in", " ", STEPWAT.sxw.directory))
          # Copy the prod file generated for this specific GCM, RCP and YEAR.
          system(paste0("cp ", "sxwprod_v2.", GCM[g], ".in", " ", STEPWAT.sxw.directory))
          # Move to the SXW inputs for STEPWAT2
          setwd(STEPWAT.sxw.directory)
          # Remove the old phenology file
          system("rm sxwphen.in")
          # Remove the old prod file
          system("rm sxwprod_v2.in")
          # Rename the phenology file to the name recognized by STEPWAT2
          system(paste0("mv ", "sxwphen.", GCM[g], ".in", " sxwphen.in"))
          # Rename the prod file to the name recognized by STEPWAT2
          system(paste0("mv ", "sxwprod_v2.", GCM[g], ".in", " sxwprod_v2.in"))
        }
        
        #Copy the weather data into the randomdata folder, commenting out creation of weather.in files as default so rSFSTEP2
        #uses only weather data generated from the markov weather generator but retain this code if one wants to create and copy 30 years of 
        #weather.in files into the weather folder
        if (TYPE=="basic") {
          #Copy the weather data into the randomdata folder
          system(paste("cp -a ",weath.read,"/. ",weather.dir2,sep=""))
        } 
        
        #Paste in the site-specific markov weather generator files into the appropriate folder
        system(paste("cp ",weath.read,"/mkv_covar.in ",weather.dir,sep=""))
        system(paste("cp ",weath.read,"/mkv_prob.in ",weather.dir,sep=""))
        
        # Loop through all rgroup files. Note that rgroups contains the file name without ".in"
        for (rg_index in 1:length(rgroups)) {
          rg <- rgroups[rg_index]
          setwd(paste0(dist.directory))
          
          # names(rg) specifies if this rgroup.in file should be used for this climate scenario. 
          # "Inputs" specifies inputs directly from the csv files.
          # "Current" specifies files that have readjusted space parameters for current conditions.
          if(names(rg) != "Inputs" & names(rg) != "Current"){
            next
          }
          
          # rg + ".in" = the file name
          dist.graz.name<-paste0(rg,".in")
          
          # Parse rg to get the disturbance frequency (dst), the grazing frequency (grz), and the grazing intensity (intensity).
          temp <- strsplit(rg,"\\.")
          dst <- temp[[1]][3]
          grz <- temp[[1]][5]
          intensity <- temp[[1]][6]
          treatmentName <- temp[[1]][7]
          
          system(paste0("cp ",dist.graz.name," ",directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/"))
          
          setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/"))
          system("rm rgroup.in")
          system(paste0("mv ",dist.graz.name," rgroup.in"))
          
          #Change directory to the executable directory
          setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs",sep=""))
          #Run stepwat2
          system("./stepwat -f  files.in -o")
          
          #Change directory to "Output" folder
          setwd("Output")

          # Add biomass output to the SQLite database
          bmassavg.csv <- read.csv("bmassavg.csv", header = TRUE)
          wrapped.biomass <- data.frame(as.integer(notassigned), GCM[g], NA, NA, treatmentName, dst, grz, intensity, soil, sp, bmassavg.csv)
          colnames(wrapped.biomass) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                         "SoilTreatment", "SpeciesTreatment", colnames(bmassavg.csv))
          lock(databaseMutex)
          dbWriteTable(db, "Biomass", wrapped.biomass, append=T)
          unlock(databaseMutex)
          system("rm bmassavg.csv")
          
          # Add mortality output to the SQLite database
          mortavg.csv <- read.csv("mortavg.csv", header = TRUE)
          wrapped.mortality <- data.frame(as.integer(notassigned), GCM[g], NA, NA, treatmentName, dst, grz, intensity, soil, sp, mortavg.csv)
          colnames(wrapped.mortality) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                           "SoilTreatment", "SpeciesTreatment", colnames(mortavg.csv))
          lock(databaseMutex)
          dbWriteTable(db, "Mortality", wrapped.mortality, append=T)
          unlock(databaseMutex)
          system("rm mortavg.csv")
          
          #Change directory to where SOILWAT2 output is stored
          setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output/sw_output",sep=""))
          
          #Daily SOILWAT2 output
          lock(dailySWMutex)
          sw2_daily_slyrs_agg.csv <- read.csv("sw2_daily_slyrs_agg.csv", header = TRUE)
          
          #Calculate aggregated daily output for soil layer variables - average values for each day across all years
          sw2_daily_slyrs_aggregated=aggregate(sw2_daily_slyrs_agg.csv[,c(3:length(sw2_daily_slyrs_agg.csv[1,]))],by=list(sw2_daily_slyrs_agg.csv$Day),mean)
 		  names(sw2_daily_slyrs_aggregated)[1]=c("Day")
    
          wrapped.daily.slyrs <- data.frame(as.integer(notassigned), GCM[g], NA, NA, treatmentName, dst, grz, intensity, soil, sp, sw2_daily_slyrs_aggregated)
          colnames(wrapped.daily.slyrs) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                             "SoilTreatment", "SpeciesTreatment", colnames(sw2_daily_slyrs_aggregated))
          lock(databaseMutex)
          dbWriteTable(db, "sw2_daily_slyrs", wrapped.daily.slyrs, append=T)
          unlock(databaseMutex)
          sw2_daily_agg.csv <- read.csv("sw2_daily_agg.csv", header = TRUE)
          
          #Calculate aggregated daily output - average values for each day across all years
          sw2_daily_aggregated=aggregate(sw2_daily_agg.csv[,c(3:length(sw2_daily_agg.csv[1,]))],by=list(sw2_daily_agg.csv$Day),mean)
 		  names(sw2_daily_aggregated)[1]=c("Day")
 		  
          wrapped.daily <- data.frame(as.integer(notassigned), GCM[g], NA, NA, treatmentName, dst, grz, intensity, soil, sp, sw2_daily_aggregated)
          colnames(wrapped.daily) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                             "SoilTreatment", "SpeciesTreatment", colnames(sw2_daily_aggregated))
          lock(databaseMutex)
          dbWriteTable(db, "sw2_daily", wrapped.daily, append=T)
          unlock(databaseMutex)
          remove(sw2_daily_agg.csv)
          remove(sw2_daily_slyrs_agg.csv)
          remove(sw2_daily_aggregated)
          remove(sw2_daily_slyrs_aggregated)
          remove(wrapped.daily)
          remove(wrapped.daily.slyrs)
          unlock(dailySWMutex)
          system("rm sw2_daily_slyrs_agg.csv")
          system("rm sw2_daily_agg.csv")
          
          #Monthly SOILWAT2 output
          sw2_monthly_slyrs_agg.csv <- read.csv("sw2_monthly_slyrs_agg.csv", header = TRUE)
          wrapped.monthly.slyrs <- data.frame(as.integer(notassigned), GCM[g], NA, NA, treatmentName, dst, grz, intensity, soil, sp, sw2_monthly_slyrs_agg.csv)
          colnames(wrapped.monthly.slyrs) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                               "SoilTreatment", "SpeciesTreatment", colnames(sw2_monthly_slyrs_agg.csv))
                                               
          months=12
          wrapped.monthly.slyrs$Year <- rep(1:simyears,each=months)                                     
          lock(databaseMutex)
          dbWriteTable(db, "sw2_monthly_slyrs", wrapped.monthly.slyrs, append=T)
          unlock(databaseMutex)
          system("rm sw2_monthly_slyrs_agg.csv")
          
          sw2_monthly_agg.csv <- read.csv("sw2_monthly_agg.csv", header = TRUE)
          wrapped.monthly <- data.frame(as.integer(notassigned), GCM[g], NA, NA, treatmentName, dst, grz, intensity, soil, sp, sw2_monthly_agg.csv)
          colnames(wrapped.monthly) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                         "SoilTreatment", "SpeciesTreatment", colnames(sw2_monthly_agg.csv))
          
          wrapped.monthly$Year <- rep(1:simyears,each=months)                               
          lock(databaseMutex)
          dbWriteTable(db, "sw2_monthly", wrapped.monthly, append=T)
          unlock(databaseMutex)
          system("rm sw2_monthly_agg.csv")
          
          #Yearly SOILWAT2 output
          sw2_yearly_slyrs_agg.csv <- read.csv("sw2_yearly_slyrs_agg.csv", header = TRUE)
          wrapped.yearly.slyrs <- data.frame(as.integer(notassigned), GCM[g], NA, NA, treatmentName, dst, grz, intensity, soil, sp, sw2_yearly_slyrs_agg.csv)
          colnames(wrapped.yearly.slyrs) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                              "SoilTreatment", "SpeciesTreatment", colnames(sw2_yearly_slyrs_agg.csv))
                                              
          wrapped.yearly.slyrs$Year <- 1:length(wrapped.yearly.slyrs$Year)                                    
          lock(databaseMutex)
          dbWriteTable(db, "sw2_yearly_slyrs", wrapped.yearly.slyrs, append=T)
          unlock(databaseMutex)
          system("rm sw2_yearly_slyrs_agg.csv")
          
          sw2_yearly_agg.csv <- read.csv("sw2_yearly_agg.csv", header = TRUE)
          wrapped.yearly <- data.frame(as.integer(notassigned), GCM[g], NA, NA, treatmentName, dst, grz, intensity, soil, sp, sw2_yearly_agg.csv)
          colnames(wrapped.yearly) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                    		   "SoilTreatment", "SpeciesTreatment", colnames(sw2_yearly_agg.csv))
                                             
          wrapped.yearly$Year <- 1:length(wrapped.yearly$Year)                                   
          lock(databaseMutex)
          dbWriteTable(db, "sw2_yearly", wrapped.yearly, append=T)
          unlock(databaseMutex)
          system("rm sw2_yearly_agg.csv")
          
          setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output",sep=""))
        }
        #If GCM is not current, then repeat the above steps for all GCMs, RCPs and time periods as specified in Main.R 
      } else if (GCM[g]!="Current"){
        
        for (y in YEARS) { # loop through all the time periods 50 or 90
          for (r in RCP) { # loop through all the RCP
            #Go to the weather directory
            setwd(assembly_output)
            
            #use with Vic weather database and all new weather databases
            if(database_name!="dbWeatherData_Sagebrush_KP.v3.2.0.sqlite")
            {
              weather.read.dir <- paste("Site_",w,"_hybrid-delta-3mod.",y,".",r,".",GCM[g], sep="")
              weath.read <- paste(assembly_output,"Site_",w,"_hybrid-delta-3mod.",y,".",r,".",GCM[g], sep="")
            } else {
              weather.read.dir <- paste("Site_",w,"_hybrid-delta.",y,".",r,".",GCM[g], sep="")
              weath.read <- paste(assembly_output,"Site_",w,"_hybrid-delta.",y,".",r,".",GCM[g], sep="")
            }
            
            # If the user didn't specify this particular GCM/RCP combination
            if(!dir.exists(weather.read.dir)) {
              next
            } else {
              setwd(weather.read.dir)
            }
            
            if(rescale_phenology){
              ########## Move phen and prod files generated for this specific GCM x RCP x YEARS combination #########
              setwd(dist.directory)
              # Copy the phenology file generated for this climate into STEPWAT2
              system(paste0("cp ", "sxwphen.", downscaling.method, ".", y, ".", r, ".", GCM[g], ".in", " ", STEPWAT.sxw.directory))
              # Copy the prod file generated for this climate into STEPWAT2
              system(paste0("cp ", "sxwprod_v2.", downscaling.method, ".", y, ".", r, ".", GCM[g], ".in", " ", STEPWAT.sxw.directory))
              # Move into the sxw inputs folder for STEPWAT2
              setwd(STEPWAT.sxw.directory)
              # Remove the old phenology file
              system("rm sxwphen.in")
              # Remove the old prod file
              system("rm sxwprod_v2.in")
              # Rename the new phenology file to the name recognized by STEPWAT2
              system(paste0("mv ", "sxwphen.", downscaling.method, ".", y, ".", r, ".", GCM[g], ".in", " sxwphen.in"))
              # Rename the new prod file to the name recognized by STEPWAT2
              system(paste0("mv ", "sxwprod_v2.", downscaling.method, ".", y, ".", r, ".", GCM[g], ".in", " sxwprod_v2.in"))
            }
            
            #Identify the directory the weather will be pasted into   
            weather.dir<-paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input/",sep="")
            weather.dir2<-paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input/randomdata/",sep="")
            
            #Copy the weather data into the randomdata folder,commenting out creation of weather.in files as default
            if (TYPE=="basic") {
              #Copy the weather data into the randomdata folder
              system(paste("cp -a ",weath.read,"/. ",weather.dir2,sep=""))
            } 
            
            system(paste("cp ",weath.read,"/mkv_covar.in ",weather.dir,sep=""))
            system(paste("cp ",weath.read,"/mkv_prob.in ",weather.dir,sep=""))
            
            # Loop through all rgroup files. Note that rgroups contains the file name without ".in"
            for (rg_index in 1:length(rgroups)) {
              rg <- rgroups[rg_index]
              setwd(paste0(dist.directory))
              
              # names(rg) specifies if this rgroup.in file should be used for this climate scenario. 
              # "Inputs" specifies inputs directly from the csv files.
              # Otherwise, names(rg) must match the current year-rcp-scenario in order to proceed.
              if(names(rg) != "Inputs" & names(rg) != paste("hybrid-delta-3mod", y, r, GCM[g], sep = ".") & names(rg) != paste("hybrid-delta", y, r, GCM[g], sep = ".")){
                next
              }
              
              # rg + ".in" = the file name
              dist.graz.name<-paste0(rg,".in")
              
              # Parse rg to get the disturbance frequency (dst), the grazing frequency (grz), and the grazing intensity (intensity).
              temp <- strsplit(rg,"\\.")
              dst <- temp[[1]][3]
              grz <- temp[[1]][5]
              intensity <- temp[[1]][6]
              treatmentName<- temp[[1]][7]

              system(paste0("cp ",dist.graz.name," ",directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/"))
              
              setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/"))
              system("rm rgroup.in")
              system(paste0("mv ",dist.graz.name," rgroup.in"))
              
              #Change directory to the executable directory
              setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs",sep=""))
              #Run stepwat2
              system("./stepwat -f  files.in -o")
              
              #Change directory to "Output" folder
              setwd("Output")
              
              # Add biomass output to the SQLite database
              bmassavg.csv <- read.csv("bmassavg.csv", header = TRUE)
              wrapped.biomass <- data.frame(as.integer(notassigned), GCM[g], y, r, treatmentName, dst, grz, intensity, soil, sp, bmassavg.csv)
              colnames(wrapped.biomass) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                             "SoilTreatment", "SpeciesTreatment", colnames(bmassavg.csv))
              lock(databaseMutex)
              dbWriteTable(db, "Biomass", wrapped.biomass, append=T)
              unlock(databaseMutex)
              system("rm bmassavg.csv")
              
              # Add mortality output to the SQLite database
              mortavg.csv <- read.csv("mortavg.csv", header = TRUE)
              wrapped.mortality <- data.frame(as.integer(notassigned), GCM[g], y, r, treatmentName, dst, grz, intensity, soil, sp, mortavg.csv)
              colnames(wrapped.mortality) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                               "SoilTreatment", "SpeciesTreatment", colnames(mortavg.csv))
              lock(databaseMutex)
              dbWriteTable(db, "Mortality", wrapped.mortality, append=T)
              unlock(databaseMutex)
              system("rm mortavg.csv")
              
              #Change directory to where SOILWAT2 output is stored
              setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output/sw_output",sep=""))
              
              #Daily SOILWAT2 output
              lock(dailySWMutex)
              sw2_daily_slyrs_agg.csv <- read.csv("sw2_daily_slyrs_agg.csv", header = TRUE)
              
              #Calculate aggregated daily output for soil layer variables - average values for each day across all years
              sw2_daily_slyrs_aggregated=aggregate(sw2_daily_slyrs_agg.csv[,c(3:length(sw2_daily_slyrs_agg.csv[1,]))],by=list(sw2_daily_slyrs_agg.csv$Day),mean)
 		      names(sw2_daily_slyrs_aggregated)[1]=c("Day")
 		      
              wrapped.daily.slyrs <- data.frame(as.integer(notassigned), GCM[g], y, r, treatmentName, dst, grz, intensity, soil, sp, sw2_daily_slyrs_aggregated)
              colnames(wrapped.daily.slyrs) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                                 "SoilTreatment", "SpeciesTreatment", colnames(sw2_daily_slyrs_aggregated))
              lock(databaseMutex)
              dbWriteTable(db, "sw2_daily_slyrs", wrapped.daily.slyrs, append=T)
              unlock(databaseMutex)
              sw2_daily_agg.csv <- read.csv("sw2_daily_agg.csv", header = TRUE)
              
			  #Calculate aggregated daily output - average values for each day across all years
              sw2_daily_aggregated=aggregate(sw2_daily_agg.csv[,c(3:length(sw2_daily_agg.csv[1,]))],by=list(sw2_daily_agg.csv$Day),mean)
 		  	  names(sw2_daily_aggregated)[1]=c("Day")
    
              wrapped.daily <- data.frame(as.integer(notassigned), GCM[g], y, r, treatmentName, dst, grz, intensity, soil, sp, sw2_daily_aggregated)
              colnames(wrapped.daily) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                           "SoilTreatment", "SpeciesTreatment", colnames(sw2_daily_aggregated))
              lock(databaseMutex)
              dbWriteTable(db, "sw2_daily", wrapped.daily, append=T)
              unlock(databaseMutex)
              remove(sw2_daily_agg.csv)
              remove(sw2_daily_slyrs_agg.csv)
              remove(sw2_daily_aggregated)
              remove(sw2_daily_slyrs_aggregated)
              remove(wrapped.daily)
              remove(wrapped.daily.slyrs)
              unlock(dailySWMutex)
              system("rm sw2_daily_slyrs_agg.csv")
              system("rm sw2_daily_agg.csv")
              
              #Monthly SOILWAT2 output
              sw2_monthly_slyrs_agg.csv <- read.csv("sw2_monthly_slyrs_agg.csv", header = TRUE)
              wrapped.monthly.slyrs <- data.frame(as.integer(notassigned), GCM[g], y, r, treatmentName, dst, grz, intensity, soil, sp, sw2_monthly_slyrs_agg.csv)
              colnames(wrapped.monthly.slyrs) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                                   "SoilTreatment", "SpeciesTreatment", colnames(sw2_monthly_slyrs_agg.csv))
              months=12
              wrapped.monthly.slyrs$Year <- rep(1:simyears,each=months)                                     
              lock(databaseMutex)
              dbWriteTable(db, "sw2_monthly_slyrs", wrapped.monthly.slyrs, append=T)
              unlock(databaseMutex)
              system("rm sw2_monthly_slyrs_agg.csv")
              
              sw2_monthly_agg.csv <- read.csv("sw2_monthly_agg.csv", header = TRUE)
              wrapped.monthly <- data.frame(as.integer(notassigned), GCM[g], y, r, treatmentName, dst, grz, intensity, soil, sp, sw2_monthly_agg.csv)
              colnames(wrapped.monthly) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                             "SoilTreatment", "SpeciesTreatment", colnames(sw2_monthly_agg.csv))
                                             
              wrapped.monthly$Year <- rep(1:simyears,each=months)                                
              lock(databaseMutex)
              dbWriteTable(db, "sw2_monthly", wrapped.monthly, append=T)
              unlock(databaseMutex)
              system("rm sw2_monthly_agg.csv")
              
              #Yearly SOILWAT2 output
              sw2_yearly_slyrs_agg.csv <- read.csv("sw2_yearly_slyrs_agg.csv", header = TRUE)
              wrapped.yearly.slyrs <- data.frame(as.integer(notassigned), GCM[g], y, r, treatmentName, dst, grz, intensity, soil, sp, sw2_yearly_slyrs_agg.csv)
              colnames(wrapped.yearly.slyrs) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                                  "SoilTreatment", "SpeciesTreatment", colnames(sw2_yearly_slyrs_agg.csv))
                                                  
              wrapped.yearly.slyrs$Year <- 1:length(wrapped.yearly.slyrs$Year)                                    
              lock(databaseMutex)
              dbWriteTable(db, "sw2_yearly_slyrs", wrapped.yearly.slyrs, append=T)
              unlock(databaseMutex)
              system("rm sw2_yearly_slyrs_agg.csv")
              
              sw2_yearly_agg.csv <- read.csv("sw2_yearly_agg.csv", header = TRUE)
              wrapped.yearly <- data.frame(as.integer(notassigned), GCM[g], y, r, treatmentName, dst, grz, intensity, soil, sp, sw2_yearly_agg.csv)
              colnames(wrapped.yearly) <- c("site", "GCM", "years", "RCP", "RGroupTreatment", "dst", "grazing", "intensity", 
                                            "SoilTreatment", "SpeciesTreatment", colnames(sw2_yearly_agg.csv))
                                            
              wrapped.yearly$Year <- 1:length(wrapped.yearly$Year)                             
              lock(databaseMutex)
              dbWriteTable(db, "sw2_yearly", wrapped.yearly, append=T)
              unlock(databaseMutex)
              system("rm sw2_yearly_agg.csv")
              
              setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output",sep=""))
            }
            print(paste("RCP ",r," DONE",sep=""))
          }
          #Print statement for when model done with that GCM
          print(paste("YEAR ",y," DONE",sep=""))
        }
        
      }
      print(paste("Soil treatment ", soil, " DONE"))
    }
    print(paste("Species treatment ", sp, " DONE"))
  }
  
  print(paste("GCM ",GCM[g]," DONE",sep=""))
  dbDisconnect(db)
}

stopImplicitCluster()

#Print statement for when model done with Site
print(paste("Site ",s," Done",sep=""))
