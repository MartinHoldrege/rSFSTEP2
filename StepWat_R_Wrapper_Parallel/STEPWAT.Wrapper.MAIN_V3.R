#The Burke-Lauenroth Laboratory 
#STEPWAT R Wrapper
#Main R Script for STEPWAT_R_WRAPPER

#Load Required Packages
library(DBI)
library(RSQLite)
library(mail)
library(sendmailR)
library(rSOILWAT2)

#Load source files and directories in the environment
#Note: Change number of processors and output database location according to your system

#Number of cores
proc_count<-6

#Enter email id for timing statistics, add your email below in "" and uncomment out if you want to use
#emailid<-""

#Source directory, the source.directory will be filled in automatically when rSFSTEP2 runs
source.dir<-"nopath"
source.dir<-paste(source.dir,"/", sep="")
setwd(source.dir)

#Set database location
db_loc<-""

#Database location, edit the name of the weather database accordingly
database<-file.path(db_loc,"dbWeatherData_Sagebrush_KP.sqlite")
 
#Query script (Loads data from the database into a list)
query.file<-paste(source.dir,"RSoilWat31.Weather.Data.Query_V2.R", sep="")

#Assembly script (Assemble data with respect to years and conditions)
assemble.file<-paste(source.dir,"Weather.Assembly.Choices_V2.R", sep="")

#Markov script (To generate cov and prob files)
markov.file<-paste(source.dir,"Markov.Weather_V2.R",sep="")

#Wrapper script
wrapper.file<-paste(source.dir,"StepWat.Wrapper.Code_V3.R", sep="")

#Output script
output.file<-paste(source.dir,"SoilWatOutput.R", sep="")

#Start timing for timing statistics
tick_on<-proc.time()

#rSFSTEP2 will automatically populate the site string with the sites specified in generate_stepwat_sites.sh
site<-c(sitefolderid)#,2,3,4,5,6,7,8,9,10)

#This code is used in the circumstance when you want to use different species.in parameters for different sites
#In this case, we have three different species.in files which are found in the STEPWAT_DIST folder. The below strings
#correspond to which sites we want to use each species.in file for. 
species1<-c(21,80,144,150,244,291,374,409,411,542,320,384,391,413,501,592,687,733,758,761,781,787,798,816,824,828,866,868,869,876,879)
species2<-c(609,676,729,730,778,792,809,818,826,829,854,857,862)
species3<-c(163,211,221,230,264,283,341,354,365,380,387,497,524,543,566,581,608,175,178,217,319,335,369,498,595,659,4,7,14,15,23,79)
species<-"species"

#######################################################################################
#KS: Source site soil requirements from a csv
soil_data <- read.csv("InputData_SoilLayers.csv", header=TRUE, sep=",")
soil_data_site<-soil_data[soil_data$Site==1,]
treatments<-unique(soil_data_site$soil_treatment)

setwd("STEPWAT_DIST")

for(i in treatments)
{
  df=soil_data_site[soil_data_site$soil_treatment==i,]
  df <- subset(df, select = -c(1,2) )
  write.table(df, file = paste0(i,".in"),row.names=FALSE,col.names = FALSE,sep="\t")
}

treatments<-as.character(treatments)

#Soil types are specified here, in accordance with the files added to STEPWAT_DIST folder
soil.types<-treatments#c("soils.17sand.13clay","soils.68sand.10clay") #KS: uncommented to test overhaul of inputs

################################ Weather Query Code ###################################

setwd(source.dir)

#Setup parameters for the weather aquisition (years, scenarios, timeperiod, GCMs) 
simstartyr <- 1979
endyr <- 2010
climate.ambient <- "Current"

#Specify the RCP/GCM combinations
climate.conditions <- c(climate.ambient,  "RCP45.CanESM2", "RCP45.CESM1-CAM5", "RCP45.CSIRO-Mk3-6-0", "RCP45.FGOALS-g2", "RCP45.FGOALS-s2", "RCP45.GISS-E2-R", "RCP45.HadGEM2-CC", "RCP45.HadGEM2-ES",
                        "RCP45.inmcm4", "RCP45.IPSL-CM5A-MR", "RCP45.MIROC5", "RCP45.MIROC-ESM","RCP45.MRI-CGCM3", "RCP85.CanESM2", "RCP85.CESM1-CAM5", "RCP85.CSIRO-Mk3-6-0", "RCP85.FGOALS-g2","RCP85.FGOALS-s2","RCP85.GISS-E2-R","RCP85.HadGEM2-CC","RCP85.HadGEM2-ES","RCP85.inmcm4","RCP85.IPSL-CM5A-MR","RCP85.MIROC5","RCP85.MIROC-ESM","RCP85.MRI-CGCM3")

#Difference between start and end year(if you want 2030-2060 use 50; if you want 2070-2100 use 90 below)
#use with Vic weather database and all new weather databases
deltaFutureToSimStart_yr <- c("d50","d90")
#use with KP weather database
#deltaFutureToSimStart_yr <- c(50,90)

#Downscaling method
#use with Vic weather database and all new weather databases
downscaling.method <- c("hybrid-delta-3mod")
#use with KP weather database
#downscaling.method <- c("hybrid-delta")

#Store climate conditons
#List of all future and current scenarios putting "Current" first	
temp <- climate.conditions[!grepl(climate.ambient, climate.conditions)] #make sure 'climate.ambient' is first entry
if(length(temp) > 0){
#use with Vic weather database and all new weather databases
temp <- paste0(deltaFutureToSimStart_yr, "yrs.", rep(temp, each=length(deltaFutureToSimStart_yr)))	#add (multiple) deltaFutureToSimStart_yr
#use with KP weather database
#temp <- paste0(deltaFutureToSimStart_yr, "years.", rep(temp, each=length(deltaFutureToSimStart_yr)))	#add (multiple) deltaFutureToSimStart_yr

temp <- paste0(downscaling.method, ".", rep(temp, each=length(downscaling.method))) #add (multiple) downscaling.method
}

climate.conditions <-  c("Current",temp)
temp<-c("Current",temp)

#Vector of sites, the code needs to be run on, this will be populated by rSFSTEP2
sites<-c(notassigned) 

#Source the code in query script
source(query.file)

############################### End Weather Query Code ################################

############################### Weather Assembly Code #################################

#This script assembles the necessary weather data that was extracted during the weather query step
site<-c(sitefolderid)
#Set output directories
weather.dir<-source.dir
setwd(weather.dir)
#Create a new folder called StepWat.Weather.Markov.Test in which to put the weather files and markov files
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
#Set Type
#TYPE="basic" is for both basic and markov. TYPE="markov" is for only markov.
TYPE<-"basic"

#Source the code in assembly script
source(assemble.file)

############################### End Weather Assembly Code ################################

############################# MARKOV Weather Generator Code ##############################
#This code generates two site-specific files necessary for the Markov Weather Generator built into STEPWAT. mk_covar.in
#and mk_prob.in. These files are based on the weather data for each site that is extracted during the previous step.
site<-c(sitefolderid)#,2,3,4,5,6,7,8,9,10) 

#Change directory to output directory of assemble script
setwd(assembly_output)
# number of years 
yr<-30 

#Source the code in markov script
source(markov.file)

############################# End MARKOV Weather Generator Code ##############################

############### Run Wrapper Code ############################################################

########### Set parameters ###############################################

#This code is utilized if you want to use different species parameters for different sites
if(is.element(sites,species1))
{
    species<-"species1.in"
} else if (is.element(sites,species2)) {
    species<-"species2.in"
} else {	species<-"species3.in" }

#This will be populated by rSFSTEP2
site<-c(sitefolderid)#,2,3,4,5,6,7,8,9,10) 

#Directory stores working directory
directory<-source.dir

#Set GCMs
GCM<-c("Current","CanESM2","CESM1-CAM5","CSIRO-Mk3-6-0","FGOALS-g2","FGOALS-s2","GISS-E2-R","HadGEM2-CC","HadGEM2-ES","inmcm4", "IPSL-CM5A-MR", "MIROC5", "MIROC-ESM", "MRI-CGCM3")
#Set RCPs
RCP<-c("RCP45","RCP85")
#Set Years
#use with Vic weather database and all new weather databases
YEARS<-c("d50yrs","d90yrs")
#use with KP weather database
#YEARS<-c("50years","90years")

#Disturbance Flag, turn to "F" if not using disturbances (grazing,fire)
dist.graz.flag<-T
#Disturbance folder
dist.directory<-paste(source.dir,"STEPWAT_DIST/",sep="")

#Specify fire return interval
dist.freq<-c(0,10,50) # if not using disturbance but are using grazing set 'dist.freq<-0'

#Specify grazing frequency, if not use grazing set to 0, if grazing on, set to 1, if both wanted set to c(0,1)
graz.freq<-c(1)

#Set grazing intensity, these correspond to the file options in the STEPWAT_DIST folder 
graz_intensity<-c("lowgraz","modgraz","highgraz")

#Source the code in wrapper script, run the STEPWAT2 code for each combination of disturbances, soils, climate scenarios
source(wrapper.file)

################ End Wrapper Code ########################################################
#Stop timing for timing statistics
tick_off<-proc.time()-tick_on
print(tick_off)
