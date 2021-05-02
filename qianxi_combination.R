### combination of Baidu Qianxi dataset ###

setwd('/Users/cosmos/Documents/# semester_2/ECON 7910 Storytelling/project/covid/百度迁徙_省级数据的副本')
library(tidyverse)
library(readxl)


# define path of the folder with 68 xls files
file_list = list.files(path = '/Users/cosmos/Documents/# semester_2/ECON 7910 Storytelling/project/covid/百度迁徙_省级数据的副本')

# create a empty data.frame for flow in and out file seperately
flow.in = data.frame()
flow.out = data.frame()


# load in 34 flow in files, pivot table from wide to long, and combine them in a loop
for (i in seq(2,length(file_list),2)){
  temp.in = read_excel(file_list[i])
  temp.in.long = pivot_longer(temp.in,
                              cols=-c(城市代码,迁入来源地),
                              names_to='Date',
                              values_to='%MigrationPopulaion')
  temp.in.long['Origin'] = sapply(strsplit(gsub('.xls','',file_list[i]),'-'),function(x){x[1]})
  temp.in.long['Class'] = 'In'
  flow.in = rbind(flow.in, temp.in.long)
}

names(flow.in)[1:2]=c('DestCode','Destination')

# load in 34 flow out files, and repeat the process above
for (j in seq(1,length(file_list),2)){
  temp.out = read_excel(file_list[j])
  temp.out.long = pivot_longer(temp.out,
                               cols=-c(城市代码,迁出目的地),
                               names_to='Date',
                               values_to='%MigrationPopulaion')
  temp.out.long['Origin'] = sapply(strsplit(gsub('.xls','',file_list[j]),'-'),
                                   function(x){x[1]})
  temp.out.long['Class'] = 'Out'
  flow.out = rbind(flow.out, temp.out.long)
}

names(flow.out)[1:2]=c('DestCode','Destination')


# combine flow in and out tables
qianxi = rbind(flow.in, flow.out)
order = c("Date","Class","Origin","Destination","%MigrationPopulaion","DestCode")  
qianxi = qianxi[,order]

# save file and encode chinese
write.csv(qianxi, file = '/Users/cosmos/Documents/# semester_2/ECON 7910 Storytelling/project/covid/qianxi.csv',fileEncoding='GBK')