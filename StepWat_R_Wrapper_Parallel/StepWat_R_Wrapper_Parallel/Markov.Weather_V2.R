#The Burke-Lauenroth Laboratory 
#STEPWAT R Wrapper
#Markov script for STEPWAT_R_WRAPPER
#Script for Markov generator

#Set up system for parallel processing
library(doParallel)
registerDoParallel(proc_count)


#Loop through all sites
  #load a particular site
  site<-site[1] 
  s<-1
  #create directory for the particular site
  #dir.create(paste0("Site","_",site), showWarnings = FALSE) 
  #move to directory just created
  setwd(paste("Site","_",site,sep=""))
  foreach (h = 1:H) %dopar%
    { #h = number of GCM X RCP X Times (scenarios)
    scen<-temp[h] #load a particular scenario
    #dir.create(paste0("Site","_",site,"_",scen), showWarnings = FALSE) #create a new directory with the site number and scenario name 
    setwd(paste("Site","_",site,"_",scen,sep="")) #reset the working directory into that new directory
  
    ############ make mkv_prob.in file #############   
    #input data for particular site and scenario
    DGF<-data.frame(sw_weatherList[[s]][[h]])
    #add WET column 
    DGF<-within(DGF, WET<-FALSE)
    DGF[(DGF$PPT_cm>0),"WET"]<-TRUE
    
    #add WET given WET or WET given DRY column
    
    for (i in 1:nrow(DGF))
    {
      if(i==1)
      {
        if((DGF$WET[i]==TRUE)&(DGF$WET[i+364]==TRUE))
        {
          DGF$WW[i]=1
          DGF$WD[i]=0
          
        }
        else if((DGF$WET[i]==TRUE)&(DGF$WET[i+364]==FALSE))
        {
          DGF$WW[i]=0
          DGF$WD[i]=1
        }
        else{
          DGF$WW[i]=0
          DGF$WD[i]=0          
        }
      }
      
      else{
        
      if((DGF$WET[i]==TRUE)&(DGF$WET[i-1]==TRUE))
      {
        DGF$WW[i]=1
        DGF$WD[i]=0      }
      else if((DGF$WET[i]==TRUE)&(DGF$WET[i-1]==FALSE))
      {
        DGF$WW[i]=0
        DGF$WD[i]=1      }
      else{
        DGF$WW[i]=0
        DGF$WD[i]=0          
      }
      }
    }
    
        #create vectors to store data
        DOY<-vector();p_W_W<-vector();p_W_D<-vector();PPT_avg<-vector();PPT_sd<-vector();CF.max.w<-vector();
        CF.max.d<-vector();CF.min.w<-vector();CF.min.d<-vector()
        
        #make a dataframe for storing mkv_prob.in data
        DF<-data.frame(DOY,p_W_W,p_W_D,PPT_avg,PPT_sd,CF.max.w,CF.max.d,CF.min.w,CF.min.d)
        
        #celcius to kelvin conversion
        DGF$Tmax_C<-DGF$Tmax_C+273.15
        DGF$Tmin_C<-DGF$Tmin_C+273.15
        
          
        
      for ( i in 366) #loop through all possible days in all years
        {
          #probability of wet|wet is the number of wet given wet years for that day divided by the number
          #of total wet days from the previous day
        
          #prbability of wet|dry is the number of wet given dry years for that day divdied by the number of
          #total years (yrs identified by user) minus the total number of wet days from the previous day
          #or the number of dry days
        
          if(i==1)
          {
            p_W_W<-sum(DGF[(DGF$WW==1)&(DGF$DOY==i),7])
            p_W_D<-sum(DGF[(DGF$WD==1)&(DGF$DOY==i),8])
            
            p_W_W<-p_W_W/(sum(DGF[(DGF$WW==1)&(DGF$DOY==i+364),7])+sum(DGF[(DGF$WD==1)&(DGF$DOY==i+364),8]))
            p_W_D<-p_W_D/(yr-(sum(DGF[(DGF$WW==1)&(DGF$DOY==i+364),7])+sum(DGF[(DGF$WD==1)&(DGF$DOY==i+364),8])))
          }else
          {
            p_W_W<-sum(DGF[(DGF$WW==1)&(DGF$DOY==i),7])
            p_W_D<-sum(DGF[(DGF$WD==1)&(DGF$DOY==i),8])
            
            #p_W_W<-p_W_W/(DF$p_W_W[i-1]+DF$p_W_D[i-1])
            #p_W_D<-p_W_D/(yr-(DF$p_W_W[i-1]+DF$p_W_D[i-1]))
            
            p_W_W<-sum(DGF[(DGF$WW==1)&(DGF$DOY==i),7])
            p_W_D<-sum(DGF[(DGF$WD==1)&(DGF$DOY==i),8])
            
            p_W_W<-p_W_W/(sum(DGF[(DGF$WW==1)&(DGF$DOY==i-1),7])+sum(DGF[(DGF$WD==1)&(DGF$DOY==i-1),8]))
            p_W_D<-p_W_D/(yr-(sum(DGF[(DGF$WW==1)&(DGF$DOY==i-1),7])+sum(DGF[(DGF$WD==1)&(DGF$DOY==i-1),8])))
          }
         
          
          CF.max.w<-(abs(mean(DGF[(DGF$WET=="TRUE"),2])/mean(DGF[(DGF$DOY==i),2]))) + (mean(DGF[(DGF$WET=="TRUE"),2])-mean(DGF[(DGF$DOY==i),2]))/mean(DGF[(DGF$DOY==i),2])
          if (CF.max.w > 1.0) {CF.max.w<-1}
          CF.max.d<-(abs(mean(DGF[(DGF$WET=="FALSE"),2])/mean(DGF[(DGF$DOY==i),2]))) + (mean(DGF[(DGF$WET=="FALSE"),2])-mean(DGF[(DGF$DOY==i),2]))/mean(DGF[(DGF$DOY==i),2])
          if (CF.max.d < 1.0) {CF.max.d<-1}
          CF.min.w<-(abs(mean(DGF[(DGF$WET=="TRUE"),3])/mean(DGF[(DGF$DOY==i),3]))) + (mean(DGF[(DGF$WET=="TRUE"),3])-mean(DGF[(DGF$DOY==i),3]))/mean(DGF[(DGF$DOY==i),3])
          if (CF.min.w > 1.0) {CF.min.w<-1}
          CF.min.d<-(abs(mean(DGF[(DGF$WET=="FALSE"),3])/mean(DGF[(DGF$DOY==i),3]))) + (mean(DGF[(DGF$WET=="FALSE"),3])-mean(DGF[(DGF$DOY==i),3]))/mean(DGF[(DGF$DOY==i),3])
          if (CF.min.d < 1.0) {CF.min.d<-1}

          #DF.DAY$W_W[i]<-sum(prob.wet_wet) #sum all of the wet given wet days for the day across all the years
          #DF.DAY$W_D[i]<-sum(prob.wet_dry) #sum all of the wet given dry days for the day across all the years
    
          PPT_avg<-mean(DGF[(DGF$DOY==i),4]) #average the ppt across all the years for that day
          PPT_sd<-(sd((DGF[(DGF$DOY==i),4])))*2 #standard deviation the ppt across all the years for that day
          CF.max.w<-CF.max.w
          CF.max.d<-CF.max.d
          CF.min.w<-CF.min.w
          CF.min.d<-CF.min.d
          
          newrow<-data.frame(DOY=i,p_W_W=p_W_W,p_W_D=p_W_D,PPT_avg=PPT_avg,PPT_sd=PPT_sd,CF.max.w=CF.max.w,CF.max.d=CF.max.d,CF.min.w=CF.min.w,CF.min.d=CF.min.d)
          DF<-rbind(DF,newrow)
          
          } 

    # print out the probability file
    colnames(DF)<-c("#DOY","p[W|W]","p[W|D]","PPT_avg","PPT_sd","CF.max.w","CF.max.d","CF.min.w","CF.min.d")# relabel the columns names 
    #DF<-DF[,c("#DOY","p[W|W]","p[W|D]","PPT_avg","PPT_sd","CF.max.w","CF.max.d","CF.min.w","CF.min.d")] #put columns in correct order for output
    rownames(DF)<- NULL      
    write.table(format(DF, digits=5), file=paste("mkv_prob.in"), sep="\t", row.names=F,quote=F) #write your year file

###########################################################################

    ################## Write mkv_covar.in FILE  ##############################
    
    DGF_covar<-data.frame(sw_weatherList[[s]][[h]])
    for (k in 1:nrow(DGF_covar))
    {
      tempdate<-strptime(paste(DGF_covar$year[k],DGF_covar$DOY[k]),format="%Y %j")
      DGF_covar$WEEK[k]<-as.numeric(strftime(tempdate,format="%W")) # if PPT >0 the day is labeled wet
      DGF_covar$WEEK[k]<-DGF_covar$WEEK[k]+1
    }
    
    WEEK<-vector();T.MAX.C<-vector();T.MIN.C<-vector();cov_MINMIN<-vector();cov_MAXMIN<-vector();cov_MINMAX<-vector();
    cov_MAXMAX<-vector();
    
    #make a dataframe for storing mkv_prob.in data
    DF_covar<-data.frame(WEEK,T.MAX.C,T.MIN.C,cov_MINMIN,cov_MAXMIN,cov_MINMAX,cov_MAXMAX)

    for (w in 1:53) { 
    WEEK<-w
    min<-(DGF_covar[(DGF_covar$WEEK==w),3])
    max<-(DGF_covar[(DGF_covar$WEEK==w),2])
    MIN.MAX<-cov(min,max) #covariance between min and max temp over all days in week for all years
    MIN.MIN<-cov(min,min) #covariance between min temps over all days in week for all years
    MAX.MAX<-cov(max,max) #covariance between max temps over all days in week for all years
    MAX.MIN<-MIN.MAX
    T.MAX.C<-mean(max) #mean max temp for the week 
    T.MIN.C<-mean(min) #mean min temp for the week
    
    newrow<-data.frame(WEEK=WEEK,T.MAX.C=T.MAX.C,T.MIN.C=T.MIN.C,cov_MINMIN=MIN.MIN,cov_MAXMIN=MAX.MIN,cov_MINMAX=MIN.MAX,cov_MAXMAX=MAX.MAX)
    DF_covar<-rbind(DF_covar,newrow)

  }

#Then write the files
#rename columns
colnames(DF_covar)<-c("#WEEK","T.MAX.C", "T.MIN.C","cov[MIN.MIN]","cov[MAX.MIN]","cov[MIN.MAX]","cov[MAX.MAX]")# relabel the columns names 
rownames(DF_covar)<- NULL #make rownames null (need this or else will have an extra column)
write.table(format(DF_covar, digits=5), file=paste("mkv_covar.in"), sep="\t", row.names=F,quote=F) #write your year file in your directory

#reset directory to site level
setwd(paste(assembly_output,"Site","_",site,sep=""))
}

#reset directory to project level
setwd(assembly_output)


stopImplicitCluster()







