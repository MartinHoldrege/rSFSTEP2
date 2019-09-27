rgroup.files <- list.files(".", pattern = "rgroup")
rgroup.files <- rgroup.files[!grepl(rgroup.files, pattern = "rgroup_template.in")]

all.group.parameters <- list()
resource.availibility <- list()
wet.dry.modifiers <- list()
wildfire <- list()

for(index in 1:length(rgroup.files)){
  rgroup_data <- read.table(rgroup.files[index], fill = TRUE)
  
  ########## Divide the data into the tables separated by "[end]" #######
  all.group.parameters[[index]] <- list()
  line <- 1
  while(rgroup_data[line,1] != "[end]"){
    this.line <- rgroup_data[line, ]
    all.group.parameters[[index]][[line]] <- this.line[!is.na(this.line)]
    line <- line + 1
  }
  last.end <- line
  
  resource.availibility[[index]] <- list()
  line <- line + 1
  while(rgroup_data[line,1] != "[end]"){
    this.line <- rgroup_data[line, ]
    resource.availibility[[index]][[line - last.end]] <- this.line[!is.na(this.line)]
    line <- line + 1
  }
  last.end <- line
  
  wet.dry.modifiers[[index]] <- list()
  line <- line + 1
  while(rgroup_data[line,1] != "[end]"){
    this.line <- rgroup_data[line, ]
    wet.dry.modifiers[[index]][[line - last.end]] <- this.line[!is.na(this.line)]
    line <- line + 1
  }
  last.end <- line
  
  wildfire[[index]] <- list()
  line <- line + 1
  while(rgroup_data[line,1] != "[end]"){
    this.line <- rgroup_data[line, ]
    wildfire[[index]][[line - last.end]] <- this.line[!is.na(this.line)]
    line <- line + 1
  }
}

