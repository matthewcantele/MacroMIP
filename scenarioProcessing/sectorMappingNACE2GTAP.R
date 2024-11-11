# 
# This script will map the NACE sectors in the original secnarios to the GTAP sectors.
# Uses the mapping provided by Lin Ma.
# 
# Benjamin Blanz 2024
# 

library(readxl)
GTAP_NACE_sector_mapping <- read_excel("helperData/GTAP_NACE_sector_mapping.xlsx")
source('sectorColRegex.R')

# files for which we will map the sectors to GTAP
files <- paste0('scenarios/',
								list.files('scenarios',pattern = 'NACE.csv',recursive = T))
files <- c(files,
					 paste0('scenarios/Danube Draught/',
					 			 list.files('scenarios/Danube Draught',pattern = 'NACE-rel.csv',recursive = T)))
files[length(files)+1] <- 'helperData/countryLevelStocksNACE.csv'
files[length(files)+1] <- 'helperData/nuts3LevelStocksNACE.csv'
files[length(files)+1] <- 'helperData/nuts2LevelStocksNACE.csv'

# Mapping of sectors
for (file in files){
	cat(sprintf('GTAPifying %s...',file))
	data <- read.csv(file)
	names(data)[names(data)=='ALL'] <- 'TOTAL'
	dataCols <- grep(sectorColPattern,names(data),perl = T)
	for( i in dataCols){
		data[,i] <- suppressWarnings(as.numeric(data[,i]))
	}
	data[is.na(data)] <- 0
	dataGTAP <- data
	dataGTAP[,dataCols] <- NULL
	for( GTAPcode.i in 1:nrow(GTAP_NACE_sector_mapping)){
		dataGTAP[[GTAP_NACE_sector_mapping$`GTAP Code`[GTAPcode.i]]] <- NA
		NACEcode <- GTAP_NACE_sector_mapping$`NACE Code`[GTAPcode.i]
		NACEcodes <- strsplit(NACEcode,'\\.')[[1]]
		if(sum(NACEcodes %in% colnames(data))==length(NACEcodes))
			if(length(NACEcodes)>1){
				dataGTAP[[GTAP_NACE_sector_mapping$`GTAP Code`[GTAPcode.i]]] <- 
					rowSums(data[,NACEcodes])
			} else {
				dataGTAP[[GTAP_NACE_sector_mapping$`GTAP Code`[GTAPcode.i]]] <- 
					data[,NACEcodes]
			}
	}
	dataGTAP[is.na(dataGTAP)]<-0
	write.csv(dataGTAP,gsub('NACE','GTAP',file),row.names = F)
	cat('done\n')
}
