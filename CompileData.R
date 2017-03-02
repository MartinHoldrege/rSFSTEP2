#The Burke-Lauenroth Laboratory 
#STEPWAT R Wrapper
#Script to compile individual Output Databases

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

total_dy<-data.frame(dbGetQuery(con,'select * from total_dy'))

total_wk<-data.frame(dbGetQuery(con,'select * from total_wk'))

total_mo<-data.frame(dbGetQuery(con,'select * from total_mo'))

total_yr<-data.frame(dbGetQuery(con,'select * from total_yr'))

total_bmass<-data.frame(dbGetQuery(con,'select * from total_bmass'))

total_mort<-data.frame(dbGetQuery(con,'select * from total_mort'))

dbDisconnect(con)


g<-sites[2]

input_database<-paste("Output_site_",g,".sqlite",sep="")
con<-dbConnect(SQLite(),input_database)

total_dy_2<-data.frame(dbGetQuery(con,'select * from total_dy'))

total_wk_2<-data.frame(dbGetQuery(con,'select * from total_wk'))

total_mo_2<-data.frame(dbGetQuery(con,'select * from total_mo'))

total_yr_2<-data.frame(dbGetQuery(con,'select * from total_yr'))

total_bmass_2<-data.frame(dbGetQuery(con,'select * from total_bmass'))

total_mort_2<-data.frame(dbGetQuery(con,'select * from total_mort'))

dbDisconnect(con)


total_dy_3<-rbind(total_dy,total_dy_2)

total_wk_3<-rbind(total_wk,total_wk_2)

total_mo_3<-rbind(total_mo,total_mo_2)

total_yr_3<-rbind(total_yr,total_yr_2)

total_bmass_3<-rbind(total_bmass,total_bmass_2)

total_mort_3<-rbind(total_mort,total_mort_2)

dbWriteTable(db, "total_dy_3", total_dy_3, append=T)
dbWriteTable(db, "total_wk_3", total_wk_3, append=T)
dbWriteTable(db, "total_mo_3", total_mo_3, append=T)
dbWriteTable(db, "total_yr_3", total_yr_3, append=T)
dbWriteTable(db, "total_bmass_3", total_bmass_3, append=T)
dbWriteTable(db, "total_mort_3", total_mort_3, append=T)
