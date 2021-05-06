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


# adjust temp -------------------------------------------------------------

# adding a fixed value (delta_temp) to daily min/max temp

# * function -------------------------------------------------------------


#' increase precipitation intensity of swWeatherData object
#' 
#' @description  Updates the temp columns in the data matrix, by adding a 
#' fixed value
#'
#' @param x object of class swWeatherData
#' @param delta_temp fixed amount to add to daily min and max temp
#'
#' @return object of class swWeatherData
#' @export
update_swWeather_temp <- function(x, delta_temp) {
  stopifnot(class(x) == "swWeatherData",
            c("Tmax_C", "Tmin_C") %in% attributes(x@data)$dimnames[[2]]
  )
  
  # increase precip intensity for that year
  x@data[, "Tmax_C"] <- x@data[, "Tmax_C"] + delta_temp
  x@data[, "Tmin_C"] <- x@data[, "Tmin_C"] + delta_temp
  x
}


# * apply function to list ------------------------------------------------

if (delta_temp != 0) {
  message("using delta_temp = ", delta_temp, ",  to adjust daily temp")
  sw_weatherList <- purrr::modify_depth(sw_weatherList, .depth = 3, 
                                        .f = update_swWeather_temp,
                                        delta_temp = delta_temp)
}


