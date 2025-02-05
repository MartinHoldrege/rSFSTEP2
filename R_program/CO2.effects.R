# Derive functional type specific bvt based on CO2-biomass relationships and mean CO2 (ppm) of each RCP-time period scenario
# set default bvt values to scale from inputs
default.bvt=rgroup_data[,c("Site","name","transpiration")]

# determine the number of unique RCP-YEARS combinations to derive bvt for
n_rcp_years <- length(co2_data$RCP)

# create unique list of RCP_YEARS combinations specified in inputs
unique.rcp.years <- do.call(paste, c(co2_data[,3:2], sep = "."))

# set up a results container for bvt for each RCP-YEARS combination
bvt.denom <- data.frame(matrix(ncol=n_rcp_years,nrow=length(rgroup_data$name)))
colnames(bvt.denom)=c(unique.rcp.years)
rownames(bvt.denom)=rgroup_data$name

# derive bvt for each plant functional type based on the corresponding C3 species and C4 species equations below
# and based for each RCP-YEARS combination
# equation for C3 species y = 0.07967256x ^ 0.42793
# equation for C4 species y = 0.2735612x ^ 0.21917
for(i in 1:length(unique.rcp.years)){
  bvt.denom[1,i] = default.bvt[1,3]/(0.07967256 *co2_data$CO2[i] ^ 0.42793)
  bvt.denom[2,i] = default.bvt[2,3]/(0.07967256 *co2_data$CO2[i] ^ 0.42793)
  bvt.denom[3,i] = default.bvt[3,3]/(0.07967256 *co2_data$CO2[i] ^ 0.42793)
  bvt.denom[4,i] = default.bvt[4,3]/(0.07967256 *co2_data$CO2[i] ^ 0.42793)
  bvt.denom[5,i] = default.bvt[5,3]/(0.07967256 *co2_data$CO2[i] ^ 0.42793)
  bvt.denom[6,i] = default.bvt[6,3]/(0.07967256 *co2_data$CO2[i] ^ 0.42793)
  bvt.denom[7,i] = default.bvt[7,3]/(0.07967256 *co2_data$CO2[i] ^ 0.42793)
  bvt.denom[8,i] = default.bvt[8,3]/(0.2735612 *co2_data$CO2[i] ^ 0.21917)
  bvt.denom[9,i] = default.bvt[8,3]/(0.07967256 *co2_data$CO2[i] ^ 0.42793)
  bvt.denom[10,i] = default.bvt[10,3]/(0.07967256 *co2_data$CO2[i] ^ 0.42793)
}

# set up a results container for bvt for each climate scenario specified in climate.conditions
bvt.denom.cc <- data.frame(matrix(ncol=length(climate.conditions),nrow=length(rgroup_data$name)))
rownames(bvt.denom.cc)=rgroup_data$name
colnames(bvt.denom.cc)=climate.conditions

# populate results container with climate scenario specific bvt
for(i in 1:length(climate.conditions)){   
  
  if (grepl("Current",climate.conditions[i])) {
    bvt.denom.cc[,i] <- default.bvt$transpiration
 }
  
  else if (grepl("d50yrs.RCP45",climate.conditions[i])) {
  bvt.denom.cc[,i] <- bvt.denom$d50yrs.RCP45
 } 
  
  else if (grepl("d50yrs.RCP85",climate.conditions[i])) {
  bvt.denom.cc[i] <- bvt.denom$d50yrs.RCP85
 } 
  
  else if (grepl("d90yrs.RCP45",climate.conditions[i])) {
    bvt.denom.cc[i] <- bvt.denom$d90yrs.RCP45
 } 
  
  else if (grepl("d90yrs.RCP85",climate.conditions[i])) {
    bvt.denom.cc[i] <- bvt.denom$d90yrs.RCP85
 }
}