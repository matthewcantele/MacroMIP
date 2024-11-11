# 
# Aggregate NUTS3 scenario stock data to country level
# 
# library(sf)
# worldAdmin1 <- read_sf('scenarios/ne_10m_admin_1_states_provinces/ne_10m_admin_1_states_provinces.shp') 
# 
# Benjamin Blanz 2024
# 

sectorColPattern <- 'ALL|TOTAL|^[A-Z]$|AGR|MIN|MFG|EGW|CNS|TRD|OTP|WTP|CMN|OFI|OBS|REA|PUB|OSG|agr|coa-oil-gas|coa\\.oil\\.gas|pro|ely-elc|ely\\.elc|ser|air-wtp-tran|air\\.wtp\\.tran'

# read scenario file with NUTS3 data ####
library(readxl)
library(countrycode)
# skip two rows so headings are the NACE letters
stocksNUTS3 <- read_excel("scenarios/flood Scenario 2.0/Flood_Scenario_2010.xlsx", 
										 sheet = "stocks")
stockCols <- grep('STOCK',names(stocksNUTS3))
for( n in grep('STOCK',names(stocksNUTS3))){
	colnames(stocksNUTS3)[n] <- stocksNUTS3[[n]][2]
}
stockUnit <- 'mEUR'
stockTypes <- stocksNUTS3[3,stockCols]
stockLabels <- stocksNUTS3[1,stockCols]
stocksNUTS3 <- stocksNUTS3[-(1:5),]
for( n in colnames(stocksNUTS3)[stockCols]){
	stocksNUTS3[[n]] <- as.numeric(stocksNUTS3[[n]])
}
stocksNUTS3$CNTR_CODE[stocksNUTS3$CNTR_CODE=='SRB_1'] <- 'SRB'
stocksNUTS3$CNTR_CODE[stocksNUTS3$CNTR_CODE=='RS'] <- 'SRB'
stocksNUTS3 <- stocksNUTS3[order(stocksNUTS3$CNTR_CODE),]
suppressWarnings(stocksNUTS3$CNTR_CODE_iso3 <- countrycode(stocksNUTS3$CNTR_CODE,'eurostat','iso3c'))
stocksNUTS3$CNTR_CODE_iso3[is.na(stocksNUTS3$CNTR_CODE_iso3)] <- countrycode(stocksNUTS3$CNTR_CODE[is.na(stocksNUTS3$CNTR_CODE_iso3)],'iso3c','iso3c')
stocksNUTS3$CNTR_NAME <- countrycode(stocksNUTS3$CNTR_CODE_iso3,'iso3c','iso.name.en')
stocksNUTS3$CNTR_CODE_Eurostat <- countrycode(stocksNUTS3$CNTR_CODE_iso3,'iso3c','eurostat')
stocksNUTS3$CNTR_CODE_iso2 <- countrycode(stocksNUTS3$CNTR_CODE_iso3,'iso3c','iso2c')
stocksNUTS3 <- stocksNUTS3[,c(1:5,29,30,31,28,6:27)]
write.csv(stocksNUTS3,file = 'helperData/nuts3LevelStocksNACE.csv',row.names=F)
codes <- stocksNUTS3[,1:9]
write.csv(codes,file = 'helperData/nuts3fid4Codes.csv',row.names=F)
sink('helperData/nuts3LevelStocksMetadata.csv')
cat(sprintf('Unit %s,,\n',stockUnit))
cat(sprintf('Labels,, \n'))
cat(sprintf('Sector,Label,Type\n'))
sectorCols <- grep(sectorColPattern,names(stocksNUTS3),perl = T)
for(n in colnames(stocksNUTS3)[sectorCols]){	
	cat(sprintf('"%s", "%s", "%s"\n',n,stockLabels[n],stockTypes[n]))
}
sink()


# aggregate to country level
sectorCols <- grep(sectorColPattern,names(stocksNUTS3),perl = T)
stocksCNT <- aggregate(stocksNUTS3[,sectorCols],
											 by = list(Category=stocksNUTS3$CNTR_CODE),FUN=sum)
colnames(stocksCNT)[1] <- 'CNTR_CODE'
# add country codes and country names back to data
# two and three letter country codes as seperate columns
library(countrycode)
stocksCNT$CNTR_CODE[stocksCNT$CNTR_CODE=='SRB_1'] <- 'SRB'
stocksCNT$CNTR_CODE[stocksCNT$CNTR_CODE=='RS'] <- 'SRB'
suppressWarnings(stocksCNT$CNTR_CODE_iso3 <- countrycode(stocksCNT$CNTR_CODE,'eurostat','iso3c'))
stocksCNT$CNTR_CODE_iso3[is.na(stocksCNT$CNTR_CODE_iso3)] <- countrycode(stocksCNT$CNTR_CODE[is.na(stocksCNT$CNTR_CODE_iso3)],'iso3c','iso3c')
stocksCNT$CNTR_NAME <- countrycode(stocksCNT$CNTR_CODE_iso3,'iso3c','iso.name.en')
stocksCNT$CNTR_CODE_Eurostat <- countrycode(stocksCNT$CNTR_CODE_iso3,'iso3c','eurostat')
stocksCNT$CNTR_CODE_iso2 <- countrycode(stocksCNT$CNTR_CODE_iso3,'iso3c','iso2c')
stocksCNT <- stocksCNT[,c(25,26,27,24,2:23)]
write.csv(stocksCNT,file = 'helperData/countryLevelStocksNACE.csv',row.names = F)
sink('helperData/countryLevelStocksMetadata.csv')
cat(sprintf('Unit %s,,\n',stockUnit))
cat(sprintf('Labels,, \n'))
cat(sprintf('Sector,Label,Type\n'))
sectorCols <- grep(sectorColPattern,names(stocksNUTS3),perl = T)
for(n in colnames(stocksNUTS3)[sectorCols]){	
	cat(sprintf('"%s", "%s", "%s"\n',n,stockLabels[n],stockTypes[n]))
}
sink()

# aggregate to NUTS2 level ####
library(nuts)
rlang::local_options(nuts.verbose = "quiet")
nutsSheet <- read_excel("helperData/NUTS2021.xlsx", 
												sheet = "NUTS & SR 2021", range = "A1:H2125")
source('funAggregateNuts2CNT.R')
stocksNUTS2 <- aggregateNUTS3ToNUTS2(stocksNUTS3,
																		 codes[,c('fid4','CNTR_CODE','CNTR_NAME','CNTR_CODE_iso2','CNTR_CODE_iso3','CNTR_CODE_Eurostat')],
																		 nutsSheet,sectorColPattern)
write.csv(stocksNUTS2,file = 'helperData/nuts2LevelStocksNACE.csv',row.names = F)
sink('helperData/countryLevelStocksMetadata.csv')
cat(sprintf('Unit %s,,\n',stockUnit))
cat(sprintf('Labels,, \n'))
cat(sprintf('Sector,Label,Type\n'))
sectorCols <- grep(sectorColPattern,names(stocksNUTS2),perl = T)
for(n in colnames(stocksNUTS2)[sectorCols]){	
	cat(sprintf('"%s", "%s", "%s"\n',n,stockLabels[n],stockTypes[n]))
}
sink()
