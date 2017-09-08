#The Burke-Lauenroth Laboratory 
#STEPWAT R Wrapper
#Assembly script for STEPWAT Wrapper
#Script to assemble data from the list (produced by the query script),according to interval and type

if (INT==30)
{

#Iterate through each site
  site<-site[1] 
  #Create a folder for each site
  dir.create(paste0("Site","_",site), showWarnings = FALSE)
  setwd(paste("Site","_",site,sep=""))
  
  #Iterate through each scenario
  for(h in 1:H) 
  {
    i<-1
    #Pull out which scenario
    scen<-temp[h] 
    dir.create(paste0("Site","_",site,"_",scen), showWarnings = FALSE) #create a new directory with the site number and scenario name 
    setwd(paste("Site","_",site,"_",scen,sep="")) #reset the working directory into that new directory
    
  temp_assembly_dataframe<-data.frame(rSOILWAT2::dbW_weatherData_to_dataframe(sw_weatherList[[i]][[h]]))
    if (TYPE=="basic")
    {

    #Assemble data for every year, commenting out below as default
    for(year in AssemblyStartYear: (AssemblyStartYear+30))
    {
      x<-data.frame()
      x<-temp_assembly_dataframe[temp_assembly_dataframe$year==year,2:5];
      colnames(x)<-c("#DOY","Tmax_C", "Tmin_C","PPT_cm")# relabel the columns names 
      rownames(x)<- NULL #make rownames null (need this or else will have an extra column)
      write.table(x, file=paste("weath.",year,sep=""), sep="\t", row.names=F,quote=F) #write your year file in your directory
      year<-year+1
    }
    }
  setwd(paste(assembly_output,"/Site","_",site,sep=""))
  }
  setwd(assembly_output)
}


