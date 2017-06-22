#The Burke-Lauenroth Laboratory 
#SoilWatOutput.R
#Script to combine all outputs of SoilWat in terms of days,weeks,months and years

library(plyr)

#Input files with respective extensions, weekly and monthly are commented out as default
dy_files<-system("ls *.dy",intern = TRUE)
#wk_files<-system("ls *.wk",intern = TRUE)
#mo_files<-system("ls *.mo",intern = TRUE)
yr_files<-system("ls *.yr",intern = TRUE)

#Write master file for all .dy files
LL<-list()
timeframe<-dy_files

for(j in 1:length(dy_files)) 
{
  temp_df<-data.frame()
  temp_df<-data.frame(read.table(timeframe[j],header=FALSE))
  colnames(temp_df) <- paste(timeframe[j], colnames(temp_df), sep = "_")
  colnames(temp_df)[1] <- "YEAR"
  colnames(temp_df)[2] <- "DOY"
  LL[[j]]<-temp_df
}

total<-LL[[1]]

for(j in 2:length(dy_files)) 
{
  total<-merge(total,LL[[j]],by=c("YEAR","DOY"))
}

total<-total[order(total$DOY),]
total<-total[order(total$YEAR),]

total$site<-sites[1]
total$GCM<-GCM[g]

if(GCM[g]=="Current")
{
total$soilType<-soil
total$dist_flag<-dist.graz.flag
    if(dist.graz.flag==T)
    {
        total$dist_freq<-dst
        total$graz_freq<-graz.freq
        total$intensity<-intensity
    }else
    {
        total$dist_freq<-NA
        total$graz_freq<-NA
        total$intensity<-NA
    }
}else
{
total$soilType<-soil
total$RCP<-r
total$YEARS<-y
total$dist_flag<-dist.graz.flag

    if(dist.graz.flag==T)
    {
        total$dist_freq<-dst
        total$graz_freq<-graz.freq
        total$intensity<-intensity
    }else
    {
    total$dist_freq<-NA
    total$graz_freq<-NA
    total$intensity<-NA
    }
}

#dbWriteTable(db, "total_dy", total, append=T)
write.table(total, "total_dy.csv",sep=",",row.names=F,quote = F,append = T)

#Write master file for all .wk files
#LL<-list()
#timeframe<-wk_files
#for(j in 1:length(wk_files))
#{
#  temp_df<-data.frame()
#  temp_df<-data.frame(read.table(timeframe[j],header=FALSE))
#  colnames(temp_df) <- paste(timeframe[j], colnames(temp_df), sep = "_")
#  colnames(temp_df)[1] <- "YEAR"
#  colnames(temp_df)[2] <- "WEEK"
#  LL[[j]]<-temp_df
#}

#total<-LL[[1]]

#for(j in 2:length(wk_files))
#{
#  total<-merge(total,LL[[j]],by=c("YEAR","WEEK"))
#}

#total<-total[order(total$WEEK),]
#total<-total[order(total$YEAR),]

#total$site<-sites[1]
#total$GCM<-GCM[g]
#if(GCM[g]=="Current")
#{
#total$soilType<-soil
#total$dist_flag<-dist.graz.flag
#    if(dist.graz.flag==T)
#    {
#        total$dist_freq<-dst
#        total$graz_freq<-graz.freq
#        total$intensity<-intensity
#    }else
#    {
#        total$dist_freq<-NA
#        total$graz_freq<-NA
#        total$intensity<-NA
#    }
#}else
#{
#total$soilType<-soil
#total$RCP<-r
#total$YEARS<-y
#total$dist_flag<-dist.graz.flag
#
#   if(dist.graz.flag==T)
#    {
#        total$dist_freq<-dst
#        total$graz_freq<-graz.freq
#        total$intensity<-intensity
#    }else
#    {
#    total$dist_freq<-NA
#    total$graz_freq<-NA
#    total$intensity<-NA
#    }
#}

#dbWriteTable(db, "total_wk", total, append=T)
#write.table(total, "total_wk.csv",sep=",",row.names=F,quote = F,append = T)

#Write master file for all .mo files
#LL<-list()
#timeframe<-mo_files

#for(j in 1:length(mo_files))
#{
#  temp_df<-data.frame()
#  temp_df<-data.frame(read.table(timeframe[j],header=FALSE))
#  colnames(temp_df) <- paste(timeframe[j], colnames(temp_df), sep = "_")
#  colnames(temp_df)[1] <- "YEAR"
#  colnames(temp_df)[2] <- "MONTH"
#  LL[[j]]<-temp_df
#}

#total<-LL[[1]]

#for(j in 2:length(mo_files))
#{
#  total<-merge(total,LL[[j]],by=c("YEAR","MONTH"))
#}

#total<-total[order(total$MONTH),]
#total<-total[order(total$YEAR),]
#total$site<-sites[1]
#total$GCM<-GCM[g]

#if(GCM[g]=="Current")
#{
#total$soilType<-soil
#total$dist_flag<-dist.graz.flag
#    if(dist.graz.flag==T)
#   {
#        total$dist_freq<-dst
#        total$graz_freq<-graz.freq
#        total$intensity<-intensity
#    }else
#    {
#        total$dist_freq<-NA
#        total$graz_freq<-NA
#        total$intensity<-NA
 #   }
#}else
#{
#total$soilType<-soil
#total$RCP<-r
#total$YEARS<-y
#total$dist_flag<-dist.graz.flag

    #if(dist.graz.flag==T)
    #{
    #    total$dist_freq<-dst
    #    total$graz_freq<-graz.freq
    #    total$intensity<-intensity
    #}else
    #{
    #total$dist_freq<-NA
    #total$graz_freq<-NA
    #total$intensity<-NA
    #}
#}
#dbWriteTable(db, "total_mo", total, append=T)
#write.table(total, "total_mo.csv",sep=",",row.names=F,quote = F,append = T)

#Write master file for all .yr files
LL<-list()
timeframe<-yr_files

for(j in 1:length(yr_files))
{
  temp_df<-data.frame()
  temp_df<-data.frame(read.table(timeframe[j],header=FALSE))
  colnames(temp_df) <- paste(timeframe[j], colnames(temp_df), sep = "_")
  colnames(temp_df)[1] <- "YEAR"
  LL[[j]]<-temp_df
}

total<-LL[[1]]

for(j in 2:length(yr_files))
{
  total<-merge(total,LL[[j]],by=c("YEAR"))
}

total<-total[order(total$YEAR),]
total$site<-sites[1]
total$GCM<-GCM[g]

if(GCM[g]=="Current")
{
total$soilType<-soil
total$dist_flag<-dist.graz.flag
    if(dist.graz.flag==T)
    {
        total$dist_freq<-dst
        total$graz_freq<-graz.freq
        total$intensity<-intensity
    }else
    {
        total$dist_freq<-NA
        total$graz_freq<-NA
        total$intensity<-NA
    }
}else
{
total$soilType<-soil
total$RCP<-r
total$YEARS<-y
total$dist_flag<-dist.graz.flag

    if(dist.graz.flag==T)
    {
        total$dist_freq<-dst
        total$graz_freq<-graz.freq
        total$intensity<-intensity
    }else
    {
    total$dist_freq<-NA
    total$graz_freq<-NA
    total$intensity<-NA
    }
}

#dbWriteTable(db, "total_yr", total, append=T)
write.table(total, "total_yr.csv",sep=",",row.names=F,quote = F,append=T)

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

write.table(tempbmass, "total_bmass.csv",sep=",",row.names=F,quote = F,append=T)
write.table(tempmort, "total_mort.csv",sep=",",row.names=F,quote = F,append=T)