#The Burke-Lauenroth Laboratory
#STEPWAT R Wrapper
# Vegetation code for STEPWAT Wrapper


#' Function to estimate relative abundance of functional groups based on
#' climate relationships
#'
#' @param sw_weatherList A list. An object as created by the function
#'   \code{\link{extract_data}} of the script
#'   \var{"RSoilWat31.Weather.Data.Query_V2.R"}. It is a list with an element
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

  temp_veg <- rSOILWAT2::estimate_PotNatVeg_composition(
    MAP_mm = 10 * temp_clim[["MAP_cm"]], MAT_C = temp_clim[["MAT_C"]],
    mean_monthly_ppt_mm = 10 * temp_clim[["meanMonthlyPPTcm"]],
    mean_monthly_Temp_C = temp_clim[["meanMonthlyTempC"]],
    dailyC4vars = temp_clim[["dailyC4vars"]])

  # Result container
  res <- array(NA,
    dim = c(n_sites, n_climate.conditions,
      length(temp_veg[["Rel_Abundance_L0"]])),
    dimnames = list(names(sw_weatherList), names(sw_weatherList[[1]]),
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

      temp_veg <- rSOILWAT2::estimate_PotNatVeg_composition(
        MAP_mm = 10 * temp_clim[["MAP_cm"]], MAT_C = temp_clim[["MAT_C"]],
        mean_monthly_ppt_mm = 10 * temp_clim[["meanMonthlyPPTcm"]],
        mean_monthly_Temp_C = temp_clim[["meanMonthlyTempC"]],
        dailyC4vars = temp_clim[["dailyC4vars"]])

      res[n_sites, k_scen, ] <- temp_veg[["Rel_Abundance_L0"]]
    }

  res
}
