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
      
    #If you don't want to use replicated species.in files for each site, simply comment out the below
    #Copy in the relevant species.in file for each site, as specified in the STEPWAT.Wrapper.MAIN_V3.R
    for(sp in species)
    {
      system(paste0("cp ",sp," ",directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input"))
      setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input"))
      system("rm species.in")
      system(paste0("mv ",sp," species.in"))
    }
    setwd(directory)      
    
   	#Copy in the soils.in file that is specified by the user in STEPWAT_DIST
    for(soil in soil.types){
      setwd(dist.directory)
      soil.type.name<-paste0(soil,".in")
      system(paste0("cp ",soil.type.name," ",directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input"))
      setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input"))
      system("rm soils.in")
      system(paste0("mv ",soil.type.name," soils.in"))
      
      #Go to the weather directory
      setwd(paste(assembly_output,"Site_",s,sep=""))
      
      #If climate conditions = "Current", copy the current weather data files into the randomdata folder
      if (GCM[g]=="Current") {
        setwd(paste("Site_",s,"_",GCM[g],sep=""))
        weath.read<-paste(assembly_output,"Site_",s,"/Site_",s,"_",GCM[g],sep="")
        
        #Identify the directory the weather will be pasted into    
        weather.dir<-paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input/",sep="")
        weather.dir2<-paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input/randomdata/",sep="")
        
        #Copy the weather data into the randomdata folder, commenting out creation of weather.in files as default so rSFSTEP2
        #uses only weather data generated from the markov weather generator but retain this code if one wants to create and copy 30 years of 
        #weather.in files into the weather folder
        if (TYPE=="basic" || TYPE=="drought" || TYPE=="back") {
          #Copy the weather data into the randomdata folder
          system(paste("cp -a ",weath.read,"/. ",weather.dir2,sep=""))
        } 
        
        #Paste in the site-specific markov weather generator files into the appropriate folder
        system(paste("cp ",weath.read,"/mkv_covar.in ",weather.dir,sep=""))
        system(paste("cp ",weath.read,"/mkv_prob.in ",weather.dir,sep=""))
                      
        #If disturbances are turned on, loop through and run STEPWAT2 for all disturbance combinations (grazing X fire) for current conditions
        if (dist.graz.flag == T) {
          for (dst in dist.freq) {
            for (grz in graz.freq) {
              for(intensity in graz_intensity ){
                setwd(paste0(dist.directory))
                dist.graz.name<-paste0("rgroup.freq",dst,".graz",grz,".",intensity,".in")
                system(paste0("cp ",dist.graz.name," ",directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/"))
                
                setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/"))
                system("rm rgroup.in")
                system(paste0("mv ",dist.graz.name," rgroup.in"))
                                
                #Change directory to the executable directory
                setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs",sep=""))
                #Run stepwat2
                system("./stepwat -f  files.in -s -o")
                
                #Change directory to "Output" folder
                setwd("Output")
                
                #Identify the name of the biomass output file
                name.bmass.csv<-paste("bmassavg.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                name.mort.csv<-paste("mortavg.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                
                #Rename the bmassavg.csv
                system(paste("mv bmassavg.csv ",name.bmass.csv,sep=""))
                system(paste("mv mortavg.csv ",name.mort.csv,sep=""))
                
                #Change directory to where SOILWAT2 output is stored
                setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output/sw_output",sep=""))
                
                #Daily SOILWAT2 output
                #Identify the name of the sw daily output files
                name.sw2.daily.slyrs.csv<-paste("sw2_daily_slyrs_agg.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                name.sw2.daily.csv<-paste("sw2_daily_agg.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                
                #Rename the daily SOILWAT2 output files
                system(paste("mv sw2_daily_slyrs_agg.csv ",name.sw2.daily.slyrs.csv,sep=""))
                system(paste("mv sw2_daily_agg.csv ",name.sw2.daily.csv,sep=""))
                
                #Monthly SOILWAT2 output
                #Identify the name of the sw monthly output files
                name.sw2.monthly.slyrs.csv<-paste("sw2_monthly_slyrs_agg.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                name.sw2.monthly.csv<-paste("sw2_monthly_agg.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                
                #Rename the monthly SOILWAT2 output files
                system(paste("mv sw2_monthly_slyrs_agg.csv ",name.sw2.monthly.slyrs.csv,sep=""))
                system(paste("mv sw2_monthly_agg.csv ",name.sw2.monthly.csv,sep=""))
                
                #Yearly SOILWAT2 output
                #Identify the name of the sw yearly output files
                name.sw2.yearly.slyrs.csv<-paste("sw2_yearly_slyrs_agg.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                name.sw2.yearly.csv<-paste("sw2_yearly_agg.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                
                #Rename the yearly SOILWAT2 output files
                system(paste("mv sw2_yearly_slyrs_agg.csv ",name.sw2.yearly.slyrs.csv,sep=""))
                system(paste("mv sw2_yearly_agg.csv ",name.sw2.yearly.csv,sep=""))
                
                source(output.file,local = TRUE)
                setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output",sep=""))
              }
            }
            print(paste0("DIST.GRAZ D",dst,".G",grz," DONE"))
          }
        }
        
        #If disturbances are turned off, run STEPWAT2 for no fire, no grazing for current conditions
        else if (dist.graz.flag ==F) {
          
          #Change directory to the executable directory
          setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs",sep=""))
          #Run stepwat2
          system("./stepwat -f  files.in -s -o")
          
          #Change directory to "Output" folder
          setwd("Output")
                    
          #Identify the name of the biomass output file
          name.bmass.csv<-paste("bmassavg.Site",s,GCM[g],soil,"csv",sep=".")
          name.mort.csv<-paste("mortavg.Site",s,GCM[g],soil,"csv",sep=".")
          
          #Rename the bmassavg.csv
          system(paste("mv bmassavg.csv ",name.bmass.csv,sep=""))
          system(paste("mv mortavg.csv ",name.mort.csv,sep=""))
          
          #Change directory to where SOILWAT2 output is stored
          setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output/sw_output",sep=""))
                
          #Daily SOILWAT2 output
          #Identify the name of the sw daily output files
          name.sw2.daily.slyrs.csv<-paste("sw2_daily_slyrs_agg.Site",s,GCM[g],soil,"csv",sep=".")
          name.sw2.daily.csv<-paste("sw2_daily_agg.Site",s,GCM[g],soil,"csv",sep=".")
                
          #Rename the daily SOILWAT2 output files
          system(paste("mv sw2_daily_slyrs_agg.csv ",name.sw2.daily.slyrs.csv,sep=""))
          system(paste("mv sw2_daily_agg.csv ",name.sw2.daily.csv,sep=""))
          
          #Monthly SOILWAT2 output
          #Identify the name of the sw monthly output files
          name.sw2.monthly.slyrs.csv<-paste("sw2_monthly_slyrs_agg.Site",s,GCM[g],soil,"csv",sep=".")
          name.sw2.monthly.csv<-paste("sw2_monthly_agg.Site",s,GCM[g],soil,"csv",sep=".")
                
          #Rename the monthly SOILWAT2 output files
          system(paste("mv sw2_monthly_slyrs_agg.csv ",name.sw2.monthly.slyrs.csv,sep=""))
          system(paste("mv sw2_monthly_agg.csv ",name.sw2.monthly.csv,sep=""))
                
          #Yearly SOILWAT2 output
          #Identify the name of the sw yearly output files
          name.sw2.yearly.slyrs.csv<-paste("sw2_yearly_slyrs_agg.Site",s,GCM[g],soil,"csv",sep=".")
          name.sw2.yearly.csv<-paste("sw2_yearly_agg.Site",s,GCM[g],soil,"csv",sep=".")
                
          #Rename the yearly SOILWAT2 output files
          system(paste("mv sw2_yearly_slyrs_agg.csv ",name.sw2.yearly.slyrs.csv,sep=""))
          system(paste("mv sw2_yearly_agg.csv ",name.sw2.yearly.csv,sep=""))
          
          source(output.file,local = TRUE)
          setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output",sep=""))
        }
        
        #If GCM is not current, then repeat the above steps for all GCMs, RCPs and time periods as specified in STEPWAT.Wrapper.MAIN_V3.R 
      } else if (GCM[g]!="Current"){
        
        for (y in YEARS) { # loop through all the time periods 50 or 90
          for (r in RCP) { # loop through all the RCP
            #Go to the weather directory
            setwd(paste(assembly_output,"Site_",s,sep=""))
			
			      #use with Vic weather database and all new weather databases
			      if(database_name!="dbWeatherData_Sagebrush_KP.v3.2.0.sqlite")
			      {
    			    setwd(paste("Site_",s,"_hybrid-delta-3mod.",y,".",r,".",GCM[g], sep=""))
			        weath.read<-paste(assembly_output,"Site_",s,"/Site_",s,"_hybrid-delta-3mod.",y,".",r,".",GCM[g], sep="")
 			      } else {
   				    setwd(paste("Site_",s,"_hybrid-delta.",y,".",r,".",GCM[g], sep=""))
   				    weath.read<-paste(assembly_output,"Site_",s,"/Site_",s,"_hybrid-delta.",y,".",r,".",GCM[g], sep="")
  			    }
	            
            #Identify the directory the weather will be pasted into   
            weather.dir<-paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input/",sep="")
            weather.dir2<-paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/sxw/Input/randomdata/",sep="")
            
            #Copy the weather data into the randomdata folder,commenting out creation of weather.in files as default
            if (TYPE=="basic" || TYPE=="drought" || TYPE=="back") {
            #Copy the weather data into the randomdata folder
            system(paste("cp -a ",weath.read,"/. ",weather.dir2,sep=""))
            } 

            system(paste("cp ",weath.read,"/mkv_covar.in ",weather.dir,sep=""))
            system(paste("cp ",weath.read,"/mkv_prob.in ",weather.dir,sep=""))
                                 
            if (dist.graz.flag == T) {
              for (dst in dist.freq) {
                for (grz in graz.freq) {
                  for(intensity in graz_intensity ){
                    setwd(paste0(dist.directory))
                    dist.graz.name<-paste0("rgroup.freq",dst,".graz",grz,".",intensity,".in")
                    system(paste0("cp ",dist.graz.name," ",directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/"))
                    
                    setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Input/"))
                    system("rm rgroup.in")
                    system(paste0("mv ",dist.graz.name," rgroup.in"))
                    
                    #Change directory to the executable directory
                    setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs",sep=""))
                    #Run stepwat2
                    system("./stepwat -f  files.in -s -o")
                    
                    #Change directory to "Output" folder
                    setwd("Output")
                    
                    #Identify the name of the biomass output file
                    name.bmass.csv<-paste("bmassavg.Site",s,GCM[g],y,r,"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                    name.mort.csv<-paste("mortavg.Site",s,GCM[g],y,r,"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                    
                    #Rename the bmassavg.csv
                    system(paste("mv bmassavg.csv ",name.bmass.csv,sep=""))
                    system(paste("mv mortavg.csv ",name.mort.csv,sep=""))
                    
                    #Change directory to where SOILWAT2 output is stored
                	  setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output/sw_output",sep=""))
                
                	  #Daily SOILWAT2 output
                	  #Identify the name of the sw daily output files
                	  name.sw2.daily.slyrs.csv<-paste("sw2_daily_slyrs_agg.Site",s,GCM[g],y,r,"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                	  name.sw2.daily.csv<-paste("sw2_daily_agg.Site",s,GCM[g],y,r,"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                
                	  #Rename the daily SOILWAT2 output files
                	  system(paste("mv sw2_daily_slyrs_agg.csv ",name.sw2.daily.slyrs.csv,sep=""))
                	  system(paste("mv sw2_daily_agg.csv ",name.sw2.daily.csv,sep=""))
                	
                	  #Monthly SOILWAT2 output
                	  #Identify the name of the sw monthly output files
                	  name.sw2.monthly.slyrs.csv<-paste("sw2_monthly_slyrs_agg.Site",s,GCM[g],y,r,"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                	  name.sw2.monthly.csv<-paste("sw2_monthly_agg.Site",s,GCM[g],y,r,"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                	
                	  #Rename the monthly SOILWAT2 output files
                	  system(paste("mv sw2_monthly_slyrs_agg.csv ",name.sw2.monthly.slyrs.csv,sep=""))
                	  system(paste("mv sw2_monthly_agg.csv ",name.sw2.monthly.csv,sep=""))
                
                	  #Yearly SOILWAT2 output
                	  #Identify the name of the sw yearly output files
                	  name.sw2.yearly.slyrs.csv<-paste("sw2_yearly_slyrs_agg.Site",s,GCM[g],y,r,"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                	  name.sw2.yearly.csv<-paste("sw2_yearly_agg.Site",s,GCM[g],y,r,"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                	
                	  #Rename the yearly SOILWAT2 output files
                	  system(paste("mv sw2_yearly_slyrs_agg.csv ",name.sw2.yearly.slyrs.csv,sep=""))
                	  system(paste("mv sw2_yearly_agg.csv ",name.sw2.yearly.csv,sep=""))
                    
                    source(output.file,local = TRUE)
                    setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output",sep=""))
                  }
                }
                print(paste0("DIST.GRAZ D",dst,".G",grz," DONE"))
              }
            } else if (dist.graz.flag ==F) {
              
              #Change directory to the executable directory
              setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs",sep=""))
              #Run stepwat2
              system("./stepwat -f  files.in -s -o")
              
              #Change directory to "Output" folder
              setwd("Output")
                            
              #Identify the name of the biomass output file
              name.bmass.csv<-paste("bmassavg.Site",s,GCM[g],y,r,soil,"csv",sep=".")
              name.mort.csv<-paste("mortavg.Site",s,GCM[g],y,r,soil,"csv",sep=".")
              
              #Rename the bmassavg.csv
              system(paste("mv bmassavg.csv ",name.bmass.csv,sep=""))
              system(paste("mv mortavg.csv ",name.mort.csv,sep=""))
              
              #Change directory to where SOILWAT2 output is stored
          	  setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output/sw_output",sep=""))
                
          	  #Daily SOILWAT2 output
         	    #Identify the name of the sw daily output files
         	    name.sw2.daily.slyrs.csv<-paste("sw2_daily_slyrs_agg.Site",s,GCM[g],y,r,soil,"csv",sep=".")
          	  name.sw2.daily.csv<-paste("sw2_daily_agg.Site",s,GCM[g],y,r,soil,"csv",sep=".")
                
          	  #Rename the daily SOILWAT2 output files
          	  system(paste("mv sw2_daily_slyrs_agg.csv ",name.sw2.daily.slyrs.csv,sep=""))
          	  system(paste("mv sw2_daily_agg.csv ",name.sw2.daily.csv,sep=""))
          	
          	  #Monthly SOILWAT2 output
          	  #Identify the name of the sw monthly output files
          	  name.sw2.monthly.slyrs.csv<-paste("sw2_monthly_slyrs_agg.Site",s,GCM[g],y,r,soil,"csv",sep=".")
          	  name.sw2.monthly.csv<-paste("sw2_monthly_agg.Site",s,GCM[g],y,r,soil,"csv",sep=".")
                
          	  #Rename the monthly SOILWAT2 output files
          	  system(paste("mv sw2_monthly_slyrs_agg.csv ",name.sw2.monthly.slyrs.csv,sep=""))
          	  system(paste("mv sw2_monthly_agg.csv ",name.sw2.monthly.csv,sep=""))
          	          	               
          	  #Yearly SOILWAT2 output
          	  #Identify the name of the sw yearly output files
          	  name.sw2.yearly.slyrs.csv<-paste("sw2_yearly_slyrs_agg.Site",s,GCM[g],y,r,soil,"csv",sep=".")
          	  name.sw2.yearly.csv<-paste("sw2_yearly_agg.Site",s,GCM[g],y,r,soil,"csv",sep=".")
                
          	  #Rename the yearly SOILWAT2 output files
          	  system(paste("mv sw2_yearly_slyrs_agg.csv ",name.sw2.yearly.slyrs.csv,sep=""))
          	  system(paste("mv sw2_yearly_agg.csv ",name.sw2.yearly.csv,sep=""))
              
              source(output.file,local = TRUE)
              setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output",sep=""))
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
  
  stopImplicitCluster()
  
  #Print statement for when model done with Site
  print(paste("Site ",s," Done",sep=""))