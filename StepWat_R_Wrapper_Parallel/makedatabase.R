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

    total_sw2_daily_slyrs<-read.csv('total_sw2_daily_slyrs.csv',header=T)
    total_sw2_daily<-read.csv('total_sw2_daily.csv',header=T)    
    
    #calculate aggregated daily mean and sd - need to get the columns after data - site, GCM, soilType, dist_flag, dist_freq, graz_freq, intensity, RCP, YEARS
	length=length(total_sw2_daily_slyrs[2,])-10

	total_sw2_daily_slyrs_aggregated=aggregate(total_sw2_daily_slyrs[,c(3:length)],by=list(total_sw2_daily_slyrs$Day,total_sw2_daily_slyrs$site,total_sw2_daily_slyrs$GCM, total_sw2_daily_slyrs$soilType,total_sw2_daily_slyrs$dist_flag,total_sw2_daily_slyrs$dist_freq,total_sw2_daily_slyrs$graz_freq,total_sw2_daily_slyrs$intensity,total_sw2_daily_slyrs$RCP,total_sw2_daily_slyrs$YEARS),mean)
 	names(total_sw2_daily_slyrs_aggregated)[1:10]=c("Day","site","GCM","soilType","dist_flag","dist_freq","graz_freq","intensity","RCP","YEARS")
    
	length=length(total_sw2_daily[2,])-10

	total_sw2_daily_aggregated=aggregate(total_sw2_daily[,c(3:length)],by=list(total_sw2_daily$Day,total_sw2_daily$site,total_sw2_daily$GCM, total_sw2_daily$soilType,total_sw2_daily$dist_flag,total_sw2_daily$dist_freq,total_sw2_daily$graz_freq,total_sw2_daily$intensity,total_sw2_daily$RCP,total_sw2_daily$YEARS),mean)
 	names(total_sw2_daily_aggregated)[1:10]=c("Day","site","GCM","soilType","dist_flag","dist_freq","graz_freq","intensity","RCP","YEARS")

    #write all tables to the SQLite database
    dbWriteTable(db, "total_sw2_daily_slyrs",total_sw2_daily_slyrs_aggregated, 	append=T)
    dbWriteTable(db, "total_sw2_daily",total_sw2_daily_aggregated, append=T)
    dbWriteTable(db, "total_sw2_yearly_slyrs",total_sw2_yearly_slyrs, append=T)
    dbWriteTable(db, "total_sw2_yearly",total_sw2_yearly, append=T)
    dbWriteTable(db, "total_bmass", total_bmass, append=T)
    dbWriteTable(db, "total_mort", total_mort,append=T) 
  }
  
setwd(source.dir)

tickoff<-proc.time()-tickon
print(tickoff)