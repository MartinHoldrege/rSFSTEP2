#Main R Script that initiates the R program and sources all downstream functionality held in .R files.

#Load Required Packages
library(DBI)
library(RSQLite)
library(rSOILWAT2)
library(doParallel)

#Load source files and directories in the environment

#Number of cores, the user must change the number of processors accordingly
proc_count<-6

#Source directory, the source.directory will be filled in automatically when rSFSTEP2 runs
source.dir<-"nopath"
source.dir<-paste(source.dir,"/", sep="")
setwd(source.dir)

#Path to the weather database, which needs to be set by the user
db_loc<-""

#Database location, edit the name of the weather database accordingly
database_name=""
database<-file.path(db_loc,database_name)

#Weather query script (Loads weather data from the weather database for all climate scenarios into a list for each site)
query.file<-paste(source.dir,"RSoilWat31.Weather.Data.Query_V2.R", sep="")

#Weather assembly script (Assembles weather data with respect to years and conditions)
assemble.file<-paste(source.dir,"Weather.Assembly.Choices_V2.R", sep="")

#Markov script (Generates site-specific markov files used for weather generation in SOILWAT2)
markov.file<-paste(source.dir,"Markov.Weather_V2.R",sep="")

#Wrapper script (Executes STEPWAT2 for all climate-disturbance-input parameter combinations)
wrapper.file<-paste(source.dir,"StepWat.Wrapper.Code_V3.R", sep="")

#Output script (Combines individual output files into a master output file for each site)
output.file<-paste(source.dir,"SoilWatOutput.R", sep="")

#Start timing for timing statistics
tick_on<-proc.time()

#rSFSTEP2 will automatically populate the site string with the sites specified in generate_stepwat_sites.sh
site<-c(sitefolderid)

#This code is used in the circumstance when you want to use different species.in parameters for different sites
#In this case, we have three different species.in files which are found in the STEPWAT_DIST folder. The below strings
#correspond to which sites we want to use each species.in file for. 
species1<-c(21,80,144,150,244,291,374,409,411,542,320,384,391,413,501,592,687,733,758,761,781,787,798,816,824,828,866,868,869,876,879)
species2<-c(609,676,729,730,778,792,809,818,826,829,854,857,862)
species3<-c(163,211,221,230,264,283,341,354,365,380,387,497,524,543,566,581,608,175,178,217,319,335,369,498,595,659,4,7,14,15,23,79)
species<-"species"

################################ Weather Query Code ###################################

#Setup parameters for the weather extraction (time periods (Current, Future), scenarios (RCP.GCMs)) 
simstartyr <- 1979
endyr <- 2010
climate.ambient <- "Current"

#Specify the RCP/GCM combinations
#Default settings for testing rSFSTEP2, which represents a single GCM and two RCPs
climate.conditions <- c(climate.ambient,  "RCP45.CanESM2", "RCP85.CanESM2")

#All climate conditions typically utilized in complete simulation runs, uncomment for simulation runs
#climate.conditions <- c(climate.ambient,  "RCP45.CanESM2", "RCP45.CESM1-CAM5", "RCP45.CSIRO-Mk3-6-0", "RCP45.FGOALS-g2", "RCP45.FGOALS-s2", "RCP45.GISS-E2-R", "RCP45.HadGEM2-CC", "RCP45.HadGEM2-ES",
                        "RCP45.inmcm4", "RCP45.IPSL-CM5A-MR", "RCP45.MIROC5", "RCP45.MIROC-ESM","RCP45.MRI-CGCM3", "RCP85.CanESM2", "RCP85.CESM1-CAM5", "RCP85.CSIRO-Mk3-6-0", "RCP85.FGOALS-g2","RCP85.FGOALS-s2","RCP85.GISS-E2-R","RCP85.HadGEM2-CC","RCP85.HadGEM2-ES","RCP85.inmcm4","RCP85.IPSL-CM5A-MR","RCP85.MIROC5","RCP85.MIROC-ESM","RCP85.MRI-CGCM3")
#Store climate conditons
#List of all future and current scenarios putting "Current" first	
temp <- climate.conditions[!grepl(climate.ambient, climate.conditions)] #make sure 'climate.ambient' is first entry
if(length(temp) > 0){

#use with Vic weather database and all new weather databases
if(database_name!="dbWeatherData_Sagebrush_KP.v3.2.0.sqlite")
{
    #Difference between start and end year(if you want 2030-2060 use 50; if you want 2070-2100 use 90 below)
    deltaFutureToSimStart_yr <- c("d50","d90")
    
    #Downscaling method
    downscaling.method <- c("hybrid-delta-3mod")
    temp <- paste0(deltaFutureToSimStart_yr, "yrs.", rep(temp, each=length(deltaFutureToSimStart_yr)))
    
    #Set Years
    YEARS<-c("d50yrs","d90yrs")
  }
  else
  {
    #Difference between start and end year(if you want 2030-2060 use 50; if you want 2070-2100 use 90 below)
    deltaFutureToSimStart_yr <- c(50,90)
    
    #Downscaling method
    downscaling.method <- c("hybrid-delta")
   
    temp <- paste0(deltaFutureToSimStart_yr, "years.", rep(temp, each=length(deltaFutureToSimStart_yr)))
    #Set Years
    YEARS<-c("50years","90years")
  }
temp <- paste0(downscaling.method, ".", rep(temp, each=length(downscaling.method))) #add (multiple) downscaling.method
}

climate.conditions <-  c("Current",temp)
temp<-c("Current",temp)

#Vector of sites, the code needs to be run on, this will be populated by rSFSTEP2
sites<-c(notassigned) 

#Source the weather query code
source(query.file)

############################### End Weather Query Code ################################

############################### Weather Assembly Code #################################

#This script re-assembles the necessary weather data that was extracted during the weather query step based on user specifications
#If the user wants to exclusively utilize randomly generate weather data from the markov weather generator, no settings should be changed here

#Set output directories
weather.dir<-source.dir
setwd(weather.dir)

#Create the StepWat.Weather.Markov.Test folder in which to place weath.in files and/or markov files (mkv_covar.in, mkv_prob.in)
dir.create("StepWat.Weather.Markov.Test", showWarnings = FALSE)
assembly_output<-paste(source.dir,"StepWat.Weather.Markov.Test/",sep="")
setwd(assembly_output)

#Number of scenarios (GCM X RCP X Periods run)
H<-length(temp)

#Parameters for weather assembly script
AssemblyStartYear<-1980
# Number of years (in one section)
K<-30
# Interval Size
INT<-30
# Final number of years wanted
FIN<-30
#Resampling time
RE<-FIN/INT

#### Type ##########################################
# choose between "basic" (for 1,5,10,30 year); "back" (for 5 year non-driest back-to-back);
#         OR "drought" (for 5 year non-driest back-to-back and only once in 20 years); or "markov"
#         (for markov code output) !!!! if using Markov remember to flag it in weathersetup.in !!!!
#Set Type, TYPE="basic" is for both basic and markov. TYPE="markov" is for only markov.
TYPE<-"markov"

#Source the weather assembly script
source(assemble.file)

############################### End Weather Assembly Code ################################

############################# MARKOV Weather File Generation Code ##############################
#This code generates two site-specific files necessary for the Markov Weather Generator in SOILWAT2. mk_covar.in
#and mk_prob.in. These files are generated based on the site-specific and scenario-specific weather data for each site that is extracted during the previous step.

#Change directory to the folder specific to this site within StepWat.Weather.Markov.Test
setwd(assembly_output)

#Number of years of historical or future weather data that will be utilized to generate mkv_covar.in and mkv_prob.in 
yr<-30 

#Source markov script
source(markov.file)

############################# End MARKOV Weather File Generation Code ##############################

############### Run Wrapper Code ############################################################

########### Set climate scenarios, disturbance regimes, and soil types for each STEPWAT2 should be executed ###############

#This code utilizes different species parameters for different sites, default here is 3 unique sets of species parameters held in 3 separate species.in files in STEPWAT_DIST
if(is.element(sites,species1))
{
    species<-"species1.in"
} else if (is.element(sites,species2)) {
    species<-"species2.in"
} else {	species<-"species3.in" }

#Directory stores working directory
directory<-source.dir

#Set GCMs, must match GCMs set in climate.conditions above
#Default settings for testing rSFSTEP2, which represents a subset of potential GCMs
GCM<-c("Current","CanESM2")

#All GCM options typically utilized in complete simulation runs, uncomment for simulation runs
#GCM<-c("Current","CanESM2","CESM1-CAM5","CSIRO-Mk3-6-0","FGOALS-g2","FGOALS-s2","GISS-E2-R","HadGEM2-CC","HadGEM2-ES","inmcm4", "IPSL-CM5A-MR", "MIROC5", "MIROC-ESM", "MRI-CGCM3")

#Set RCPs, must match RCPs set in climate.conditions above
RCP<-c("RCP45","RCP85")

#Disturbance flag, turn to "F" if not using disturbances (grazing,fire)
dist.graz.flag<-T

#Set the path to the STEPWAT_DIST folder where disturbance inputs (held in rgroup.in), species inputs (held in species.in), and soil inputs (held in soils.in) are specified
dist.directory<-paste(source.dir,"STEPWAT_DIST/",sep="")

#Specify fire return interval (FRI). If not simulating fire but do want grazing set 'dist.freq<-0'
#Default settings for testing rSFSTEP2, which represents a single FRI
dist.freq<-c(50)

#All FRI options typically utilized in complete simulation runs, uncomment for simulation runs
#dist.freq<-c(0,10,50)

#Specify grazing frequency. If no grazing set to 0, if grazing on, set to 1, if both wanted set to c(0,1)
graz.freq<-c(1)

#Set grazing intensity, these correspond to the files in the STEPWAT_DIST folder 
#Default settings for testing rSFSTEP2, which represents a single grazing treatment
graz_intensity<-c("lowgraz")

#All grazing intensity options typically utilized in complete simulation runs, uncomment for simulation runs
#graz_intensity<-c("lowgraz","modgraz","highgraz")

#Set soil types, these correspond to the files in the STEPWAT_DIST folder 
#Default settings for testing rSFSTEP2, which represents a single soil treatment
soil.types<-c("soils.17sand.13clay")

#All soil options typically utilized in complete simulation runs, uncomment for simulation runs
#soil.types<-c("soils.17sand.13clay","soils.68sand.10clay")

#Source the wrapper script, run the STEPWAT2 code for each combination of disturbances, soils, species, and climate scenarios
source(wrapper.file)

################ End Wrapper Code ########################################################
#Stop timing for timing statistics
tick_off<-proc.time()-tick_on
print(tick_off)
