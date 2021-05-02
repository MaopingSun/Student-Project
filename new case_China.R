### 2020全球新冠疫情信息明细数据 ###


rm(list = ls())

library(tidyverse)
library(dplyr)
library(readxl)

data = read_xlsx('/Users/cosmos/Documents/# semester_2/ECON 7910 Storytelling/project/dataset/澎湃美数课/2020年全球新冠疫情信息明细数据.xlsx')
data = data[-1,-7:-10]
colnames(data) = c('Date','Province','City','NewCase','NewDischarge','NewDeath')


# check how many rows with NA in column NewCase
sum(is.na(data$NewCase))


# drop rows with NA and foreign countries in column Province
prov = c('河北','山西','辽宁','吉林','黑龙江','江苏','浙江','安徽','福建','江西','山东','河南','湖北','湖南','广东','海南','四川','贵州','云南','陕西','甘肃','青海','台湾',
         '内蒙古','广西','西藏','宁夏','新疆','北京','天津','上海','重庆','香港','澳门')
data = data[data$Province %in% prov,] 


# classify the type of new cases into 3 groups,Local case,Domestic imported and Foreign imported
data = replace_na(data,
                  list(City = '地市明细不详',
                       NewCase=0,
                       NewDischarge=0,
                       NewDeath=0))

data = data %>%  
  mutate(Type = case_when(grepl('境外',data$City) ~ 'Foreign imported',
                          grepl('外地',data$City) ~ 'Domestic imported',
                          TRUE ~ 'Local case')) %>% 
  mutate(Place = ifelse(str_detect(data$City,'-'),
                        sapply(strsplit(data$City,'-'),
                               function(x){x[2]}),
                        City))


# There are still 64 str 'NA' in column Place
sum(data$Place=='NA')
data$Place = ifelse(data$Place=='NA',data$Province,data$Place)


# There are still some misplacement
data[grep("境外",data$Place),]
data[which(data$Place == "境外输入孟加拉国"),"Place"] = "孟加拉国"


# There are '-' in 3 columns, "NewCase","NewDischarge","NewDeath".
# In other words, there is less than zero new case. Typo error must exists.
# There must be some typo error. So '-' needs to be removed.
for (i in 4:6){
  for (j in 1:nrow(data)){
    data[j,i] = gsub('-','',data[j,i])
  }
}


# drop city
data = data[,-3]

# Adjust order of columns
colnames(data)
order = c("Date","Province","Place","NewCase","Type","NewDischarge","NewDeath")
data = data[,order]


# save file
write.csv(data,'/Users/cosmos/Documents/# semester_2/ECON 7910 Storytelling/project/dataset/澎湃美数课/New case_China.csv',fileEncoding = 'GBK')
