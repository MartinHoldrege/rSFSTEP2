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
    #default is to not put daily, monthly, and weekly output into SQLite database. In most cases, we will not save weekly
    #and monthly output. Daily output is currently too large to drop into SQLite database. Once we have added aggregation
    #of the daily output to rSFSTEP2, we will want daily output in the SQLite database as well.
    
    #setwd(paste(directory,"/Stepwat.Site.",s,".",g,"/sw_src/testing/Output",sep=""))
    #temp<-data.frame(read.csv("total_dy.csv",header=TRUE, sep=","))
    #dbWriteTable(db, "total_dy", temp, append=T)
        
    #set working directory to where the biomass and mortality output files are
    setwd(paste(directory,"/Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output",sep=""))
    
    #read in output files
    total_bmass=read.csv('total_bmass.csv',header=T)
    total_mort=read.csv('total_mort.csv',header=T)
    total_yr=read.csv('total_yr.csv',header=T)
    
      #write all tables to the SQLite database
    dbWriteTable(db, "total_yr",total_yr, append=T)
    dbWriteTable(db, "total_bmass", total_bmass, append=T)
    dbWriteTable(db, "total_mort", total_mort,append=T)
    
  }
  setwd(source.dir)

tickoff<-proc.time()-tickon
print(tickoff)