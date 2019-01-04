#The Burke-Lauenroth Laboratory 
#STEPWAT R Wrapper
#Script to compile individual Output Databases into 1 master SQLite file

library(plyr)
library(RSQLite)

dir_db<-"" #Location where the databases are located, needs to be set by the user

setwd(dir_db)
output_database<-paste("Output_Compiled",".sqlite",sep="")
db<-dbConnect(SQLite(),output_database)
sites<-c(14,103) #Add the id of all sites to be compiled, 14 and 103 are here as examples

for (i in 1:length(sites)) {
g<-sites[i]

input_database<-paste("Output_site_",g,".sqlite",sep="")
con<-dbConnect(SQLite(),input_database)

total_bmass_g<-data.frame(dbGetQuery(con,'select * from total_bmass'))
total_sw2_yearly_slyrs_g<-data.frame(dbGetQuery(con,'select * from total_sw2_yearly_slyrs'))
total_sw2_yearly_g<-data.frame(dbGetQuery(con,'select * from total_sw2_yearly'))
total_sw2_monthly_slyrs_g<-data.frame(dbGetQuery(con,'select * from total_sw2_monthly_slyrs'))
total_sw2_monthly_g<-data.frame(dbGetQuery(con,'select * from total_sw2_monthly'))

dbDisconnect(con)

dbWriteTable(db, "total_bmass", total_bmass_g, append=T)
dbWriteTable(db, "total_sw2_yearly_slyrs",total_sw2_yearly_slyrs_g, append=T)
dbWriteTable(db, "total_sw2_yearly",total_sw2_yearly_g, append=T)
dbWriteTable(db, "total_sw2_monthly_slyrs",total_sw2_monthly_slyrs_g, append=T)
dbWriteTable(db, "total_sw2_monthly",total_sw2_monthly_g, append=T)

}

#Add index to the compiled database
#Get names of database(s) to add index to
fname_dbs <- list.files(dir_db, pattern = "sqlite", full.names = TRUE)

#Local functions utilized below
dbConnect_OutputDB <- function(fname = NULL, dir = NULL, site = NULL) {
  fname <- get_OutputDB_filenames(fname, dir, site)[1]

  if (file.exists(fname)) {
    DBI::dbConnect(RSQLite::SQLite(), fname)
  } else NULL
}

add_index <- function(con) {
  prev_indices <- DBI::dbGetQuery(con, "SELECT * FROM sqlite_master WHERE type = 'index'")

  if (NROW(prev_indices) > 0 && "MZ_exp" %in% prev_indices[, "name"])
    return(NULL)

  DBI::dbGetQuery(con, paste("CREATE INDEX MZ_exp ON total_bmass (site, GCM, YEARS,",
    "soilType, intensity, dist_freq)"))
}

get_OutputDB_filenames <- function(fnames = NULL, dir = NULL, sites = NULL) {
  if (!is.null(dir) && !is.null(sites)) {
    file.path(dir, paste0("Output_site_", sites, ".sqlite"))

  } else if (all(sapply(fnames, file.exists))) {
    fnames
  } else NULL
}

#Finally add indices to DBs
temp <- lapply(fname_dbs, function(fdb) {
  print(paste(Sys.time(), "add index to", basename(fdb)))
  con <- dbConnect_OutputDB(fdb)
  temp <- add_index(con)
  DBI::dbDisconnect(con)
}