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
	
sw_weatherList_old <-extract_data(site_to_extract = sites)
rSOILWAT2::dbW_disconnectConnection()


# update weather list -----------------------------------------------------


# update weather list with increased precipitation intensity

# * functions -------------------------------------------------------------


#' increase precipitation intensity of swWeatherData object
#' 
#' Updates the PPT_cm column in the data matrix, using a function
#' that increases precipitation intensity of that vector. Currently only
#' using incr_event_intensity function but could update to any function
#' that can work on a numeric vector
#'
#' @param x object of class swWeatherData
#' @param ... arguments passed to precipr::incr_event_intensity
#'
#' @return object of class swWeatherData
#' @export
update_swWeatherData <- function(x, ...) {
  stopifnot(class(x) == "swWeatherData",
            "PPT_cm" %in% attributes(x@data)$dimnames[[2]]
  )
  
  # increase precip intensity for that year
  x@data[, "PPT_cm"] <- precipr::incr_event_intensity(x@data[, "PPT_cm"], ...)
  x
}



# * modify ----------------------------------------------------------------

# doubling event intensity (specified by from and to args)
sw_weatherList <- purrr::modify_depth(sw_weatherList_old, .depth = 3, 
                               .f = update_swWeatherData, from = 1, to = 1)

# testing weather operation worked
if (FALSE){
  ppt_mean <- function(x) {
    ppt <- x@data[, "PPT_cm"]
    precipr::mean_event_size(ppt)
  }
  # get mean event size for original and modified lists
  old <- map_depth(sw_weatherList_old, .depth = 3, .f = ppt_mean) %>% unlist
  new <- map_depth(sw_weatherList, .depth = 3, .f = ppt_mean) %>% unlist
  
  # confirm event size roughly doubled
  hist(new/old) # can be < 2 when odd number of events in a year
}

remove(sw_weatherList_old)
