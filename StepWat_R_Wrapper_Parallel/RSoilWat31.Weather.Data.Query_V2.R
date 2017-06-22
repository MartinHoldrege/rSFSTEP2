#The Burke-Lauenroth Laboratory 
#STEPWAT R Wrapper
#Query script for STEPWAT Wrapper
#Script to extract respective data from the database into a list

#Load required libraries
library(plyr)

#Connecting to the database
db<-dbDriver("SQLite")
db<-dbConnect(db,database)
con.env <- NULL
con.env$con<-db

#########################################################################
#Functions to access respective data

#Function to query data from the database
dbW_getWeatherData <- function(Site_id=NULL,lat=NULL,long=NULL,Label=NULL,startYear=NULL,endYear=NULL, Scenario="Current") {
  if(is.null(Site_id) && is.null(Label) && is.null(lat) && is.null(long)) {
    stop("No way to locate weather data from input")
  }
  
  useYears<-FALSE
  useStart<-FALSE
  useEnd  <-FALSE
  if(!is.null(startYear) | !is.null(endYear)) {#See if we should narrow the start end year range
    startYear <- as.integer(startYear)
    if(!is.na(startYear)) useStart<-TRUE
    endYear <- as.integer(endYear)
    if(!is.na(endYear)) useEnd<-TRUE
    if(useStart | useEnd) useYears<-TRUE
    if(useStart & useEnd) {
      if(startYear >= endYear | startYear<0 | endYear<0) {
        stop("Wrong start or end year")
      }
    }
  }
  Site_id<-as.integer(Site_id)
  if(length(Site_id) == 0) {
    Site_id <- dbW_getSiteId(lat,long,Label)
  } else {
    if(!dbGetQuery(con.env$con, paste("SELECT COUNT(*) FROM WeatherData WHERE Site_id=",Site_id,";",sep=""))[1,1]) {
      stop("Site_id does not exist.")
    }
  }
  if(!is.null(Site_id) && is.integer(Site_id) && Site_id >= 0) {
    Scenario <- dbGetQuery(con.env$con, paste("SELECT id FROM Scenarios WHERE Scenario='",Scenario,"';",sep=""))[1,1]
    result <- dbGetQuery(con.env$con, paste("SELECT StartYear,EndYear,data FROM WeatherData WHERE Site_id=",Site_id, " AND Scenario=",Scenario,";",sep=""));
    data <- dbW_blob_to_weatherData(result$StartYear, result$EndYear, result$data)
    if(inherits(data, "try-error")) stop(paste("Weather data for Site_id", Site_id, "is corrupted"))
  } else {
    stop(paste("Site_id for", Label, "not obtained."))
  }

  if(useYears) {
    if(useStart && useEnd) {
      startYear_idx <- match(startYear, 
                             as.integer(unlist(lapply(data, FUN=slot, "year"))))
      endYear_idx <- match(endYear, 
                           as.integer(unlist(lapply(data, FUN=slot, "year"))))
      data <- data[startYear_idx:endYear_idx]
    } else if(useStart) {
      startYear_idx <- match(startYear, 
                             as.integer(unlist(lapply(data, FUN=slot, "year"))))
      data <- data[startYear_idx:length(as.integer(unlist(lapply(data, FUN=slot, "year"))))]
    } else if(useEnd) {
      endYear_idx <- match(endYear,
                           as.integer(unlist(lapply(data, FUN=slot, "year"))))
      data <- data[1:endYear_idx]
    }
  }
  return(data)
}

#Function to extract data from blobs
dbW_blob_to_weatherData <- function(StartYear, EndYear, data_blob) {
  if(typeof(data_blob) == "list")
    data_blob <- data_blob[[1]]
  data <- strsplit(rawToChar(memDecompress(data_blob, type="gzip")), ";")[[1]]
  years <- seq(from=StartYear, to=EndYear)
  weatherData <- data.frame()
  for(i in 1:length(years)) {
    ydata <- read.csv(textConnection(data[i]),header=FALSE,sep=",",stringsAsFactors=FALSE)
    ydata <- as.data.frame(cbind(seq(from=1,to=dim(ydata)[1]),ydata))
    colnames(ydata) <- c("DOY","Tmax_C","Tmin_C","PPT_cm")
    ydata$year<-years[i]
    weatherData<-rbind.fill(weatherData,ydata)
  }
  return(weatherData)
}

#Function to extract data for a specific site
	.local <- function(sid){
		i_sw_weatherList <- list()
		for(k in seq_along(climate.conditions))
			i_sw_weatherList[[k]] <- dbW_getWeatherData(Site_id=sid, Scenario=climate.conditions[k])
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
dbDisconnect(db)

