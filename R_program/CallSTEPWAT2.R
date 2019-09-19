#The Burke-Lauenroth Laboratory 
#STEPWAT R Wrapper
#Wrapper script to to loop through and run STEPWAT2 for all of the sites and GCM/PERIOD/RCP combinations

#Load libraries
library(doParallel)
registerDoParallel(proc_count)
library(plyr)
library(RSQLite)

setwd(directory)

s<-site[1]
  foreach (g = 1:length(GCM)) %dopar% { # loop through all the GCMs
      
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
      
      #If climate conditions = "Current", copy the current weather data files into the randomdata folder
      if (GCM[g]=="Current") {
        setwd(paste("Site_",s,"_",GCM[g],sep=""))
        weath.read<-paste(assembly_output,"Site_",s,"_",GCM[g],sep="")
        
        #Identify the directory the weather will be pasted into    
        weather.dir<-paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input/",sep="")
        weather.dir2<-paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input/randomdata/",sep="")
        
        setwd(dist.directory)
        system(paste0("cp ", "sxwphen.", GCM[g], ".in", " ", directory,
                      "Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw"))
        setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw"))
        system("rm sxwphen.in")
        system(paste0("mv ", "sxwphen.", GCM[g], ".in", " sxwphen.in"))
        
        setwd(dist.directory)
        system(paste0("cp ", "sxwprod_v2.", GCM[g], ".in", " ", directory,
                      "Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw"))
        setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw"))
        system("rm sxwprod_v2.in")
        system(paste0("mv ", "sxwprod_v2.", GCM[g], ".in", " sxwprod_v2.in"))
        
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
          
          #Identify the name of the biomass output file
          name.bmass.csv<-paste("bmassavg.Site",s,GCM[g],"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
          name.mort.csv<-paste("mortavg.Site",s,GCM[g],"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
          
          #Rename the bmassavg.csv
          system(paste("mv bmassavg.csv ",name.bmass.csv,sep=""))
          system(paste("mv mortavg.csv ",name.mort.csv,sep=""))
          
          #Change directory to where SOILWAT2 output is stored
          setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output/sw_output",sep=""))
          
          #Daily SOILWAT2 output
          #Identify the name of the sw daily output files
          name.sw2.daily.slyrs.csv<-paste("sw2_daily_slyrs_agg.Site",s,GCM[g],"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
          name.sw2.daily.csv<-paste("sw2_daily_agg.Site",s,GCM[g],"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
          
          #Rename the daily SOILWAT2 output files
          system(paste("mv sw2_daily_slyrs_agg.csv ",name.sw2.daily.slyrs.csv,sep=""))
          system(paste("mv sw2_daily_agg.csv ",name.sw2.daily.csv,sep=""))
          
          #Monthly SOILWAT2 output
          #Identify the name of the sw monthly output files
          name.sw2.monthly.slyrs.csv<-paste("sw2_monthly_slyrs_agg.Site",s,GCM[g],"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
          name.sw2.monthly.csv<-paste("sw2_monthly_agg.Site",s,GCM[g],"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
          
          #Rename the monthly SOILWAT2 output files
          system(paste("mv sw2_monthly_slyrs_agg.csv ",name.sw2.monthly.slyrs.csv,sep=""))
          system(paste("mv sw2_monthly_agg.csv ",name.sw2.monthly.csv,sep=""))
          
          #Yearly SOILWAT2 output
          #Identify the name of the sw yearly output files
          name.sw2.yearly.slyrs.csv<-paste("sw2_yearly_slyrs_agg.Site",s,GCM[g],"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
          name.sw2.yearly.csv<-paste("sw2_yearly_agg.Site",s,GCM[g],"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
          
          #Rename the yearly SOILWAT2 output files
          system(paste("mv sw2_yearly_slyrs_agg.csv ",name.sw2.yearly.slyrs.csv,sep=""))
          system(paste("mv sw2_yearly_agg.csv ",name.sw2.yearly.csv,sep=""))
          
          source(output.file,local = TRUE)
          setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output",sep=""))
          
          #this will print out which treatment was just completed
          print(paste0("rgroup treatment ", treatmentName, " done."))
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
              downscaling_method <- paste0("hybrid-delta-3mod.",y)
              setwd(paste("Site_",s,"_hybrid-delta-3mod.",y,".",r,".",GCM[g], sep=""))
              weath.read<-paste(assembly_output,"Site_",s,"_hybrid-delta-3mod.",y,".",r,".",GCM[g], sep="")
            } else {
              downscaling_method <- paste0("hybrid-delta.",y)
              setwd(paste("Site_",s,"_hybrid-delta.",y,".",r,".",GCM[g], sep=""))
              weath.read<-paste(assembly_output,"Site_",s,"_hybrid-delta.",y,".",r,".",GCM[g], sep="")
            }
            
            setwd(dist.directory)
            system(paste0("cp ", "sxwphen.", downscaling_method, ".", r, ".", GCM[g], ".in", " ", directory,
                          "Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw"))
            setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw"))
            system("rm sxwphen.in")
            system(paste0("mv ", "sxwphen.", downscaling_method, ".", r, ".", GCM[g], ".in", " sxwphen.in"))
            
            setwd(dist.directory)
            system(paste0("cp ", "sxwprod_v2.", downscaling_method, ".", r, ".", GCM[g], ".in", " ", directory,
                          "Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw"))
            setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw"))
            system("rm sxwprod_v2.in")
            system(paste0("mv ", "sxwprod_v2.", downscaling_method, ".", r, ".", GCM[g], ".in", " sxwprod_v2.in"))
            
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
              
              #Identify the name of the biomass output file
              name.bmass.csv<-paste("bmassavg.Site",s,GCM[g], y, r,"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
              name.mort.csv<-paste("mortavg.Site",s,GCM[g], y, r,"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
              
              #Rename the bmassavg.csv
              system(paste("mv bmassavg.csv ",name.bmass.csv,sep=""))
              system(paste("mv mortavg.csv ",name.mort.csv,sep=""))
              
              #Change directory to where SOILWAT2 output is stored
              setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output/sw_output",sep=""))
              
              #Daily SOILWAT2 output
              #Identify the name of the sw daily output files
              name.sw2.daily.slyrs.csv<-paste("sw2_daily_slyrs_agg.Site",s,GCM[g], y, r,"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
              name.sw2.daily.csv<-paste("sw2_daily_agg.Site",s,GCM[g], y, r,"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
              
              #Rename the daily SOILWAT2 output files
              system(paste("mv sw2_daily_slyrs_agg.csv ",name.sw2.daily.slyrs.csv,sep=""))
              system(paste("mv sw2_daily_agg.csv ",name.sw2.daily.csv,sep=""))
              
              #Monthly SOILWAT2 output
              #Identify the name of the sw monthly output files
              name.sw2.monthly.slyrs.csv<-paste("sw2_monthly_slyrs_agg.Site",s,GCM[g], y, r,"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
              name.sw2.monthly.csv<-paste("sw2_monthly_agg.Site",s,GCM[g], y, r,"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
              
              #Rename the monthly SOILWAT2 output files
              system(paste("mv sw2_monthly_slyrs_agg.csv ",name.sw2.monthly.slyrs.csv,sep=""))
              system(paste("mv sw2_monthly_agg.csv ",name.sw2.monthly.csv,sep=""))
              
              #Yearly SOILWAT2 output
              #Identify the name of the sw yearly output files
              name.sw2.yearly.slyrs.csv<-paste("sw2_yearly_slyrs_agg.Site",s,GCM[g], y, r,"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
              name.sw2.yearly.csv<-paste("sw2_yearly_agg.Site",s,GCM[g], y, r,"Rgrp",treatmentName,dst,grz,intensity,soil,sp,"csv",sep=".")
              
              #Rename the yearly SOILWAT2 output files
              system(paste("mv sw2_yearly_slyrs_agg.csv ",name.sw2.yearly.slyrs.csv,sep=""))
              system(paste("mv sw2_yearly_agg.csv ",name.sw2.yearly.csv,sep=""))
              
              source(output.file,local = TRUE)
              setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output",sep=""))
              
              #this will print out which treatment was just completed
              print(paste0("rgroup treatment ", treatmentName, " done."))
            }
            print(paste("RCP ",r," DONE",sep=""))
          }
          #Print statement for when model done with that GCM
          print(paste("YEAR ",y," DONE",sep=""))
        }
        
      }
      print(paste("GCM ",GCM[g]," DONE",sep=""))
    }
  }
}

stopImplicitCluster()

#Print statement for when model done with Site
print(paste("Site ",s," Done",sep=""))