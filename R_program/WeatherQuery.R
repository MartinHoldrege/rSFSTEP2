#Weather query script to extract respective weather data for all scenarios from a pre-generated weather database into a list (sw_weatherList)

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
  return (sw_weatherList)
}
	
sw_weatherList<-extract_data(site_to_extract = sites)
rSOILWAT2::dbW_disconnectConnection()