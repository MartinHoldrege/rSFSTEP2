#The Burke-Lauenroth Laboratory 
#STEPWAT R Wrapper
#Wrapper script for STEPWAT Wrapper
#Script to to loop through all of the sites and GCM/PERIOD/RCP combinations

library(doParallel)
registerDoParallel(proc_count)
library(plyr)
library(RSQLite)

setwd(directory)

s<-site[1]
#for (g in 1:length(GCM)) { # loop through all the GCMs
  foreach (g = 1:length(GCM)) %dopar% { # loop through all the GCMs
    for(soil in soil.types){
      setwd(dist.directory)
      soil.type.name<-paste0(soil,".in")
      system(paste0("cp ",soil.type.name," ",directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs/Input/sxw/Input"))
      setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs/Input/sxw/Input"))
      system("rm soils_v30.in")
      system(paste0("mv ",soil.type.name," soils_v30.in"))
      
      # Go to the weather directory
      setwd(paste(assembly_output,"Site_",s,sep=""))
      
      # if on the "Current" GCM read the weather data into randomdata
      if (GCM[g]=="Current") {
        setwd(paste("Site_",s,"_",GCM[g],sep=""))
        weath.read<-paste(assembly_output,"Site_",s,"/Site_",s,"_",GCM[g],sep="")
        
        # identify the directory the weather will be pasted into        
        weather.dir2<-paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs/Input/sxw/Input/randomdata/",sep="")
        weather.dir3<-paste(directory,"Stepwat.Site.",s,".",g,"/sw_src/testing/Input/data_39.0625_-119.4375/",sep="")
        
        # copy the weather data into the randomdata folder
        if (TYPE=="basic" || TYPE=="drought" || TYPE=="back") {
          # copy the weather data into the randomdata folder
          system(paste("cp -a ",weath.read,"/. ",weather.dir2,sep=""))
        } 
        if (TYPE2=="markov") {
          system(paste("cp ",weath.read,"/mkv_covar.in ",weather.dir2,sep=""))
          system(paste("cp ",weath.read,"/mkv_prob.in ",weather.dir2,sep=""))
        }
        
        # copy the weather data into the data_39.0625_-199.4375 folder
        if (TYPE=="basic" || TYPE=="drought" || TYPE=="back") {
          # copy the weather data into the data_39.0625_-199.4375 folder
          system(paste("cp -a ",weath.read,"/. ",weather.dir3,sep=""))
        } 
        if (TYPE2=="markov") {
          system(paste("cp ",weath.read,"/mkv_covar.in ",weather.dir3,sep=""))
          system(paste("cp ",weath.read,"/mkv_prob.in ",weather.dir3,sep=""))
        }
        
        if (dist.graz.flag == T) {
          for (dst in dist.freq) {
            for (grz in graz.freq) {
              for(intensity in graz_intensity ){
                setwd(paste0(dist.directory))
                dist.graz.name<-paste0("rgroup.freq",dst,".graz",grz,".",intensity,".in")
                system(paste0("cp ",dist.graz.name," ",directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs/Input/"))
                
                setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs/Input/"))
                system("rm rgroup.in")
                system(paste0("mv ",dist.graz.name," rgroup.in"))
                
                
                # change directory to the executable directory
                setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs",sep=""))
                # run stepwat
                system("./stepwat -f  files.in -s -o ../../sw_src/testing/files_step_soilwat.in")
                
                # change directory to "Output" folder
                setwd("Output")
                
                # identify the name of the biomass output file
                name.bmass.csv<-paste("bmassavg.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                name.mort.csv<-paste("mortavg.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                name.stdebug.sqlite<-paste("stdebug.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"sqlite3",sep=".")
                
                # rename the bmassavg.csv
                system(paste("mv bmassavg.csv ",name.bmass.csv,sep=""))
                system(paste("mv mortavg.csv ",name.mort.csv,sep=""))
                system(paste("mv stdebug.sqlite3 ",name.stdebug.sqlite,sep=""))
                
                setwd(paste(directory,"Stepwat.Site.",s,".",g,"/sw_src/testing/Output",sep=""))
                source(output.file,local = TRUE)
                setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs/Output",sep=""))
              }}
            
            
            print(paste0("DIST.GRAZ D",dst,".G",grz," DONE"))
          }
          
        }
        
        else if (dist.graz.flag ==F) {
          
          # change directory to the executable directory
          setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs",sep=""))
          # run stepwat
          system("./stepwat    -f  files.in -s -o ../../sw_src/testing/files_step_soilwat.in")
          #system("./stepwat    -f  files.in -s -o /home/ksodhi/KyleProject/Stepwat.Site.1/sw_src/testing/files_step_soilwat.in")
          
          # change directory to "Output" folder
          setwd("Output")
          
          
          # identify the name of the biomass output file
          name.bmass.csv<-paste("bmassavg.Site",s,GCM[g],soil,"csv",sep=".")
          name.mort.csv<-paste("mortavg.Site",s,GCM[g],soil,"csv",sep=".")
          name.stdebug.sqlite<-paste("stdebug.Site",s,GCM[g],soil,"sqlite3",sep=".")
          
          # rename the bmassavg.csv
          system(paste("mv bmassavg.csv ",name.bmass.csv,sep=""))
          system(paste("mv mortavg.csv ",name.mort.csv,sep=""))
          system(paste("mv stdebug.sqlite3 ",name.stdebug.sqlite,sep=""))
          setwd(paste(directory,"Stepwat.Site.",s,".",g,"/sw_src/testing/Output",sep=""))
          source(output.file,local = TRUE)
          setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs/Output",sep=""))
        }
        # for all other GMC/year/RCP read the weather data into randomdata    
      } else if (GCM[g]!="Current"){
        
        for (y in YEARS) { # loop through all the time periods 50 or 90
          for (r in RCP) { # loop through all the RCP
            
            # Go to the weather directory
            setwd(paste(assembly_output,"Site_",s,sep=""))
            
            setwd(paste("Site_",s,"_hybrid-delta.",y,".",r,".",GCM[g], sep=""))
            weath.read<-paste(assembly_output,"Site_",s,"/Site_",s,"_hybrid-delta.",y,".",r,".",GCM[g], sep="")
            
            
            
            # identify the directory the weather will be pasted into        
            weather.dir2<-paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs/Input/sxw/Input/randomdata/",sep="")
            weather.dir3<-paste(directory,"Stepwat.Site.",s,".",g,"/sw_src/testing/Input/data_39.0625_-119.4375/",sep="")
            
            # copy the weather data into the randomdata folder
            if (TYPE=="basic" || TYPE=="drought" || TYPE=="back") {
              # copy the weather data into the randomdata folder
              system(paste("cp -a ",weath.read,"/. ",weather.dir2,sep=""))
            } 
            if (TYPE2=="markov") {
              system(paste("cp ",weath.read,"/mkv_covar.in ",weather.dir2,sep=""))
              system(paste("cp ",weath.read,"/mkv_prob.in ",weather.dir2,sep=""))
            }
            
            # copy the weather data into the data_39.0625_-199.4375 folder
            if (TYPE=="basic" || TYPE=="drought" || TYPE=="back") {
              # copy the weather data into the data_39.0625_-199.4375 folder
              system(paste("cp -a ",weath.read,"/. ",weather.dir3,sep=""))
            } 
            if (TYPE2=="markov") {
              system(paste("cp ",weath.read,"/mkv_covar.in ",weather.dir3,sep=""))
              system(paste("cp ",weath.read,"/mkv_prob.in ",weather.dir3,sep=""))
            }
            if (dist.graz.flag == T) {
              for (dst in dist.freq) {
                for (grz in graz.freq) {
                  for(intensity in graz_intensity ){
                    setwd(paste0(dist.directory))
                    dist.graz.name<-paste0("rgroup.freq",dst,".graz",grz,".",intensity,".in")
                    system(paste0("cp ",dist.graz.name," ",directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs/Input/"))
                    
                    setwd(paste0(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs/Input/"))
                    system("rm rgroup.in")
                    system(paste0("mv ",dist.graz.name," rgroup.in"))
                    
                    
                    # change directory to the executable directory
                    setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs",sep=""))
                    # run stepwat
                    system("./stepwat    -f  files.in -s -o ../../sw_src/testing/files_step_soilwat.in")
                    
                    # change directory to "Output" folder
                    setwd("Output")
                    
                    # identify the name of the biomass output file
                    name.bmass.csv<-paste("bmassavg.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                    name.mort.csv<-paste("mortavg.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"csv",sep=".")
                    name.stdebug.sqlite<-paste("stdebug.Site",s,GCM[g],"D",dst,"G",grz,intensity,soil,"sqlite3",sep=".")
                    
                    # rename the bmassavg.csv
                    system(paste("mv bmassavg.csv ",name.bmass.csv,sep=""))
                    system(paste("mv mortavg.csv ",name.mort.csv,sep=""))
                    system(paste("mv stdebug.sqlite3 ",name.stdebug.sqlite,sep=""))
                    
                    setwd(paste(directory,"Stepwat.Site.",s,".",g,"/sw_src/testing/Output",sep=""))
                    source(output.file,local = TRUE)
                    setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs/Output",sep=""))
                  }}
                
                
                print(paste0("DIST.GRAZ D",dst,".G",grz," DONE"))
              }
              
            }
            
            else if (dist.graz.flag ==F) {
              
              # change directory to the executable directory
              setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs",sep=""))
              # run stepwat
              system("./stepwat    -f  files.in -s -o ../../sw_src/testing/files_step_soilwat.in")
              
              # change directory to "Output" folder
              setwd("Output")
              
              
              # identify the name of the biomass output file
              name.bmass.csv<-paste("bmassavg.Site",s,GCM[g],y,r,soil,"csv",sep=".")
              name.mort.csv<-paste("mortavg.Site",s,GCM[g],y,r,soil,"csv",sep=".")
              name.stdebug.sqlite<-paste("stdebug.Site",s,GCM[g],y,r,soil,"sqlite3",sep=".")
              
              # rename the bmassavg.csv
              system(paste("mv bmassavg.csv ",name.bmass.csv,sep=""))
              system(paste("mv mortavg.csv ",name.mort.csv,sep=""))
              system(paste("mv stdebug.sqlite3 ",name.stdebug.sqlite,sep=""))
              
              setwd(paste(directory,"Stepwat.Site.",s,".",g,"/sw_src/testing/Output",sep=""))
              source(output.file,local = TRUE)
              setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.MT_drs/Stepwat_Inputs/Output",sep=""))
            }
            
            print(paste("RCP ",r," DONE",sep=""))
          }
          #print statement for when model done with that GCM
          print(paste("YEAR ",y," DONE",sep=""))
        }
        
      }
      print(paste("GCM ",GCM[g]," DONE",sep=""))
    }}
  
  stopImplicitCluster()
  
  # print statement for when model done with Site
  print(paste("Site ",s," Done",sep=""))
  
