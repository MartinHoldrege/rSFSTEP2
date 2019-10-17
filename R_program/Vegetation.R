#STEPWAT R Wrapper
# Vegetation code for STEPWAT Wrapper

#' Function to estimate relative abundance of functional groups based on
#' climate relationships
#'
#' @param sw_weatherList A list. An object as created by the function
#'   \code{\link{extract_data}} of the script
#'   \var{"WeatherQuery.R"}. It is a list with an element
#'   for each \var{sites}; these elements are themselves lists with elements
#'   for each \var{climate.conditions}; these are in turn lists with a
#'   S4-class
#'   \code{\link[rSOILWAT2:swWeatherData-class]{rSOILWAT2::swWeatherData}}
#'   object for each year as is returned by the function
#'   \code{\link[rSOILWAT2]{dbW_getWeatherData}}.
#' @param site_latitude A numeric vector. The latitude in degrees (N, positive;
#'   S, negative) of the simulation \var{sites}. If vector of length one, then
#'   the value is repeated for all \var{sites}.
#'
#' @seealso \code{\link[rSOILWAT2]{calc_SiteClimate}} to estimate relevant
#'   climate variables, and
#'   \code{\link[rSOILWAT2]{estimate_PotNatVeg_composition}} to estimate
#'   potential natural vegetation composition.
#'
#' @examples
#' data("weatherData", package = "rSOILWAT2")
#' sw_weatherList <- list(
#'   site1 = list(Current = weatherData, Future1 = weatherData),
#'   site2 = list(Current = weatherData, Future1 = weatherData))
#' relabund <- estimate_STEPWAT_relativeVegAbundance(sw_weatherList)
#'
estimate_STEPWAT_relativeVegAbundance <- function(sw_weatherList,
  site_latitude = 90) {

  n_sites <- length(sw_weatherList)

  if (length(site_latitude) != n_sites && length(site_latitude) > 1) {
    stop("'estimate_STEPWAT_relativeVegAbundance': argument 'site_latitude' ",
      "must have a length one or be equal to the length of 'sw_weatherList'.")
  } 

  n_climate.conditions <- unique(lengths(sw_weatherList))

  # Determine output size
  temp_clim <- rSOILWAT2::calc_SiteClimate(
    weatherList = sw_weatherList[[1]][[1]], do_C4vars = TRUE, do_Cheatgrass_ClimVars = TRUE,
    latitude = site_latitude[1])
  
  # variables used to determine annual grasses (cheatgrass) relative abundance
  prec7 <- as.numeric(temp_clim$Cheatgrass_ClimVars["Month7th_PPT_mm"])
  tmin2 <- as.numeric(temp_clim$Cheatgrass_ClimVars["MinTemp_of2ndMonth_C"])
  
  # set annuals fraction. Equation derived from raw data in Brummer et al. 2016
  if(prec7 > 30 | tmin2 < -13){
    annuals_fraction <- 0.0
  } else {
    annuals_fraction <- 0.6732229 - 0.0254591 * prec7 + 0.0538173 * tmin2 - 0.0021601 * prec7 * tmin2
    #extra check to make sure the annuals fraction is non-negative
    if(annuals_fraction < 0){
      annuals_fraction = 0;
    }
  }

  temp_veg <- rSOILWAT2::estimate_PotNatVeg_composition(
    MAP_mm = 10 * temp_clim[["MAP_cm"]], MAT_C = temp_clim[["MAT_C"]],
    mean_monthly_ppt_mm = 10 * temp_clim[["meanMonthlyPPTcm"]],
    mean_monthly_Temp_C = temp_clim[["meanMonthlyTempC"]],
    dailyC4vars = temp_clim[["dailyC4vars"]], Annuals_Fraction = annuals_fraction)

  # Result container
  res <- array(NA,
    dim = c(n_sites, n_climate.conditions,
      length(temp_veg[["Rel_Abundance_L0"]])),
    dimnames = list(names(sw_weatherList), climate.conditions,
      names(temp_veg[["Rel_Abundance_L0"]])))
  res[1, 1, ] <- temp_veg[["Rel_Abundance_L0"]]

  # Calculate relative abundance
    for (k_scen in seq_len(n_climate.conditions)) {
      if (k_scen == 1) {
        next
      }

      temp_clim <- rSOILWAT2::calc_SiteClimate(
        weatherList = sw_weatherList[[n_sites]][[k_scen]], do_C4vars = TRUE, do_Cheatgrass_ClimVars = TRUE,
        latitude = site_latitude[n_sites])
      
      # variables used to determine annual grasses (cheatgrass) relative abundance
      prec7 <- as.numeric(temp_clim$Cheatgrass_ClimVars["Month7th_PPT_mm"])
      tmin2 <- as.numeric(temp_clim$Cheatgrass_ClimVars["MinTemp_of2ndMonth_C"])
      
      # set annuals fraction. Equation derived from raw data in Brummer et al. 2016
      if(prec7 > 30 | tmin2 < -13){
        annuals_fraction <- 0.0
      } else {
        annuals_fraction <- 0.6732229 - 0.0254591 * prec7 + 0.0538173 * tmin2 - 0.0021601 * prec7 * tmin2
        #extra check to make sure the annuals fraction is non-negative
        if(annuals_fraction < 0){
          annuals_fraction = 0;
        }
      }

      temp_veg <- rSOILWAT2::estimate_PotNatVeg_composition(
        MAP_mm = 10 * temp_clim[["MAP_cm"]], MAT_C = temp_clim[["MAT_C"]],
        mean_monthly_ppt_mm = 10 * temp_clim[["meanMonthlyPPTcm"]],
        mean_monthly_Temp_C = temp_clim[["meanMonthlyTempC"]],
        dailyC4vars = temp_clim[["dailyC4vars"]], Annuals_Fraction = annuals_fraction)

      res[n_sites, k_scen, ] <- temp_veg[["Rel_Abundance_L0"]]
    }

  res
}

#' Function to scale phenology values based on climate and a reference growing season.
#' 
#' @param matrices A list of matrices that will all be scaled.
#' @param sw_weatherList A list. An object as created by the function
#'   \code{\link{extract_data}} of the script
#'   \var{"WeatherQuery.R"}. It is a list with an element
#'   for each \var{sites}; these elements are themselves lists with elements
#'   for each \var{climate.conditions}; these are in turn lists with a
#'   S4-class
#'   \code{\link[rSOILWAT2:swWeatherData-class]{rSOILWAT2::swWeatherData}}
#'   object for each year as is returned by the function
#'   \code{\link[rSOILWAT2]{dbW_getWeatherData}}.
#' @param defaultGrowingSeason A numeric vector of values between 1 and 12. The number
#'   of months that describe the potential active season of the input matrice.
#' @param site_latitude A numeric vector. The latitude in degrees (N, positive;
#'   S, negative) of the simulation \var{sites}. If vector of length one, then
#'   the value is repeated for all \var{sites}.
#' @param includeGrowingSeasonInfo A boolean value. If TRUE, the return list will
#'   contain 2 entries: return[[1]] is a list of the scaled matrices and 
#'   return[[2]] is a list of boolean vectors where TRUE means that for the given
#'   scenario and month the mean temperature was above the minimum growing temperature.
#'   If includeGrowingSeason is FALSE, only the list of scaled growing seasons
#'   will be returned.
#'
#' @examples
#' data("weatherData", package = "rSOILWAT2")
#' matrices <- list( phenology, prod_litter, prod_biomass)
#' sw_weatherList <- list(
#'   site1 = list(Current = weatherData, Future1 = weatherData),
#'   site2 = list(Current = weatherData, Future1 = weatherData))
#' defaultGrowingSeason <- c(3:12)
#' scale_phenology(matrices, sw_weatherList, defaultGrowingSeason)
#' 
scale_phenology <- function(matrices, sw_weatherList, defaultGrowingSeason = 3:10, 
                            site_latitude = 90, includeGrowingSeasonInfo = FALSE){
  n_sites <- length(sw_weatherList)
  
  if (length(site_latitude) != n_sites && length(site_latitude) > 1) {
    stop("'scale_phenology': argument 'site_latitude' ",
         "must have a length one or be equal to the length of 'sw_weatherList'.")
  } 
  
  n_climate.conditions <- unique(lengths(sw_weatherList))
  
  return_list <- list()
  growingSeason_list <- list()
  
  # Calculate relative abundance
  for (k_scen in seq_len(n_climate.conditions)) {
    temp_clim <- rSOILWAT2::calc_SiteClimate(
      weatherList = sw_weatherList[[n_sites]][[k_scen]], 
      do_C4vars = FALSE, 
      do_Cheatgrass_ClimVars = FALSE,
      latitude = site_latitude[n_sites])
    
    if(includeGrowingSeasonInfo){
      growingSeason_list[[k_scen]] <- temp_clim[["meanMonthlyTempC"]] > 4
    }
    
    return_list[[k_scen]] <- rSOILWAT2::adjBiom_by_temp(matrices, 
                                                        temp_clim[["meanMonthlyTempC"]], 
                                                        reference_growing_season = defaultGrowingSeason,
                                                        growing_limit_C = 4,
                                                        isNorth = TRUE)
  }
  
  if(includeGrowingSeasonInfo){
    return_list <- list(return_list, growingSeason_list)
  }
  
  return_list
}
