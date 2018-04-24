#The Burke-Lauenroth Laboratory 
#SoilWatOutput.R
#Script to rename the columns of the compiled csv files, and push them to a sqlite database.

library(plyr)
library(RSQLite)
tickon<-proc.time()

#Add number of sites and GCMs
s<-sitefolderid
GCM<-14

source.dir<-"nopath/"

#Add output database
output_database<-paste(source.dir,"Output_site_",notassigned,".sqlite",sep="")
db <- dbConnect(SQLite(), output_database)

setwd(source.dir)

directory<-source.dir
setwd(directory)
  for (g in 1:GCM)
  {      
    #set working directory to where the biomass and mortality output files are
    setwd(paste(directory,"/Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output",sep=""))
    
    #read in output files
    total_bmass=read.csv('total_bmass.csv',header=T)
    total_mort=read.csv('total_mort.csv',header=T)

	setwd(directory)
    #change working directory to where SOILWAT output files are
	setwd(paste(directory,"/Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output/sw_output",sep=""))
    
  	total_sw2_yearly_slyrs=read.csv('total_sw2_yearly_slyrs.csv',header=T)
    total_sw2_yearly=read.csv('total_sw2_yearly.csv',header=T)

    #default is to not put daily output into SQLite database as is currently too large. Once we have added aggregation of the daily output to rSFSTEP2, we will want daily output in the SQLite database as well.
    #total_sw2_daily_slyrs<-read.csv('total_sw2_daily_slyrs.csv',header=T)
    #total_sw2_daily<-read.csv('total_sw2_daily.csv',header=T)    
    
    #write all tables to the SQLite database
    dbWriteTable(db, "total_sw2_yearly_slyrs",total_sw2_yearly_slyrs, append=T)
    dbWriteTable(db, "total_sw2_yearly",total_sw2_yearly, append=T)
    dbWriteTable(db, "total_bmass", total_bmass, append=T)
    dbWriteTable(db, "total_mort", total_mort,append=T) 
  }
  
setwd(source.dir)

tickoff<-proc.time()-tickon
print(tickoff)