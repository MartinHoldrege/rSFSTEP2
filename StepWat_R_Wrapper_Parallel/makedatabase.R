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
    
    #setwd(paste(directory,"/Stepwat.Site.",s,".",g,"/sw_src/testing/Output",sep=""))
    #temp<-data.frame(read.csv("total_wk.csv",header=TRUE, sep=","))
    #dbWriteTable(db, "total_wk", temp, append=T)
    
    #setwd(paste(directory,"/Stepwat.Site.",s,".",g,"/sw_src/testing/Output",sep=""))
    #temp<-data.frame(read.csv("total_mo.csv",header=TRUE, sep=","))
    #dbWriteTable(db, "total_mo", temp, append=T)
    
    #set working directory to where the biomass and mortality output files are
    setwd(paste(directory,"/Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output",sep=""))
    
    #read in csv file and remove empty column at the end
    total_bmass=read.csv('total_bmass.csv',header=T)
	total_bmass$X=NULL
    
    #write grep function to remove extra column headers that appear throughout spreadsheet
    total_bmass=total_bmass[grep("Year",total_bmass$Disturbs,invert=T),]
    
    #read in mort file and also remove extra column headers
    total_mort=read.csv('total_mort.csv',header=T)
    total_mort=total_mort[grep("Age",total_mort$Age,invert=T),]
    
    setwd(directory)
    
    #change working directory to where SOILWAT output files are
    setwd(paste(directory,"/Stepwat.Site.",s,".",g,"/sw_src/testing/Output",sep=""))
    total_yr=read.csv('total_yr.csv',header=T)
    total_yr=total_yr[grep("YEAR",total_yr$YEAR,invert=T),]
    
    #adding RCP and YEARS columns to current total_bmass file
    if(g==1)
    {     
        total_bmass$RCP=rep("NONE",length(total_bmass$site))
        total_bmass$YEARS=rep("NONE", length(total_bmass$site))
        
        total_mort$RCP=rep("NONE",length(total_mort$site))
        total_mort$YEARS=rep("NONE", length(total_mort$site))
        
        total_yr$RCP=rep("NONE",length(total_yr$site))
        total_yr$YEARS=rep("NONE", length(total_yr$site))
        
    }
    
    else{
               
        #if GCM is not current, then reorder the columns so it matches current total files
   		total_bmass=total_bmass[,c(1:86,89:92,87:88)]
    
    	total_yr=total_yr[,c(1:190,193:196,191:192)]
		total_mort=total_mort[,c(1:32,35:38,33:34)]
    }
    
    #write all tables to the SQLite database
    dbWriteTable(db, "total_yr",total_yr, append=T)
    dbWriteTable(db, "total_bmass", total_bmass, append=T)
    dbWriteTable(db, "total_mort", total_mort, append=T)
    
  }
  setwd(source.dir)


tickoff<-proc.time()-tickon
print(tickoff)

