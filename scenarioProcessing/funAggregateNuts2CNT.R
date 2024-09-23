#
# Function to aggregate stocks or stock data to the country level from the NUTS3 level
# 
# Parameters
# 	data		data to aggregate
# 	codes   country 
# 	sectorColPattern the matching pattern for sectorl column names
#
# Returns
#   aggregated data
#   
aggregateNUTS3ToCountry <- function(data,codes,sectorColPattern){
	# identify columns with data rather than identifiers
	sectorCols <- grep(sectorColPattern,names(data),perl = T)
	# convert data to numeric (deals with in import error)
	for(s in sectorCols){
		suppressWarnings(data[[s]] <- as.numeric(data[[s]]))
	}
	data[is.na(data)] <- 0
	# combine the data and the codes datasets on the fid4 field if the data dataset 
	# does not already have a CNTR_CODE field that can be used for aggregation
	if(!('CNTR_CODE'%in%names(data))){
		data <- merge(codes,data,by = 'fid4')
	}
	sectorCols <- grep(sectorColPattern,names(data),perl = T)
	data <- aggregate(data[,c(sectorCols)],
											 by = list(Category=data$CNTR_CODE),FUN=sum)
	names(data)[1] <- 'CNTR_CODE'
	codesCNT <- codes[,-1]
	codesCNT <- codesCNT[!duplicated(codesCNT),]
	data <- merge(codesCNT,data)
	return(data)
}

#
# Function to aggregate stocks or stock data to the NUTS2 level from the NUTS3 level
# 
# Parameters
# 	data		  data to aggregate
# 	codes     country codes
# 	nutsSheet nuts2021 sheet of region names from eurostat
# 	sectorColPattern the matching pattern for sectorl column names
#
# Returns
#   aggregated data
#   
aggregateNUTS3ToNUTS2 <- function(data,codes,nutsSheet,sectorColPattern){
	# identify rows that contain semantically valid nuts ids
	data.NUTSsubset <- data[grepl('^[a-zA-Z]{2}[a-zA-Z0-9]{1,3}$',data$fid4,perl=T),]
	# use the nuts classifiy script to determine the nuts versions
	data.NUTSsubset.classified <- nuts_classify(data.NUTSsubset,'fid4') 
	# identify rows that have now valid nuts version these can be candidate countries that are not in the nuts lib database
	# or malformed
	data.NUTSsubset.naVersion <- data.NUTSsubset.classified$data[is.na(data.NUTSsubset.classified$data$from_version),]
	# remove the invalid rows
	data.NUTSsubset <- data.NUTSsubset[!(data.NUTSsubset$fid4 %in% data.NUTSsubset.naVersion$from_code),]
	# reclassify and convert to uniform nuts version 2021
	data.NUTSsubset.classified <- nuts_classify(data.NUTSsubset,'fid4') 
	dataColsNames <- names(data.NUTSsubset)[grep(sectorColPattern,names(data.NUTSsubset),perl = T)]
	variablesVector <- rep('absolute',length(dataColsNames))
	names(variablesVector) <- dataColsNames
	data.NUTSsubset.2021 <- nuts_convert_version(data.NUTSsubset.classified,2021,variablesVector)
	data.NUTSsubset.2021 <- data.NUTSsubset.2021[,-which(names(data.NUTSsubset.2021)=='country')]#remove column "country" to work around a bug in the next line
	data.NUTSsubset.2021.classified <- nuts_classify(data.NUTSsubset.2021,'to_code') 
	# aggregate the valid rows to nuts2
	data.NUTSsubset.NUTS2 <- nuts_aggregate(data.NUTSsubset.2021.classified,2,variablesVector)
	data.NUTSsubset.NUTS2 <- data.NUTSsubset.NUTS2[,-which(names(data.NUTSsubset.NUTS2)=='country')]
	# drop empty rows, this should be just the FRY, france's overseas territories
	if(sum(complete.cases(data.NUTSsubset.NUTS2))==nrow(data.NUTSsubset.NUTS2)){
		stop('too many incomplete cases\n')
	} else {
		data.NUTSsubset.NUTS2 <- data.NUTSsubset.NUTS2[complete.cases(data.NUTSsubset.NUTS2),]
	}
	names(data.NUTSsubset.NUTS2)[1] <- 'NUTS2'
	
	# deal with the rows that where omitted above
	data.NUTSsubset.naVersion$nuts2 <- substring(data.NUTSsubset.naVersion$from_code,1,4)
	sectorCols <- grep(sectorColPattern,names(data.NUTSsubset.naVersion),perl = T)
	data.NUTSsubset.naVersion.NUTS2 <- aggregate(data.NUTSsubset.naVersion[,c(sectorCols)],
																							 by = list(Category=data.NUTSsubset.naVersion$nuts2),FUN=sum)
	names(data.NUTSsubset.naVersion.NUTS2)[1] <- 'NUTS2'
	
	# merge the two
	data.NUTSsubset.NUTS2 <- rbind(data.NUTSsubset.naVersion.NUTS2,data.NUTSsubset.NUTS2)
	
	# add the country codes and region names
	data.NUTSsubset.NUTS2$CNTR_CODE <- substring(data.NUTSsubset.NUTS2$NUTS2,1,2)
	data.NUTSsubset.NUTS2 <- merge(data.NUTSsubset.NUTS2,nutsSheet[,c('Code 2021','NUTS level 2')],by.x='NUTS2',by.y='Code 2021',all.x=T)
	names(data.NUTSsubset.NUTS2)[names(data.NUTSsubset.NUTS2)=='NUTS level 2'] <- 'NAME'
	numCol <- ncol(data.NUTSsubset.NUTS2)
	data.NUTSsubset.NUTS2 <- data.NUTSsubset.NUTS2[,c(1,numCol-1,numCol, 2:(numCol-2))]
	codesCNT <- codes[,-1]
	codesCNT <- codesCNT[!duplicated(codesCNT),]
	data.NUTS2 <- merge(codesCNT,data.NUTSsubset.NUTS2)
	return(data.NUTS2)
}
