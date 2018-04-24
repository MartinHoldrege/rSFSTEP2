#The Burke-Lauenroth Laboratory 
#STEPWAT R Wrapper
#Script to compile individual Output Databases into 1 master SQLite file

library(plyr)
library(RSQLite)

source.dir<-"" #Location where the databases are located, needs to be set by the user

setwd(source.dir)
output_database<-paste("Output_Compiled",".sqlite",sep="")
db<-dbConnect(SQLite(),output_database)
sites<-c(14,103) #Add the id of sites to be compiled

g<-sites[1]

input_database<-paste("Output_site_",g,".sqlite",sep="")
con<-dbConnect(SQLite(), input_database)

total_bmass<-data.frame(dbGetQuery(con,'select * from total_bmass'))
total_mort<-data.frame(dbGetQuery(con,'select * from total_mort'))
total_sw2_yearly_slyrs<-data.frame(dbGetQuery(con,'select * from total_sw2_yearly_slyrs'))
total_sw2_yearly<-data.frame(dbGetQuery(con,'select * from total_sw2_yearly'))

dbDisconnect(con)

g<-sites[2]

input_database<-paste("Output_site_",g,".sqlite",sep="")
con<-dbConnect(SQLite(),input_database)

total_bmass_2<-data.frame(dbGetQuery(con,'select * from total_bmass'))
total_mort_2<-data.frame(dbGetQuery(con,'select * from total_mort'))
total_sw2_yearly_slyrs_2<-data.frame(dbGetQuery(con,'select * from total_sw2_yearly_slyrs'))
total_sw2_yearly_2<-data.frame(dbGetQuery(con,'select * from total_sw2_yearly'))

dbDisconnect(con)

total_bmass_3<-rbind(total_bmass,total_bmass_2)
total_mort_3<-rbind(total_mort,total_mort_2)
total_sw2_yearly_slyrs_3<-rbind(total_sw2_yearly_slyrs,total_sw2_yearly_slyrs_2)
total_sw2_yearly_3<-rbind(total_sw2_yearly,total_sw2_yearly_2)

dbWriteTable(db, "total_bmass_3", total_bmass_3, append=T)
dbWriteTable(db, "total_mort_3", total_mort_3, append=T)
dbWriteTable(db, "total_sw2_yearly_slyrs_3",total_sw2_yearly_slyrs_3, append=T)
dbWriteTable(db, "total_sw2_yearly_3",total_sw2_yearly_3, append=T)