############## Locate all rgroup.in files ##############
rgroup.files <- list.files(".", pattern = "rgroup")
############### Remove the template file ###############
rgroup.files <- rgroup.files[!grepl(rgroup.files, pattern = "rgroup_template.in")]

############ Lists to hold all input types #############
all.group.parameters <- list()
resource.availibility <- list()
wet.dry.modifiers <- list()
wildfire <- list()

################ Loop through all input files so we can parse them #################
for(index in 1:length(rgroup.files)){
  ####################### Read an RGroup file ###########################
  rgroup_data <- read.table(rgroup.files[index], fill = TRUE)
  
  # Line will keep track of our location in the file. This is necessary because R
  # cannot handle the "[end]" delimiter we use in STEPWAT files.
  line <- 1
  
  ########## Read the first table (all group parameters like space) ###########
  all.group.parameters[[index]] <- list()
  while(rgroup_data[line,1] != "[end]"){
    this.line <- as.numeric(sapply(rgroup_data[line, 2:length(rgroup_data[line,])], as.character))
    all.group.parameters[[index]][[line]] <- this.line[!is.na(this.line)]
    line <- line + 1
  }
  last.end <- line  # Remember where we found the "[end]" delimiter
  
  ############## Read the second table (resource availibility) ################
  resource.availibility[[index]] <- list()
  line <- line + 1
  while(rgroup_data[line,1] != "[end]"){
    this.line <- as.numeric(sapply(rgroup_data[line, 2:length(rgroup_data[line,])], as.character))
    resource.availibility[[index]][[line - last.end]] <- this.line[!is.na(this.line)]
    line <- line + 1
  }
  last.end <- line  # Remember where we found the "[end]" delimiter
  
  ########## Read the third table (wet-dry modifiers for succulents) ##########
  wet.dry.modifiers[[index]] <- list()
  line <- line + 1
  while(rgroup_data[line,1] != "[end]"){
    this.line <- as.numeric(sapply(rgroup_data[line, 2:length(rgroup_data[line,])], as.character))
    wet.dry.modifiers[[index]][[line - last.end]] <- this.line[!is.na(this.line)]
    line <- line + 1
  }
  last.end <- line  # Remember where we found the "[end]" delimiter
  
  ######## Read the fourth table (cheatgrass driven wildfire parameters) #######
  wildfire[[index]] <- list()
  line <- line + 1
  while(rgroup_data[line,1] != "[end]"){
    this.line <-  as.numeric(sapply(rgroup_data[line, ], as.character))
    wildfire[[index]][[line - last.end]] <- this.line[!is.na(this.line)]
    line <- line + 1
  }
}

#################### Compress our lists of lists of vectors into 3d arrays ##################
for(i in 1:length(resource.availibility)){
  resource.availibility[[i]] <- matrix(unlist(resource.availibility[[i]]), nrow = length(resource.availibility[[i]]), byrow = TRUE)
}
resource.availibility <- simplify2array(resource.availibility)

for(i in 1:length(all.group.parameters)){
  all.group.parameters[[i]] <- matrix(unlist(all.group.parameters[[i]]), nrow = length(all.group.parameters[[i]]), byrow = TRUE)
}
all.group.parameters <- simplify2array(all.group.parameters)

for(i in 1:length(wet.dry.modifiers)){
  wet.dry.modifiers[[i]] <- matrix(unlist(wet.dry.modifiers[[i]]), nrow = length(wet.dry.modifiers[[i]]), byrow = TRUE)
}
wet.dry.modifiers <- simplify2array(wet.dry.modifiers)

###### Wildfire can become a 2d matrix because we are guaranteed only one row per input file ######
wildfire <- matrix(unlist(wildfire), nrow = length(wildfire), byrow = TRUE)

########################### Collect Statistics ####################################

######## All group parameters #########
all.group.stats <- array(dim = c(length(all.group.parameters[ , 1, 1]), length(all.group.parameters[1, , 1]) * 3))
colnames(all.group.stats) <- rep(c("minimum", "maximum", "std"), length(all.group.parameters[1, , 1]))
for(row in 1:length(all.group.parameters[ , 1, 1])){
  for(col in 1:length(all.group.parameters[1, , 1])){
    all.group.stats[row, col * 3 - 2] <- round(min(all.group.parameters[row, col, ]), 5)
    all.group.stats[row, col * 3 - 1] <- round(max(all.group.parameters[row, col, ]), 5)
    all.group.stats[row, col * 3] <- round(sd(all.group.parameters[row, col, ]), 5)
  }
}

######## Resource availibility ########
resource.availibility.stats <- array(dim = c(length(resource.availibility[ , 1, 1]), length(resource.availibility[1, , 1]) * 3))
colnames(resource.availibility.stats) <- rep(c("minimum", "maximum", "std"), length(resource.availibility[1, , 1]))
for(row in 1:length(resource.availibility[ , 1, 1])){
  for(col in 1:length(resource.availibility[1, , 1])){
    resource.availibility.stats[row, col * 3 - 2] <- round(min(resource.availibility[row, col, ]), 5)
    resource.availibility.stats[row, col * 3 - 1] <- round(max(resource.availibility[row, col, ]), 5)
    resource.availibility.stats[row, col * 3] <- round(sd(resource.availibility[row, col, ]), 5)
  }
}

######### Wet-dry parameters ##########
wet.dry.stats <- array(dim = c(length(wet.dry.modifiers[ , 1, 1]), length(wet.dry.modifiers[1, , 1]) * 3))
colnames(wet.dry.stats) <- rep(c("minimum", "maximum", "std"), length(wet.dry.modifiers[1, , 1]))
for(row in 1:length(wet.dry.modifiers[ , 1, 1])){
  for(col in 1:length(wet.dry.modifiers[1, , 1])){
    wet.dry.stats[row, col * 3 - 2] <- round(min(wet.dry.modifiers[row, col, ]), 5)
    wet.dry.stats[row, col * 3 - 1] <- round(max(wet.dry.modifiers[row, col, ]), 5)
    wet.dry.stats[row, col * 3] <- round(sd(wet.dry.modifiers[row, col, ]), 5)
  }
}

############## Wildfire ###############
wildfire.stats <- array(dim = c(1, ncol(wildfire) * 3))
colnames(wildfire.stats) <- rep(c("minimum", "maximum", "std"), ncol(wildfire))
for(col in 1:ncol(wildfire)){
  wildfire.stats[1, col * 3 - 2] <- round(min(wildfire[ , col]), 5)
  wildfire.stats[1, col * 3 - 1] <- round(max(wildfire[ , col]), 5)
  wildfire.stats[1, col * 3] <- round(sd(wildfire[ , col]), 5)
}

############################### Write output files ################################
system("mkdir output")
write.csv(all.group.stats, "output/all_group_parameters.csv")
write.csv(resource.availibility.stats, "output/resource_availibility_parameters.csv")
write.csv(wet.dry.stats, "output/wet_dry_parameters.csv")
write.csv(wildfire.stats, "output/wildfire_parameters.csv")