#The Burke-Lauenroth Laboratory 
#SoilWatOutput.R
#Script to combine all outputs of SoilWat in terms of days,weeks,months and years

library(plyr)

setwd(paste(directory,"Stepwat.Site.",s,".",g,"/testing.sagebrush.master/Stepwat_Inputs/Output/sw_output",sep=""))

#daily files
tempsw2_daily_slyrs<-data.frame(read.csv(name.sw2.daily.slyrs.csv))
tempsw2_daily<-data.frame(read.csv(name.sw2.daily.csv))

#write master daily file for soil-layer variables
tempsw2_daily_slyrs$site<-sites[1]
tempsw2_daily_slyrs$GCM<-GCM[g]

#tempsw2_daily_slyrs<-tempsw2_daily_slyrs[order(tempsw2_daily_slyrs$DOY),]
#tempsw2_daily_slyrs<-tempsw2_daily_slyrs[order(tempsw2_daily_slyrs$YEAR),]

if(GCM[g]=="Current")
{
    tempsw2_daily_slyrs$soilType<-soil
    tempsw2_daily_slyrs$dist_flag<-dist.graz.flag
    if(dist.graz.flag==T)
    {
        tempsw2_daily_slyrs$dist_freq<-dst
        tempsw2_daily_slyrs$graz_freq<-graz.freq
        tempsw2_daily_slyrs$intensity<-intensity
    }else
    {
        tempsw2_daily_slyrs$dist_freq<-NA
        tempsw2_daily_slyrs$graz_freq<-NA
        tempsw2_daily_slyrs$intensity<-NA
    }
    tempsw2_daily_slyrs$RCP<-rep("NONE",length(tempsw2_daily_slyrs$site))
    tempsw2_daily_slyrs$YEARS<-rep("NONE",length(tempsw2_daily_slyrs$site))  
}else
{
    tempsw2_daily_slyrs$soilType<-soil
    tempsw2_daily_slyrs$dist_flag<-dist.graz.flag
    
    if(dist.graz.flag==T)
    {
        tempsw2_daily_slyrs$dist_freq<-dst
        tempsw2_daily_slyrs$graz_freq<-graz.freq
        tempsw2_daily_slyrs$intensity<-intensity
    }else
    {
        tempsw2_daily_slyrs$dist_freq<-NA
        tempsw2_daily_slyrs$graz_freq<-NA
        tempsw2_daily_slyrs$intensity<-NA
    }
    tempsw2_daily_slyrs$RCP<-r
    tempsw2_daily_slyrs$YEARS<-y  
}

#write master daily file for non-soil layer files
tempsw2_daily$site<-sites[1]
tempsw2_daily$GCM<-GCM[g]

#tempsw2_daily<-tempsw2_daily[order(tempsw2_daily$DOY),]
#tempsw2_daily<-tempsw2_daily[order(tempsw2_daily$YEAR),]

if(GCM[g]=="Current")
{
    tempsw2_daily$soilType<-soil
    tempsw2_daily$dist_flag<-dist.graz.flag
    if(dist.graz.flag==T)
    {
       tempsw2_daily$dist_freq<-dst
       tempsw2_daily$graz_freq<-graz.freq
       tempsw2_daily$intensity<-intensity
    }else
    {
        tempsw2_daily$dist_freq<-NA
        tempsw2_daily$graz_freq<-NA
        tempsw2_daily$intensity<-NA
    }
        tempsw2_daily$RCP<-rep("NONE",length(tempsw2_daily$site))
    	tempsw2_daily$YEARS<-rep("NONE",length(tempsw2_daily$site))
}else
{
    tempsw2_daily$soilType<-soil
    tempsw2_daily$dist_flag<-dist.graz.flag
    
    if(dist.graz.flag==T)
    {
       tempsw2_daily$dist_freq<-dst
       tempsw2_daily$graz_freq<-graz.freq
       tempsw2_daily$intensity<-intensity
    }else
    {
        tempsw2_daily$dist_freq<-NA
        tempsw2_daily$graz_freq<-NA
        tempsw2_daily$intensity<-NA
    }
        tempsw2_daily$RCP<-r
    	tempsw2_daily$YEARS<-y
}

write.table(tempsw2_daily_slyrs, "total_sw2_daily_slyrs.csv",sep=",",col.names=!file.exists("total_sw2_daily_slyrs.csv"),row.names=F,quote = F,append=T)
write.table(tempsw2_daily, "total_sw2_daily.csv",sep=",",col.names=!file.exists("total_sw2_daily.csv"),row.names=F,quote = F,append=T)

#yearly files
tempsw2_yearly_slyrs<-data.frame(read.csv(name.sw2.yearly.slyrs.csv))
tempsw2_yearly<-data.frame(read.csv(name.sw2.yearly.csv))

#write master yearly file for soil-layer variables
tempsw2_yearly_slyrs$site<-sites[1]
tempsw2_yearly_slyrs$GCM<-GCM[g]

if(GCM[g]=="Current")
{
    tempsw2_yearly_slyrs$soilType<-soil
    tempsw2_yearly_slyrs$dist_flag<-dist.graz.flag
    if(dist.graz.flag==T)
    {
        tempsw2_yearly_slyrs$dist_freq<-dst
        tempsw2_yearly_slyrs$graz_freq<-graz.freq
        tempsw2_yearly_slyrs$intensity<-intensity
    }else
    {
        tempsw2_yearly_slyrs$dist_freq<-NA
        tempsw2_yearly_slyrs$graz_freq<-NA
        tempsw2_yearly_slyrs$intensity<-NA
    }
        tempsw2_yearly_slyrs$RCP<-rep("NONE",length(tempsw2_yearly_slyrs$site))
    	tempsw2_yearly_slyrs$YEARS<-rep("NONE",length(tempsw2_yearly_slyrs$site))
}else
{
    tempsw2_yearly_slyrs$soilType<-soil
    tempsw2_yearly_slyrs$dist_flag<-dist.graz.flag
    
    if(dist.graz.flag==T)
    {
        tempsw2_yearly_slyrs$dist_freq<-dst
        tempsw2_yearly_slyrs$graz_freq<-graz.freq
        tempsw2_yearly_slyrs$intensity<-intensity
    }else
    {
        tempsw2_yearly_slyrs$dist_freq<-NA
        tempsw2_yearly_slyrs$graz_freq<-NA
        tempsw2_yearly_slyrs$intensity<-NA
    }
        tempsw2_yearly_slyrs$RCP<-r
    	tempsw2_yearly_slyrs$YEARS<-y
}

#write master yearly file for non-soil layer files
tempsw2_yearly$site<-sites[1]
tempsw2_yearly$GCM<-GCM[g]

if(GCM[g]=="Current")
{
    tempsw2_yearly$soilType<-soil
    tempsw2_yearly$dist_flag<-dist.graz.flag
    if(dist.graz.flag==T)
    {
       tempsw2_yearly$dist_freq<-dst
       tempsw2_yearly$graz_freq<-graz.freq
       tempsw2_yearly$intensity<-intensity
    }else
    {
        tempsw2_yearly$dist_freq<-NA
        tempsw2_yearly$graz_freq<-NA
        tempsw2_yearly$intensity<-NA
    }
        tempsw2_yearly$RCP<-rep("NONE",length(tempsw2_yearly$site))
    	tempsw2_yearly$YEARS<-rep("NONE",length(tempsw2_yearly$site))
}else
{
    tempsw2_yearly$soilType<-soil
    tempsw2_yearly$dist_flag<-dist.graz.flag
    
    if(dist.graz.flag==T)
    {
       tempsw2_yearly$dist_freq<-dst
       tempsw2_yearly$graz_freq<-graz.freq
       tempsw2_yearly$intensity<-intensity
    }else
    {
        tempsw2_yearly$dist_freq<-NA
        tempsw2_yearly$graz_freq<-NA
        tempsw2_yearly$intensity<-NA
    }
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

if(GCM[g]=="Current")
{
   tempbmass$soilType<-soil
    tempbmass$dist_flag<-dist.graz.flag
    if(dist.graz.flag==T)
    {
        tempbmass$dist_freq<-dst
        tempbmass$graz_freq<-graz.freq
        tempbmass$intensity<-intensity
    }else
    {
        tempbmass$dist_freq<-NA
        tempbmass$graz_freq<-NA
        tempbmass$intensity<-NA
    }
}else
{
   tempbmass$soilType<-soil
    tempbmass$RCP<-r
    tempbmass$YEARS<-y
    tempbmass$dist_flag<-dist.graz.flag
    
    if(dist.graz.flag==T)
    {
        tempbmass$dist_freq<-dst
        tempbmass$graz_freq<-graz.freq
        tempbmass$intensity<-intensity
    }else
    {
        tempbmass$dist_freq<-NA
        tempbmass$graz_freq<-NA
        tempbmass$intensity<-NA
    }
}

tempmort$site<-sites[1]
tempmort$GCM<-GCM[g]

if(GCM[g]=="Current")
{
    tempmort$soilType<-soil
    tempmort$dist_flag<-dist.graz.flag
    if(dist.graz.flag==T)
    {
        tempmort$dist_freq<-dst
        tempmort$graz_freq<-graz.freq
        tempmort$intensity<-intensity
    }else
    {
        tempmort$dist_freq<-NA
        tempmort$graz_freq<-NA
        tempmort$intensity<-NA
    }
}else
{
    tempmort$soilType<-soil
    tempmort$RCP<-r
    tempmort$YEARS<-y
    tempmort$dist_flag<-dist.graz.flag
    
    if(dist.graz.flag==T)
    {
        tempmort$dist_freq<-dst
        tempmort$graz_freq<-graz.freq
        tempmort$intensity<-intensity
    }else
    {
        tempmort$dist_freq<-NA
        tempmort$graz_freq<-NA
        tempmort$intensity<-NA
    }
}

write.table(tempbmass, "total_bmass.csv",sep=",",col.names=!file.exists("total_bmass.csv"),row.names=F,quote = F,append=T)
write.table(tempmort, "total_mort.csv",sep=",",col.names=!file.exists("total_mort.csv"),row.names=F,quote = F,append=T)