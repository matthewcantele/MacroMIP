#
# Uses the stocks in the flood scenario 2 and in the country level aggregate stocks derived
# from it to relativize the shocks in the earthquake and flood1 scenarios.
# 
# Benjamin Blanz 2024
# 

source('funRelData.R')

sectorColPattern <- 'ALL|TOTAL|^[A-Z]$|AGR|MIN|MFG|EGW|CNS|TRD|OTP|WTP|CMN|OFI|OBS|REA|PUB|OSG|agr|coa-oil-gas|coa\\.oil\\.gas|pro|ely-elc|ely\\.elc|ser|air-wtp-tran|air\\.wtp\\.tran'

stocks <- list()
stocks$NACE <- list(NUTS3 = read.csv("helperData/nuts3LevelStocksNACE.csv", row.names=NULL),
										NUTS2 = read.csv("helperData/nuts2LevelStocksNACE.csv", row.names=NULL),
										CNT = read.csv("helperData/countryLevelStocksNACE.csv", row.names=NULL))
stocks$GTAP <- list(NUTS3 = read.csv("helperData/nuts3LevelStocksGTAP.csv", row.names=NULL),
										NUTS2 = read.csv("helperData/nuts2LevelStocksGTAP.csv", row.names=NULL),
										CNT = read.csv("helperData/countryLevelStocksGTAP.csv", row.names=NULL))
stocks$GRACE <- list(NUTS3 = read.csv("helperData/nuts3LevelStocksGRACE.csv", row.names=NULL),
										 NUTS2 = read.csv("helperData/nuts2LevelStocksGRACE.csv", row.names=NULL),
										 CNT = read.csv("helperData/countryLevelStocksGRACE.csv", row.names=NULL))


files <- list.files('scenarios',pattern = 'csv',recursive = T)
files <- paste0('scenarios/',files[grep('.csv$(?<!rel.csv)',files,perl=T)])
cat('Calculating relative impacts for...\n')
for(f.i in 1:length(files)){
	file <- files[f.i]
	cat(sprintf('%i of %i %s\n',f.i, length(files),file))
	data <- read.csv(file,row.names=NULL)
	sectorType <- 'NACE'
	if(grepl('GTAP',file)){
		sectorType <- 'GTAP'
	} else if (grepl('GRACE',file)) {
		sectorType <- 'GRACE'
	}
	aggType <- 'NUTS3'
	if(grepl('aggCNT',file) | (!'fid4' %in% names(data) & !'NUTS2' %in% names(data))){
		aggType <- 'CNT'
	} else if(grepl('aggNUTS2',file)){
		aggType <- 'NUTS2'
	}
	data.rel <- relData(data,stocks[[sectorType]][[aggType]],aggType,sectorColPattern)
	write.csv(data.rel,gsub('.csv','-rel.csv',file),row.names = F)
}


