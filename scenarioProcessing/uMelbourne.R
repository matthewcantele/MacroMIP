# This script takes the relative country level NACE data and fills in the aefall.csv
# file from Matthew Cantele to run the scenarios in the U Melbourne CGE model.
# 
# The generated files follow the structure in aefall.csv in helperData/melbourne.
# aefall.csv defines which Regions and sectors are filled in.
# p21b.csv is used to map model sectors to the NACE that the scenarios are in. A single
#          GTAP sector can correspond to multiple NACE sectors, as a v1 effort this 
#          script will then take the average of the impacts to the NACE sectors, for 
#          relative damages and the sum for absolute damages. The latter will cause 
#          double counting if NACE sectors are not uniquely mapped. A single model 
#          sector can be mapped to multiple NACE sectors by inputting them seperated
#          by a dot. I.e. mappingNACE A.B means that the model sector corresponds to 
#          both sectors A and B.
# r32.csv is currently far not used. This means that countries with shocks need to be
#          included as their own entry in aefall.csv. If desired, we can add structure
#          similar to the sector handling to aggregate multiple countries into a
#          single regions value.
# 
# Benjamin Blanz, 2024

# config ####

# load the mappings and the template for aefall.csv
mapping.sectors <- read.csv("helperData/melbourne/p21b.csv")
# mapping.regions <- read.csv("helperData/melbourne/r32.csv")
aefall.base <- read.csv("helperData/melbourne/afeall.csv")
# regions <- unique(mapping.regions$mapping)
# aefall.template <- read.csv("helperData/melbourne/afeall.csv")
ENDW_COMMi <- unique(aefall.base$ENDW_COMMi)

# for relative impacts
# fileSuffix <- '-rel'
# for absolute impacts in mEUR
# fileSuffix <- ''
fileSuffix <- ''

# by default or impact numbers are positive for reductions i.e. 0.1 would be a ten
# percent reduction if using -rel data. 
# To flip the sign add a - to the following line.
# This can also be used to have rel in percentage instead of share.
valueMultiplicator <- -1

# collect the scenario files that are impacts at the CNT level 
files <- list.files('scenarios',pattern = paste0('NACE-aggCNT',fileSuffix,'.csv'),recursive = T)


# processing ####

cat('copying over mapping files...')
file.copy(c("helperData/melbourne/p21b.csv","helperData/melbourne/r32.csv"),
					'scenarios/forMelbourne',overwrite = T)
cat('done\n')

cat('Processing to aefall format...\n')
f.i <- 0
for(file in files){
	f.i <- f.i +1
	cat(sprintf('%i of %i %s\n',f.i, length(files),file))
	data <- read.csv(paste0('scenarios/',file))
	rownames(data) <- data$CNTR_CODE
	outputFilename <- gsub('NACE','aefall',basename(file))
	aefall.scenario <- aefall.base
	for(r.i in 1:nrow(aefall.base)){
		sector <- aefall.base$PROD_COMMj[r.i]
		sector.nace <- mapping.sectors[which(mapping.sectors$mapping==sector),'mappingNACE']
		sector.nace <- strsplit(sector.nace,'\\.')[[1]]
		region <- aefall.base$REGr[r.i]
		data.row <- which(apply(data, 1, function(r) any(r %in% c(region,toupper(region),tolower(region)))))
		if(length(data.row)==0){
			value <- 0
		} else	if(length(data.row)==1){
			if (fileSuffix=='-rel'){
				value <- valueMultiplicator * mean(as.numeric(data[data.row,sector.nace]))
			} else if (fileSuffix ==''){
				value <- valueMultiplicator * sum(as.numeric(data[data.row,sector.nace]))
			} else {
				stop(paste0('unkown fileSuffix ',fileSuffix,' only -rel or emptystring allowed\n'))
			}
		} else if (length(data.row)>1) {
			stop(paste('ambiguous region country identifier',region,'\n'))
		}
		aefall.scenario$Value[r.i] <- value
	}
	write.csv(aefall.scenario,paste0('scenarios/forMelbourne/',outputFilename))
}
cat('done\n')
