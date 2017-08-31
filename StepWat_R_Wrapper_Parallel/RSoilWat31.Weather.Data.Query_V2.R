#The Burke-Lauenroth Laboratory 
#STEPWAT R Wrapper
#Query script for STEPWAT Wrapper
#Script to extract respective data from the database into a list

#Load required libraries
library(plyr)

#Connecting to the database
stopifnot(rSOILWAT2::dbW_setConnection(database, check_version = TRUE)) 

#########################################################################
#Functions to access respective data

#Function to extract data for a specific site
	.local <- function(sid){
		i_sw_weatherList <- list()
		for(k in seq_along(climate.conditions))
			i_sw_weatherList[[k]] <- rSOILWAT2::dbW_getWeatherData(Site_id=sid, Scenario=climate.conditions[k])
		return(i_sw_weatherList)
		
	}

#Function to extract respective data for all sites and save it as a list
extract_data<-function(site_to_extract=NULL)
{
  sw_weatherList <- NULL
  for(i in seq_along(site_to_extract)){
    sw_weatherList[[i]] <- try(.local(sid=site_to_extract[i]), silent=TRUE)
  }
  #Saving the list as a .RData file
  save(sw_weatherList, file=file.path(source.dir, "WeatherData_2016.RData"))
  return (sw_weatherList)
}
	
sw_weatherList<-extract_data(site_to_extract = sites)
rSOILWAT2::dbW_disconnectConnection()