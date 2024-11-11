# 
# This script will map the NACE sectorsin the original 
# secnarios to the GRACE sectors.
# Uses the mapping provided by Lin Ma.
# 
# Benjamin Blanz 2024
# 

library(readxl)
sector_mapping <- read_excel("helperData/GTAP_NACE_sector_mapping.xlsx")
source('sectorColRegex.R')

# NACE files for which we will map the sectors to GRACE
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
	cat(sprintf('GRACEifying %s...',file))
	data <- read.csv(file)
	names(data)[names(data)=='ALL'] <- 'TOTAL'
	dataCols <- grep(sectorColPattern,names(data),perl = T)
	for( i in dataCols){
		data[,i] <- suppressWarnings(as.numeric(data[,i]))
	}
	data[is.na(data)] <- 0
	dataGRACE <- data
	dataGRACE[,dataCols] <- NULL
	GRACEcodes <- unique(sector_mapping$`GRACE Code`)
	for(GRACEcode in GRACEcodes){
		dataGRACE[[GRACEcode]] <- NA
		col <- which(sector_mapping$`GRACE Code` == GRACEcode)
		NACEcodes <- strsplit(paste(sector_mapping$`NACE Code`[col],collapse = '.'),'\\.')[[1]]
		if(sum(NACEcodes %in% colnames(data))==length(NACEcodes)){
			if(length(NACEcodes)>1){
				dataGRACE[[GRACEcode]] <- rowSums(data[,NACEcodes])
			} else {
				dataGRACE[[GRACEcode]] <- data[,NACEcodes]
			}
		}
	}
	dataGRACE[is.na(dataGRACE)]<-0
	write.csv(dataGRACE,gsub('NACE','GRACE',file),row.names = F)
	cat('done\n')
}
