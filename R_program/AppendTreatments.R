#Script that adds columns of the compiled csv files and then combines all individual output csv files for all climate-disturbance-input combinations into a master "total" file for each type of outputs: bmass, mort, sw2 (daily, monthly, yearly)

setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output/sw_output",sep=""))

#daily files
tempsw2_daily_slyrs<-data.frame(read.csv(name.sw2.daily.slyrs.csv))
tempsw2_daily<-data.frame(read.csv(name.sw2.daily.csv))

#write master daily file for soil-layer variables
tempsw2_daily_slyrs$site<-sites[1]
tempsw2_daily_slyrs$GCM<-GCM[g]
tempsw2_daily_slyrs$Rgrp_treatment<-treatmentName

#tempsw2_daily_slyrs<-tempsw2_daily_slyrs[order(tempsw2_daily_slyrs$DOY),]
#tempsw2_daily_slyrs<-tempsw2_daily_slyrs[order(tempsw2_daily_slyrs$YEAR),]

tempsw2_daily_slyrs$species<-sp
tempsw2_daily_slyrs$soilType<-soil
tempsw2_daily_slyrs$dist_freq<-dst
tempsw2_daily_slyrs$graz_freq<-grz
tempsw2_daily_slyrs$intensity<-intensity

if(GCM[g]=="Current")
{
  tempsw2_daily_slyrs$RCP<-rep("NONE",length(tempsw2_daily_slyrs$site))
  tempsw2_daily_slyrs$YEARS<-rep("NONE",length(tempsw2_daily_slyrs$site))  
}else
{
  tempsw2_daily_slyrs$RCP<-r
  tempsw2_daily_slyrs$YEARS<-y  
}

#write master daily file for non-soil layer files
tempsw2_daily$site<-sites[1]
tempsw2_daily$GCM<-GCM[g]
tempsw2_daily$Rgrp_treatment<-treatmentName

#tempsw2_daily<-tempsw2_daily[order(tempsw2_daily$DOY),]
#tempsw2_daily<-tempsw2_daily[order(tempsw2_daily$YEAR),]

tempsw2_daily$species<-sp
tempsw2_daily$soilType<-soil
tempsw2_daily$dist_freq<-dst
tempsw2_daily$graz_freq<-grz
tempsw2_daily$intensity<-intensity

if(GCM[g]=="Current")
{
  tempsw2_daily$RCP<-rep("NONE",length(tempsw2_daily$site))
  tempsw2_daily$YEARS<-rep("NONE",length(tempsw2_daily$site))
}else
{
  tempsw2_daily$RCP<-r
  tempsw2_daily$YEARS<-y
}

write.table(tempsw2_daily_slyrs, "total_sw2_daily_slyrs.csv",sep=",",col.names=!file.exists("total_sw2_daily_slyrs.csv"),row.names=F,quote = F,append=T)
write.table(tempsw2_daily, "total_sw2_daily.csv",sep=",",col.names=!file.exists("total_sw2_daily.csv"),row.names=F,quote = F,append=T)

#monthly files
tempsw2_monthly_slyrs<-data.frame(read.csv(name.sw2.monthly.slyrs.csv))
tempsw2_monthly<-data.frame(read.csv(name.sw2.monthly.csv))

#write master monthly file for soil-layer variables
tempsw2_monthly_slyrs$site<-sites[1]
tempsw2_monthly_slyrs$GCM<-GCM[g]
tempsw2_monthly_slyrs$Rgrp_treatment<-treatmentName

tempsw2_monthly_slyrs$species<-sp
tempsw2_monthly_slyrs$soilType<-soil
tempsw2_monthly_slyrs$dist_freq<-dst
tempsw2_monthly_slyrs$graz_freq<-grz
tempsw2_monthly_slyrs$intensity<-intensity

if(GCM[g]=="Current")
{
  tempsw2_monthly_slyrs$RCP<-rep("NONE",length(tempsw2_monthly_slyrs$site))
  tempsw2_monthly_slyrs$YEARS<-rep("NONE",length(tempsw2_monthly_slyrs$site))
}else
{
  tempsw2_monthly_slyrs$RCP<-r
  tempsw2_monthly_slyrs$YEARS<-y
}

#write master monthly file for non-soil layer files
tempsw2_monthly$site<-sites[1]
tempsw2_monthly$GCM<-GCM[g]
tempsw2_monthly$Rgrp_treatment<-treatmentName

tempsw2_monthly$species<-sp
tempsw2_monthly$soilType<-soil
tempsw2_monthly$dist_freq<-dst
tempsw2_monthly$graz_freq<-grz
tempsw2_monthly$intensity<-intensity

if(GCM[g]=="Current")
{
  tempsw2_monthly$RCP<-rep("NONE",length(tempsw2_monthly$site))
  tempsw2_monthly$YEARS<-rep("NONE",length(tempsw2_monthly$site))
}else
{
  tempsw2_monthly$RCP<-r
  tempsw2_monthly$YEARS<-y
}

write.table(tempsw2_monthly_slyrs, "total_sw2_monthly_slyrs.csv",sep=",",col.names=!file.exists("total_sw2_monthly_slyrs.csv"),row.names=F,quote = F,append=T)
write.table(tempsw2_monthly, "total_sw2_monthly.csv",sep=",",col.names=!file.exists("total_sw2_monthly.csv"),row.names=F,quote = F,append=T)

#yearly files
tempsw2_yearly_slyrs<-data.frame(read.csv(name.sw2.yearly.slyrs.csv))
tempsw2_yearly<-data.frame(read.csv(name.sw2.yearly.csv))

#write master yearly file for soil-layer variables
tempsw2_yearly_slyrs$site<-sites[1]
tempsw2_yearly_slyrs$GCM<-GCM[g]
tempsw2_yearly_slyrs$Rgrp_treatment<-treatmentName

tempsw2_yearly_slyrs$species<-sp
tempsw2_yearly_slyrs$soilType<-soil
tempsw2_yearly_slyrs$dist_freq<-dst
tempsw2_yearly_slyrs$graz_freq<-grz
tempsw2_yearly_slyrs$intensity<-intensity

if(GCM[g]=="Current")
{
  tempsw2_yearly_slyrs$RCP<-rep("NONE",length(tempsw2_yearly_slyrs$site))
  tempsw2_yearly_slyrs$YEARS<-rep("NONE",length(tempsw2_yearly_slyrs$site))
}else
{
  tempsw2_yearly_slyrs$RCP<-r
  tempsw2_yearly_slyrs$YEARS<-y
}

#write master yearly file for non-soil layer files
tempsw2_yearly$site<-sites[1]
tempsw2_yearly$GCM<-GCM[g]
tempsw2_yearly$Rgrp_treatment<-treatmentName

tempsw2_yearly$species<-sp
tempsw2_yearly$soilType<-soil
tempsw2_yearly$dist_freq<-dst
tempsw2_yearly$graz_freq<-grz
tempsw2_yearly$intensity<-intensity

if(GCM[g]=="Current")
{
  tempsw2_yearly$RCP<-rep("NONE",length(tempsw2_yearly$site))
  tempsw2_yearly$YEARS<-rep("NONE",length(tempsw2_yearly$site))
}else
{
  tempsw2_yearly$RCP<-r
  tempsw2_yearly$YEARS<-y
}

write.table(tempsw2_yearly_slyrs, "total_sw2_yearly_slyrs.csv",sep=",",col.names=!file.exists("total_sw2_yearly_slyrs.csv"),row.names=F,quote = F,append=T)
write.table(tempsw2_yearly, "total_sw2_yearly.csv",sep=",",col.names=!file.exists("total_sw2_yearly.csv"),row.names=F,quote = F,append=T)

#Write total bmass and mort files
setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output",sep=""))
tempbmass<-data.frame(read.csv(name.bmass.csv))
tempmort<-data.frame(read.csv(name.mort.csv))

tempbmass$site<-sites[1]
tempbmass$GCM<-GCM[g]
tempbmass$Rgrp_treatment<-treatmentName

tempbmass$species<-sp
tempbmass$soilType<-soil
tempbmass$dist_freq<-dst
tempbmass$graz_freq<-grz
tempbmass$intensity<-intensity

if(GCM[g]=="Current")
{
  tempbmass$RCP<-rep("NONE",length(tempbmass$site))
  tempbmass$YEARS<-rep("NONE",length(tempbmass$site))   
}else
{
  tempbmass$RCP<-r
  tempbmass$YEARS<-y
}

tempmort$site<-sites[1]
tempmort$GCM<-GCM[g]
tempmort$Rgrp_treatment<-treatmentName

tempmort$species<-sp
tempmort$soilType<-soil
tempmort$dist_freq<-dst
tempmort$graz_freq<-grz
tempmort$intensity<-intensity

if(GCM[g]=="Current")
{
  tempmort$RCP<-rep("NONE",length(tempmort$site))
  tempmort$YEARS<-rep("NONE",length(tempmort$site))
}else
{
  tempmort$RCP<-r
  tempmort$YEARS<-y
}

write.table(tempbmass, "total_bmass.csv",sep=",",col.names=!file.exists("total_bmass.csv"),row.names=F,quote = F,append=T)
write.table(tempmort, "total_mort.csv",sep=",",col.names=!file.exists("total_mort.csv"),row.names=F,quote = F,append=T)