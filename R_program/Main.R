#The Burke-Lauenroth Laboratory 
#STEPWAT R Wrapper
#Main R Script for STEPWAT_R_WRAPPER

#Load Required Packages
library(DBI)
library(RSQLite)
library(rSOILWAT2)

stopifnot(utils::packageVersion("rSOILWAT2") >= "4.0.4")

#Load source files and directories in the environment
#Note: Change number of processors and output database location according to your system

#Number of cores
proc_count<-6

#Source directory, the source.directory will be filled in automatically when rSFSTEP2 runs
source.dir<-"nopath"
source.dir<-paste(source.dir,"/", sep="")
setwd(source.dir)

#Set database and inputs location, an example is provided
db_loc<-"/Users/Guest/Desktop/rSFSTEP2/inputs"

#Set number of simulation years used in STEPWAT2 simulations
simyears <- 300

# If you would like to rescale space parameters based on climate for each climate 
# scenario, set this boolean to TRUE. If you would like to run with only the space 
# parameters that you have specified in the input.csv, set this boolean to FALSE.
rescale_space <- TRUE

# If you would like to compare the generated RGroup.in files with the values specified
# in the input CSV set this boolean to TRUE.
output_original_space <- TRUE

# If you would like to rescale phenological activity, biomass, litter, and % live
# fractions based on climate for each climate scenario set this boolean to TRUE.
# If you would like to run with the default values, set this boolean to FALSE.
rescale_phenology <- TRUE

#Database location, edit the name of the weather database accordingly
database_name<-"dbWeatherData.VicSites.v3.2.0.sqlite3"
database<-file.path(db_loc,database_name)
 
#Weather query script (Loads weather data from the weather database for all climate scenarios into a list for each site)
query.file<-paste(source.dir,"WeatherQuery.R", sep="")

#Weather assembly script (Assembles weather data with respect to years and conditions)
assemble.file<-paste(source.dir,"WeatherAssembly.R", sep="")

#Markov script (Generates site-specific markov files used for weather generation in SOILWAT2)
markov.file<-paste(source.dir,"MarkovWeatherFileGenerator.R",sep="")

#Vegetation script (to estimate relative abundance of functional groups based on climate relationships)
vegetation.file <- file.path(source.dir, "Vegetation.R")

#Wrapper script (Executes STEPWAT2 for all climate-disturbance-input parameter combinations)
wrapper.file<-paste(source.dir,"CallSTEPWAT2.R", sep="")

#Output script (Combines individual output files into a master output file for each site)
output.file<-paste(source.dir,"AppendTreatments.R", sep="")

#Start timing for timing statistics
tick_on<-proc.time()

#rSFSTEP2 will automatically populate the site string with the sites specified in generate_stepwat_sites.sh
site<-c(notassigned)

#######################################################################################
#Set working directory to location with inputs
setwd(db_loc)

#Read in all input data
#species-specific parameters
species_data <- read.csv("InputData_Species.csv", header=TRUE, sep=",")

#soils properties for multiple soil layers
soil_data <- read.csv("InputData_SoilLayers.csv", header=TRUE, sep=",")

#functional type (rgroup) specific parameters
rgroup_data <- read.csv("InputData_Rgroup.csv", header=TRUE, sep=",")

#Set working directory to source directory
setwd(source.dir)

#SPECIES INPUTS
#Get all sites listed in the CSV
species_data_all_sites<-unique(species_data$Site)
#Get all sites for which fixed parameters for a subest of sites are specified
species_data_all_sites_vectors<-species_data_all_sites[grepl(",",species_data_all_sites)]

# Move to the dist directory, where we will write our .in files
setwd("STEPWAT_DIST")
treatments_vector_species <- c()
# This boolean will become TRUE if this site is includes in a list of comma separated sites in input. 
# Used to determine if any input was generated from the .csv files.
contains_vector <- FALSE

if(any(grepl(",",species_data_all_sites))==TRUE)
{
  #Iterate through each site that matches this criteria
  for(j in species_data_all_sites_vectors)
  {
  	site2=paste("\\<",site,"\\>",sep='')
  
    if(grepl(site2,j))
    {
      contains_vector <- TRUE
      species_data_site<-species_data[species_data$Site==j,]
      
      #List all treatments associated with the multiple sites
      treatments_vector_species<-unique(species_data_site$treatment)
      
      #Iterate through each treatment
      for(i in treatments_vector_species)
      {
        #Get data for the specific treatment
        df=species_data_site[species_data_site$treatment==i,]
        
        #Get rid of site and treatment columns
        df <- subset(df, select = -c(1,2))
        
        #Write the species.in file to the STEPWAT_DIST folder
        write.table(df, file = paste0("species_",i,".in"),quote = FALSE,row.names=FALSE,col.names = FALSE,sep="\t")
      }
    }
  }
}

#Get site-specific species parameters for the site or the fixed parameters used for "all" sites
species_data_site<-species_data[species_data$Site==site | species_data$Site=="all",]

#print a warning if there are no species inputs for this site.
if(nrow(species_data_site) == 0 & !contains_vector){
  print(paste("Site",site,"contains no species inputs.", sep = " "))
}

#Get all treatments associated with the site
treatments_species<-unique(species_data_site$treatment)

#Write a file for each treatment - the site-specific parameters and/or fixed parameters for "all" sites if requested
for(i in treatments_species)
{
  #Get data for a specific treatment
  df=species_data_site[species_data_site$treatment==i,]
  
  #Remove Site and treatment columns
  df <- subset(df, select = -c(1,2) )
  
  #Write the species.in file to the STEPWAT_DIST folder
  write.table(df, file = paste0("species_",i,".in"),quote=FALSE,row.names=FALSE,col.names = FALSE,sep="\t")
}

#Create file names for all site-treatment combinations
treatments_species<-as.character(treatments_species)
#Only paste in 'species_' if there is already a name present. Otherwise, if there are no treatments,
#we would generate a file called 'species__.in' which would crash the program.
if(length(treatments_species) > 0){
  treatments_species<-paste("species_",treatments_species,sep="")
}
treatments_vector_species<-as.character(treatments_vector_species)
#Only paste in 'species_' if there is already a name present. Otherwise, if there are no treatments,
#we would generate a file called 'species__.in' which would crash the program.
if(length(treatments_vector_species) > 0){
  treatments_vector_species <- paste("species_",treatments_vector_species, sep="")
}

#Store the files names in the species.filenames variable and all of the treatments-site combinations in species
species<-c(treatments_species,treatments_vector_species)
species.filenames<-paste(species,".in",sep="")

#Append species_template.in within STEPWAT_DIST to all the created files and save with a unique filename
for (i in species.filenames)
{
  system(paste("cat ","species_template.in>>",i,sep=""))
}

#######################################################################################
#SOILS INPUTS

#Get all sites specified in the csv
soil_data_all_sites<-unique(soil_data$Site)

#Get the subset of sites that will be run with a fixed set of inputs, denoted with x,y
soil_data_all_sites_vectors<-soil_data_all_sites[grepl(",",soil_data_all_sites)]

treatments_vector <- c()
# This boolean will become TRUE if this site is includes in a list of comma separated sites in input. 
# Used to determine if any input was generated from the .csv files.
contains_vector <- FALSE

#Generate a soils.in file for the site for the x,y option first
if(any(grepl(",",soil_data_all_sites))==TRUE)
{
  for(j in soil_data_all_sites_vectors)
  {
    site2=paste("\\<",site,"\\>",sep='')
    
    if(grepl(site2,j))
    {
      contains_vector <- TRUE
      #Subset the soils data for the site in question
      soil_data_site<-soil_data[soil_data$Site==j,]
     
      #Get all soil treatments for the site in question
      treatments_vector<-unique(soil_data_site$soil_treatment)
      
      #For each treatment for the site in question generate a soils.in file
      for(i in treatments_vector)
      {
        df=soil_data_site[soil_data_site$soil_treatment==i,]
        #Get rid of Site and treatment columns
        df <- subset(df, select = -c(1,2) )
        #Write the soils.in file to the STEPWAT_DIST folder
        write.table(df, file = paste0("soils_",i,".in"),row.names=FALSE,col.names = FALSE,sep="\t")
      }
    }
  }
}

#Get site-specific species parameters for the site or the fixed parameters used for "all" sites
soil_data_site<-soil_data[soil_data$Site==site | soil_data$Site=="all",]

#print a warning if there are no soil inputs for this site
if(nrow(soil_data_site) == 0 & !contains_vector){
  print(paste("Site",site,"contains no soil inputs.", sep = " "))
}

#Get all treatments pertaining to site or "all"
treatments<-unique(soil_data_site$soil_treatment)

#Write a file for each treatment - the site-specific parameters and/or fixed parameters for "all" sites if requested
for(i in treatments)
{
  #Get data for a specific treatment
  df=soil_data_site[soil_data_site$soil_treatment==i,]
  #Remove Site and treatment columns
  df <- subset(df, select = -c(1,2) )
  #Write the soils.in file to the STEPWAT_DIST folder
  write.table(df, file = paste0("soils_",i,".in"),row.names=FALSE,col.names = FALSE,sep="\t")
}

#Create file names for all site-treatment combinations
treatments<-as.character(treatments)
#Only paste in 'soils_' if there is already a name present. Otherwise, if there are no treatments,
#we would generate a file called 'soils__.in' which would crash the program.
if(length(treatments) > 0){
  treatments<-paste("soils_",treatments, sep="")
}
treatments_vector<-as.character(treatments_vector)
#Only paste in 'soils_' if there is already a name present. Otherwise, if there are no treatments,
#we would generate a file called 'soils__.in' which would crash the program.
if(length(treatments_vector) > 0){
  treatments_vector <- paste("soils_",treatments_vector, sep="")
}

#Store all of the treatment-site combinations in soil.types
soil.types<-c(treatments,treatments_vector)


#######################################################################################
#RGROUP INPUTS (including fire and grazing)

# The number of rgroups specified for each treatment in InputData_Rgroup.csv will be stored in this variable.
n_rgroups <- c()

#Get all sites specified in the csv
rgroup_data_all_sites<-unique(rgroup_data$Site)

#Get the subset of sites that will be run with a fixed set of inputs, denoted with x,y
rgroup_data_all_sites_vectors<-rgroup_data_all_sites[grepl(",",rgroup_data_all_sites)]

contains_vector <- FALSE
rgroups <- c()
space_values <- list()

#Generate a rgroup.in file for the site for the x,y option first
if(any(grepl(",",rgroup_data_all_sites))==TRUE)
{
  for(j in rgroup_data_all_sites_vectors)
  {
    site2=paste("\\<",site,"\\>",sep='')
    
    if(grepl(site2,j))
    {
      contains_vector <- TRUE
      #Subset the rgroup data for the site in question
      rgroup_data_site<-rgroup_data[rgroup_data$Site==j,]
      
      #Get all rgroup treatments for the site in question
      treatments_vector<-unique(rgroup_data_site$treatment)
      
      #For each treatment for the site in question generate a rgroup.in file
      for(i in treatments_vector)
      {
        df=rgroup_data_site[rgroup_data_site$treatment==i,]
        #Get rid of Site and treatment columns
        df <- subset(df, select = -c(1,2))
        
        # Record the number of entries (i.e. the number of RGroups) for later use
        n_rgroups <- c(n_rgroups, nrow(df))
        
        #Populate the dist.freq vector with fire frequency inputs
        temp<-df['Prescribed_killfreq']
        temp<-as.numeric(unique(temp))
        dist.freq.current<-temp
        
        #Populate the graz.freq vector with grazing frequency inputs
        temp<-df['grazing_frq']
        temp<-as.numeric(unique(temp))
        graz.freq.current<-temp
        
        #If grazing is ocurring we need to know the intensity.
        if(graz.freq.current != 0){
          #Populate the graz_intensity vector with grazing intensity inputs
          temp<-df['proportion_grazing']
          temp<-max(unique(temp))
        } else {
          temp="0"
        }
        graz_intensity.current<-temp
        
        # If any of the inputs contain a decimal like "0.24" this code will remove the "0." and leave the "24"
        # this is necessary for functionallity in wrapper.file
        dist.freq.current <- toString(dist.freq.current)
        graz.freq.current <- toString(graz.freq.current)
        graz_intensity.current <- toString(graz_intensity.current)
  
        dist.freq.current <- strsplit(dist.freq.current,"\\.")
        graz.freq.current <- strsplit(graz.freq.current,"\\.")
        graz_intensity.current <- strsplit(graz_intensity.current,"\\.")
        
        dist.freq.current <- dist.freq.current[[1]][length(dist.freq.current[[1]])]
        graz.freq.current <- graz.freq.current[[1]][length(graz.freq.current[[1]])]
        graz_intensity.current <- graz_intensity.current[[1]][length(graz_intensity.current[[1]])]
        
        # Now add the file name to the list of file names
        rgroups <- c(rgroups, paste0("rgroup.","freq.",dist.freq.current,".graz.",graz.freq.current,".",graz_intensity.current,".",i))
        
        space_values[[length(space_values) + 1]] <- df[ , 2]
        # Write the rgroup.in file to the STEPWAT_DIST folder
        write.table(df, file = paste0("rgroup.","freq.",dist.freq.current,".graz.",graz.freq.current,".",graz_intensity.current,".",i,".in"),quote=FALSE,row.names=FALSE,col.names = FALSE,sep="\t")
      }
    }
  }
}

#Get site-specific rgroup parameters for the site or the fixed parameters used for "all" sites
rgroup_data_site<-rgroup_data[rgroup_data$Site==site | rgroup_data$Site=="all",]

#print a warning if there are no rgroup inputs for this site
if(nrow(rgroup_data_site) == 0 & !contains_vector){
  print(paste("Site",site,"contains no rgroup inputs.", sep = " "))
}

#Get all treatments pertaining to site or "all"
treatments<-unique(rgroup_data_site$treatment)

#For each treatment for the site in question generate a rgroup.in file
for(i in treatments)
{
  df=rgroup_data_site[rgroup_data_site$treatment==i,]
  #Get rid of Site and treatment columns
  df <- subset(df, select = -c(1,2) )
  
  # Record the number of entries (i.e. the number of RGroups) for later use
  n_rgroups <- c(n_rgroups, nrow(df))
  
  #Populate the dist.freq vector with fire frequency inputs
  temp<-df['Prescribed_killfreq']
  temp<-as.numeric(unique(temp))
  dist.freq.current<-temp
  
  #Populate the graz.freq vector with grazing frequency inputs
  temp<-df['grazing_frq']
  temp<-as.numeric(unique(temp))
  graz.freq.current<-temp
  
  #If grazing is ocurring we need to know the intensity.
  if(graz.freq.current != 0){
    #Populate the graz_intensity vector with grazing intensity inputs
    temp<-df['proportion_grazing']
    temp<-max(unique(temp))
  } else {
    temp="0"
  }
  graz_intensity.current<-temp
  
  # If any of the inputs contain a decimal like "0.24" this code will remove the "0." and leave the "24"
  # this is necessary for functionallity in wrapper.file
  dist.freq.current <- toString(dist.freq.current)
  graz.freq.current <- toString(graz.freq.current)
  graz_intensity.current <- toString(graz_intensity.current)
  
  dist.freq.current <- strsplit(dist.freq.current,"\\.")
  graz.freq.current <- strsplit(graz.freq.current,"\\.")
  graz_intensity.current <- strsplit(graz_intensity.current,"\\.")
        
  dist.freq.current <- dist.freq.current[[1]][length(dist.freq.current[[1]])]
  graz.freq.current <- graz.freq.current[[1]][length(graz.freq.current[[1]])]
  graz_intensity.current <- graz_intensity.current[[1]][length(graz_intensity.current[[1]])]
        
  # Now add the file name to the list of file names
  rgroups <- c(rgroups, paste0("rgroup.","freq.",dist.freq.current,".graz.",graz.freq.current,".",graz_intensity.current,".",i))
  
  # Save the space values for outputting later
  space_values[[length(space_values) + 1]] <- df[ , 2]
  
  # Write the rgoup.in file to the STEPWAT_DIST directory
  write.table(df, file = paste0("rgroup.","freq.",dist.freq.current,".graz.",graz.freq.current,".",graz_intensity.current,".",i,".in"),quote=FALSE,row.names=FALSE,col.names = FALSE,sep="\t")
}

if(output_original_space){
  # Output the space values to a file. This will allow us to compare them to the rescaled space
  # parameters generated later in this file. For comparing files see compareFiles.R in STEPWAT_DIST.
  names(space_values) <- rgroups
  write.csv(space_values, file = "space_original_values.csv", row.names = FALSE)
}

# adding names to the vector will help us determine what climate scenario applies to what rgroup.in file
names(rgroups) <- rep_len("Inputs", length(rgroups))

#Store the files names in the rgroup_files variable
rgroup_files<-list.files(path=".",pattern = "rgroup")
rgroup_files<-rgroup_files[rgroup_files!="rgroup_template.in"]

#Append rgroup_template.in within STEPWAT_DIST to all the created files and save with a unique filename
for (i in rgroup_files)
{
  system(paste("cat ","rgroup_template.in >>",i,sep=""))
}

setwd("..")

########################### Garbage collection for species, rgroup, and soil requirements #######################
# All of these variables were created in the species, soils, and rgroup sections. They will never be used again.
# Removing them will defrag the memory enough to allow the program to complete on systems will smaller memory.
# For more info on memory problems in rSFSTEP2, see issue #76 on github.
# PROGRAMMER NOTE: If you add any aditional variables to the program, make sure you delete them as soon as they are
# no longer necessary.

# treatment vectors
remove(graz_intensity.current)
remove(dist.freq.current)
remove(graz.freq.current)
remove(contains_vector)
# variables related to rgroup
remove(space_values)
remove(rgroup_data_site)
remove(treatments)
remove(df)
remove(treatments_vector)
remove(rgroup_data)
remove(rgroup_data_all_sites)
remove(rgroup_data_all_sites_vectors)
remove(rgroup_files)
# variables related to soil
remove(soil_data)
remove(soil_data_all_sites)
remove(soil_data_all_sites_vectors)
remove(soil_data_site)
#variables related to species
remove(species_data_site)
remove(species_data_all_sites_vectors)
remove(species_data)
remove(treatments_vector_species)
remove(treatments_species)
remove(species.filenames)

################################ Weather Query Code ###################################

#Setup parameters for the weather aquisition (years, scenarios, timeperiod, GCMs) 
simstartyr <- 1979
endyr <- 2010
climate.ambient <- "Current"

#Specify the RCP/GCM combinations
climate.conditions <- c(climate.ambient,  "RCP45.CanESM2", "RCP45.CESM1-CAM5", "RCP45.CSIRO-Mk3-6-0", "RCP45.FGOALS-g2",
                        "RCP45.FGOALS-s2", "RCP45.GISS-E2-R", "RCP45.HadGEM2-CC", "RCP45.HadGEM2-ES", "RCP45.inmcm4", 
                        "RCP45.IPSL-CM5A-MR", "RCP45.MIROC5", "RCP45.MIROC-ESM","RCP45.MRI-CGCM3", "RCP85.CanESM2", 
                        "RCP85.CESM1-CAM5", "RCP85.CSIRO-Mk3-6-0", "RCP85.FGOALS-g2","RCP85.FGOALS-s2","RCP85.GISS-E2-R",
                        "RCP85.HadGEM2-CC","RCP85.HadGEM2-ES","RCP85.inmcm4","RCP85.IPSL-CM5A-MR","RCP85.MIROC5",
                        "RCP85.MIROC-ESM","RCP85.MRI-CGCM3")

###################### Derive GCM and RCP information from climate.conditions #######################
split <- strsplit(climate.conditions, "\\.")   # Split entries in climate.conditions on the period
GCM <- c(); RCP <- c()       # Create our RCP and GCM vectors

for(i in 1:length(split))    # For every GCM/RCP combination
{
  RCP[i] <- split[[i]][1]    # The first entry is the RCP
  GCM[i] <- split[[i]][2]    # The second entry is the GCM
}

GCM <- unique(GCM)           # Remove any duplicates. This shouldn't happen for GCMs, but just to be safe.
RCP <- unique(RCP)           # Remove any duplicates. This will most likely happen with RCPs.

RCP <- RCP[!grepl("Current", RCP)]   # Since "Current" doesn't contain a period, it will appear in RCP
GCM[is.na(GCM)] <- "Current"         # An NA value in GCM results from "Current" being parsed into RCP

# temp stores all climate conditions except climate.ambient
temp <- climate.conditions[!grepl(climate.ambient, climate.conditions)]

# If we are running future scenarios we need to append a downscaling method
if(length(temp) > 0){

  #use with Vic weather database and all new weather databases
  if(database_name!="dbWeatherData_Sagebrush_KP.v3.2.0.sqlite")
  {
    #Difference between start and end year(if you want 2030-2060 use 50; if you want 2070-2100 use 90 below)
    deltaFutureToSimStart_yr <- c("d50","d90")
    
    #Downscaling method
    downscaling.method <- c("hybrid-delta-3mod")
    temp <- paste0(deltaFutureToSimStart_yr, "yrs.", rep(temp, each=length(deltaFutureToSimStart_yr)))	#add (multiple) deltaFutureToSimStart_yr
    
    #Set Years
    YEARS<-c("d50yrs","d90yrs")
  }
  else
  {
    #Difference between start and end year(if you want 2030-2060 use 50; if you want 2070-2100 use 90 below)
    deltaFutureToSimStart_yr <- c(50,90)
   
    #Downscaling method
    downscaling.method <- c("hybrid-delta")
   
    temp <- paste0(deltaFutureToSimStart_yr, "years.", rep(temp, each=length(deltaFutureToSimStart_yr)))	#add (multiple) deltaFutureToSimStart_yr
    #Set Years
    #use with KP weather database
    YEARS<-c("50years","90years")
  }
  
  # prepend the downscaling method to all future conditions
  temp <- paste0(downscaling.method, ".", rep(temp, each=length(downscaling.method)))
}

climate.conditions <-  c("Current",temp)
temp<-c("Current",temp)


#Vector of sites, the code needs to be run on, this will be populated by rSFSTEP2
sites<-c(notassigned) 

#Source the code in query script
source(query.file)

# these variables are no longer needed
remove(query.file)
remove(database)
rm(split)

############################### End Weather Query Code ################################

############################### Weather Assembly Code #################################
#This script assembles the necessary weather data that was extracted during the weather query step

#Set output directories
weather.dir<-source.dir
setwd(weather.dir)
#Create a new folder called MarkovWeatherFiles in which to put the weather files and markov files
dir.create("MarkovWeatherFiles", showWarnings = FALSE)
assembly_output<-paste(source.dir,"MarkovWeatherFiles/",sep="")
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

#Source the code in assembly script
source(assemble.file)

############################### End Weather Assembly Code ################################

############################# MARKOV Weather Generator Code ##############################
#This code generates two site-specific files necessary for the Markov Weather Generator built into STEPWAT. mk_covar.in
#and mk_prob.in. These files are based on the weather data for each site that is extracted during the previous step.

#Change directory to output directory of assemble script
setwd(assembly_output)
# number of years 
yr<-30 

#Source the code in markov script
source(markov.file)

#These variables are no longer needed
remove(assemble.file)
remove(markov.file)
remove(temp)

############################# End MARKOV Weather Generator Code ##############################

############################# Phenology Code ###############################
# This code determines plant functional type phenology
# and then scales phenological activity, biomass, litter and % live accordingly
if(rescale_phenology){
  source(vegetation.file)
  setwd(db_loc)
  # Read the input CSV files
  phenology.default <- read.csv("InputData_Phenology.csv", header = TRUE, row.names = 1)
  biomass.default <- read.csv("InputData_Biomass.csv", header = TRUE, row.names = 1)
  biomass.default.max <- apply(biomass.default, 1, max)
  pctlive.default <- read.csv("InputData_PctLive.csv", header = TRUE, row.names = 1)
  pctlive.default.max <- apply(pctlive.default, 1, max)
  litter.default <- read.csv("InputData_Litter.csv", header = TRUE, row.names = 1)
  litter.default.max <- apply(litter.default, 1, max)
  monthly.temperature <- read.csv("InputData_MonthlyTemp.csv", header = TRUE, row.names = 1)
  
  # If you plan on comparing output files, this needs to be TRUE
  shouldOutputTemperature = TRUE
  
  # First call scales phenological activity based on current temperature
  scaled_phenology <- scale_phenology(list(phenology.default), sw_weatherList, 
                                   monthly.temperature, x_asif = NULL, site_latitude = 90, 
                                   outputTemperature = shouldOutputTemperature) 
  
  # condense the values we want to scale into a single list excluding phenology
  values_to_scale <- list(pctlive.default, litter.default, biomass.default)

  # Second call scales litter, biomass, and %live fractions based on phenological activity
  scaled_values <- scale_phenology(values_to_scale, sw_weatherList, 
                                   monthly.temperature, x_asif = phenology.default, site_latitude = 90, 
                                   outputTemperature = shouldOutputTemperature)
                                   
  # Move to the DIST directory so we can start writing the files.
  setwd(source.dir)
  setwd("STEPWAT_DIST")
  
  if(shouldOutputTemperature){
    # Format and write the temperature values for each climate scenario
    temperature_values <- scaled_values[[2]]
    temperature_values <- t(simplify2array(temperature_values))
    row.names(temperature_values) <- climate.conditions
    colnames(temperature_values) <- month.abb
    write.csv(file = "temperature.csv", temperature_values)
    
    # Remove temperature values from scaled_values and scaled_phenology, leaving only the phen, biomass,
    # litter, and pctlive values.
    scaled_values <- scaled_values[[1]]
    scaled_phenology <- scaled_phenology[[1]]

    remove(temperature_values)
  }
  
  for(scen in 1:length(climate.conditions)){
    # Pull the correct entry out of the scaled list.
    phenology <- scaled_phenology[[scen]][[1]]		
    pctlive <- scaled_values[[scen]][[1]]		
    litter <- scaled_values[[scen]][[2]]		
    biomass <- scaled_values[[scen]][[3]]
    
    # Determine max monthly pct live and litter for use in scaling below
    pctlive.max <- apply(pctlive, 1, max)
    litter.max <- apply(litter, 1, max) 	

    # Normalize each row of pctlive so the max pctlive of values read from inputs is retained
    # in the derived values. 
    for(thisRow in 1:nrow(pctlive)){
      pctlive[thisRow, ] <- pctlive[thisRow, ] * (pctlive.default.max[thisRow] / pctlive.max[thisRow])
      # Make sure no values exceed 1
      pctlive[thisRow, ] <- pmin(pctlive[thisRow, ], 1)
    }
    
    # Normalize each row of litter so the max pctlive of values read from inputs is retained
    # in the derived values.
    for(thisRow in 1:nrow(litter)){
      litter[thisRow, ] <- litter[thisRow, ] * (litter.default.max[thisRow] / litter.max[thisRow])
      # Make sure no values exceed 1
      litter[thisRow, ] <- pmin(litter[thisRow, ], 1)
    }
    
    # Normalize each row of biomass so that the frequency of months with biomass < max(default biomass) is the     
   	# same as months with default biomass < max(default biomass)
    for(thisRow in 1:nrow(biomass)){
      # Number of peak default biomass months
      nmax <- max(1, 12 - sum(biomass.default[thisRow, ] < biomass.default.max[thisRow]))
      
      # Un-scaled minimum value of peak biomass months
  	  ids <- order(biomass[thisRow,], decreasing = TRUE)[seq_len(nmax)]
 	  pmin <- min(biomass[thisRow, ids])
 	
      # Scale values to maintain the number of peak biomass months
  	  biomass[thisRow,] <- biomass[thisRow,] *  biomass.default.max[thisRow] / pmin
      
      # Make sure no values exceed 1
      biomass[thisRow, ] <- pmin(biomass[thisRow, ], 1)
    }
    
    # Round so we don't output scientific notation
    phenology <- round(phenology, 9)
    pctlive <- round(pctlive, 9)
    litter <- round(litter, 9)
    biomass <- round(biomass, 9)
    
    sxwprod_v2_file <- paste0("sxwprod_v2.", climate.conditions[scen], ".in")
    sxwphen_file <- paste0("sxwphen.", climate.conditions[scen], ".in")
    
    # Write the phenology table
    write.table(phenology, sxwphen_file, append = FALSE, col.names = FALSE, row.names = TRUE, quote = FALSE, sep = "\t")
    # Write the prod table
    write.table(litter, sxwprod_v2_file, append = FALSE, col.names = FALSE, row.names = TRUE, quote = FALSE, sep = "\t")
    write.table("\n[end]\n", sxwprod_v2_file, append = TRUE, col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "")
    write.table(biomass, sxwprod_v2_file, append = TRUE, col.names = FALSE, row.names = TRUE, quote = FALSE, sep = "\t")
    write.table("\n[end]\n", sxwprod_v2_file, append = TRUE, col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "")
    write.table(pctlive, sxwprod_v2_file, append = TRUE, col.names = FALSE, row.names = TRUE, quote = FALSE, sep = "\t")
    write.table("\n[end]\n", sxwprod_v2_file, append = TRUE, col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "")
  }
  
  # Remove objects that are no longer needed
  remove(litter, litter.default, phenology, phenology.default, biomass, biomass.default, biomass.default.max,
  nmax, ids, pmin, pctlive, pctlive.default, values_to_scale, scaled_values, scaled_phenology, monthly.temperature, 
  sxwphen_file, sxwprod_v2_file, thisRow, shouldOutputTemperature, litter.max, litter.default.max, pctlive.max, pctlive.default.max)
  
}

############################# Vegetation Code ##############################
# only rescale space if requested.
if(rescale_space){
  # This code determines plant functional type relative abundance
  # and then scales STEPWAT2 parameters accordingly
  source(vegetation.file)
  
  # Move to the DIST directory so we can read the files.
  setwd(source.dir)
  setwd("STEPWAT_DIST")

  # Array of plant functional type relative abundance
  relVegAbund <- estimate_STEPWAT_relativeVegAbundance(sw_weatherList)

  # vectors that map rgroup names to the columns names of relVegAbund
  Shrubs <- c("sagebrush", "shrub")
  Forbs <- c("a.cool.forb","a.warm.forb", "p.cool.forb", "p.warm.forb")
  Succulents <- c("succulents")
  Grasses_C3 <- c("p.cool.grass")
  Grasses_C4 <- c("p.warm.grass")
  Grasses_Annuals <- c("a.cool.grass")
  Trees <- c()

  # will store the new rgroup files temporarily
  new_rgroup_files <- c()

  file_number <- 0
  # Loop through all of the rgroup files defined in inputs
  for(rg in rgroups){
    file_number <- file_number + 1
    
    #read the start of the file (where space is defined). n_rgroups[file_number] is the number of rgroups that were read in when creating
    #this specific rgroup file (the file denoted by "rg").
    rgrp <- readLines(con <- paste0(rg,".in"), n_rgroups[file_number])
    
    # split the file along tabs. This produces a 2d array of entries where rows are lines of the original file
    # and columns are the entries of each line
    rgrp <- strsplit(rgrp, "\t")
    
    # These vectors store the space parameters already in the rgroup file.
    # They are needed in case one SOILWAT2 functional type is represented by more than one STEPWAT2 functional group.
    shrub_space <- c(); forb_space <- c(); succulent_space <- c(); c3_space <- c()
    c4_space <- c(); annuals_space <- c(); tree_space <- c()
  
    # Loop through each line from rgroup.in file
    for(l in 1:length(rgrp)){
      # add the space parameters of each line to the vector of their corresponding functional type.
      if(is.element(rgrp[[l]][1], Shrubs)){ # if this rgroup is a shrub
        shrub_space <- c(shrub_space, as.numeric(rgrp[[l]][2])) #add this entry to the shrubs
      } else if(is.element(rgrp[[l]][1], Forbs)){ # if this rgroup is a forb
        forb_space <- c(forb_space, as.numeric(rgrp[[l]][2])) #add this entry to the forbs
      } else if(is.element(rgrp[[l]][1], Succulents)){ # if this rgroup is a succulent
        succulent_space <- c(succulent_space, as.numeric(rgrp[[l]][2])) #add this entry to the succulents
      } else if(is.element(rgrp[[l]][1], Grasses_C3)){ # if this rgroup is a c3 grass
        c3_space <- c(c3_space, as.numeric(rgrp[[l]][2])) #add this entry to the c3 grasses
      } else if(is.element(rgrp[[l]][1], Grasses_C4)){ # if this rgroup is a c4 grass
        c4_space <- c(c4_space, as.numeric(rgrp[[l]][2])) #add this entry to the c4 grasses
      } else if(is.element(rgrp[[l]][1], Grasses_Annuals)){ # if this rgroup is an annual grass
        annuals_space <- c(annuals_space, as.numeric(rgrp[[l]][2])) #add this entry to the annual grasses
      } else if(is.element(rgrp[[l]][1], Trees)){ # if this rgroup is a tree
        tree_space <- c(tree_space, as.numeric(rgrp[[l]][2])) #add this entry to the trees
      }
    }
  
    # loop through each site
    for(i in 1:length(relVegAbund[,1,1])){
      # make a data frame, which is easier to work with
      total_space <- data.frame(relVegAbund[i,,])
      
      # If there is only one entry in climate.conditions data.frame(relVegAbund)
      # will behave differently than if climate.conditions contains more than 1.
      # The following block accounts for this.
      if(length(climate.conditions) == 1){
        total_space <- data.frame(t(total_space))
      }
    
      #for every set of space parameters generated by climate:
      for(j in 1:nrow(total_space)){
        # If there is one entry in rgroup.in for the given functional type, this will do nothing.
        # if there are two or more entries for one functional type this equation will use the 
        # space defined in inputs to partition the new space values proportionally to each rgroup.
        temp_shrubs <- total_space$Shrubs[j] * shrub_space / sum(shrub_space)
        temp_forb <- total_space$Forbs[j] * forb_space / sum(forb_space)
        temp_succulent <- total_space$Succulents[j] * succulent_space / sum(succulent_space)
        temp_c3 <- total_space$Grasses_C3[j] * c3_space / sum(c3_space)
        temp_c4 <- total_space$Grasses_C4[j] * c4_space / sum(c4_space)
        temp_annuals <- total_space$Grasses_Annuals[j] * annuals_space / sum(annuals_space)
        temp_trees <- total_space$Trees[j] * tree_space / sum(tree_space)
      
        #for each line of the rgroup.in file
        for(l in 1:length(rgrp)){
          # replace the old space parameters with the new values. NOTE: the order of the vectors matters. If there are two shrubs defined
          # temp_shrubs[1] is the first entry and temp_shrubs[2] is the second entry.
          if(is.element(rgrp[[l]][1], Shrubs)){ # if this rgroup is a shrub
            rgrp[[l]][2] <- temp_shrubs[1] # Replace with new space parameter.
            temp_shrubs <- temp_shrubs[2:length(temp_shrubs)] #remove the used entry from the temp vector.
          } else if(is.element(rgrp[[l]][1], Forbs)){ # if this rgroup is a forb
            rgrp[[l]][2] <- temp_forb[1] # Replace with new space parameter.
            temp_forb <- temp_forb[2:length(temp_forb)] #remove the used entry from the temp vector.
          } else if(is.element(rgrp[[l]][1], Succulents)){ # if this rgroup is a succulent
            rgrp[[l]][2] <- temp_succulent[1] # Replace with new space parameter.
            temp_succulent <- temp_succulent[2:length(temp_succulent)] 
          } else if(is.element(rgrp[[l]][1], Grasses_C3)){ # if this rgroup is a c3 grass
            rgrp[[l]][2] <- temp_c3[1] # Replace with new space parameter.
            temp_c3 <- temp_c3[2:length(temp_c3)] #remove the used entry from the temp vector.
          } else if(is.element(rgrp[[l]][1], Grasses_C4)){ # if this rgroup is a c4 grass
            rgrp[[l]][2] <- temp_c4[1] # Replace with new space parameter.
            temp_c4 <- temp_c4[2:length(temp_c4)] #remove the used entry from the temp vector.
          } else if(is.element(rgrp[[l]][1], Grasses_Annuals)){ # if this rgroup is an annual grass
            rgrp[[l]][2] <- temp_annuals[1] # Replace with new space parameter.
            temp_annuals <- temp_annuals[2:length(temp_annuals)] #remove the used entry from the temp vector.
          } else if(is.element(rgrp[[l]][1], Trees)){ # if this rgroup is a tree
            rgrp[[l]][2] <- temp_trees[1] # Replace with new space parameter.
            temp_trees <- temp_trees[2:length(temp_trees)] #remove the used entry from the temp vector.
          }
        }
      
        # the new rgroup file is now stored in a 2d array. We need to stitch back together the entries, 
        # with tabs between columns and newline characters between rows
        readjusted_space <- ""
        for(y in 1:length(rgrp)){
          #if space is greater than 0 we need to make sure the rgroup is turned on. Otherwise it should be off.
          rgrp[[y]][9] <- if (rgrp[[y]][2] > 0) 1L else 0L  #rgrp[[y]][9] is the on/off column
          
          readjusted_space <- paste0(readjusted_space, rgrp[[y]][1])
          for(x in 2:length(rgrp[[1]])){
            readjusted_space <- paste0(readjusted_space, "\t", rgrp[[y]][x])
          }
          readjusted_space <- paste0(readjusted_space, "\n")
        }
      
        # create the new file, using the old file's name with ".readjustedj" appended on the end.
        newFileName <- paste0(rg,".",climate.conditions[j])
        # give this file an identifier that will be used to determine under what climate scenario it should be run.
        names(newFileName) <- climate.conditions[j]
        writeLines(readjusted_space, paste0(newFileName, ".in"), sep = "")
        # concatinate the template to the new file.
        system(paste("cat ","rgroup_template.in >>", paste0(newFileName, ".in"),sep=""))
      
        new_rgroup_files <- c(new_rgroup_files, newFileName)
      }
    }
    
    #now that we have readjusted space, we can remove the original file.
    system(paste0("rm ", rg, ".in"))
  }
  
  #replace rgroup files with the new readjusted files
  rgroups <- new_rgroup_files
  
  # Remove all of the variables created in this section.
  remove(Shrubs)
  remove(Forbs)
  remove(Succulents)
  remove(Grasses_C3)
  remove(Grasses_C4)
  remove(Grasses_Annuals)
  remove(Trees)
  remove(shrub_space)
  remove(forb_space)
  remove(succulent_space)
  remove(c3_space)
  remove(c4_space)
  remove(annuals_space)
  remove(tree_space)
  remove(new_rgroup_files)
  remove(rgrp)
  remove(temp_shrubs)
  remove(temp_forb)
  remove(temp_succulent)
  remove(temp_c3)
  remove(temp_c4)
  remove(temp_annuals)
  remove(temp_trees)
  remove(readjusted_space)
} # end if(rescale_space)

############### Run Wrapper Code ############################################################

########### Set parameters ###############################################

#This will be populated by rSFSTEP2
site<-c(sitefolderid)

#Directory stores working directory
directory<-source.dir

#Disturbance folder
dist.directory<-paste(source.dir,"STEPWAT_DIST/",sep="")

#Source the code in wrapper script, run the STEPWAT2 code for each combination of disturbances, soils, climate scenarios
source(wrapper.file)

################ End Wrapper Code ########################################################
#Stop timing for timing statistics
tick_off<-proc.time()-tick_on
print(tick_off)
