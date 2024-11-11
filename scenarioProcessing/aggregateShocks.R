#
# aggregate the flood2010 and earthquake scenarios to country level
#
# Benjamin Blanz 2024
#

library(nuts)
suppressWarnings(rlang::local_options(nuts.verbose = "quiet"))
library(readxl)
nutsSheet <- read_excel("helperData/NUTS2021.xlsx", 
												sheet = "NUTS & SR 2021", range = "A1:H2125")
source('sectorColRegex.R')
source('funAggregateNuts2CNT.R')
codes <- read.csv("helperData/nuts3fid4Codes.csv")
codes <- codes[,c('fid4','CNTR_CODE','CNTR_NAME','CNTR_CODE_iso2','CNTR_CODE_iso3','CNTR_CODE_Eurostat')]
codes <- codes[!duplicated(codes),]

# files to aggregate

files <- list.files('scenarios',pattern = 'csv',recursive = T)
files <- paste0('scenarios/',files[grep('\\.csv$',files,perl=T)])
files <- files[!grepl('(agg)|(rel)',files)]

cat('Aggregating NUTS3 to NUTS2 for...\n')
for(f.i in 1:length(files)){
	file <- files[f.i]
	cat(sprintf('%i of %i %s\n',f.i, length(files),file))
	data <- read.csv(file,row.names=NULL)
	if(!('fid4'%in%names(data))){
		cat('    fid4 col missing probably already country level data\n')
	} else {
		data.NUTS2 <- aggregateNUTS3ToNUTS2(data,codes,nutsSheet,sectorColPattern)
		write.csv(data.NUTS2,gsub('.csv','-aggNUTS2.csv',file),row.names = F)
	}
}


cat('Aggregating NUTS3 to CNT for...\n')
for(f.i in 1:length(files)){
	file <- files[f.i]
	cat(sprintf('%i of %i %s\n',f.i, length(files),file))
	data <- read.csv(file,row.names=NULL)
	if(!('fid4'%in%names(data))){
		cat('    fid4 col missing probably already country level data\n')
		write.csv(data,gsub('.csv','-aggCNT.csv',file),row.names = F)
	} else {
		data.CNT <- aggregateNUTS3ToCountry(data,codes,sectorColPattern)
		write.csv(data.CNT,gsub('.csv','-aggCNT.csv',file),row.names = F)
	}
}
