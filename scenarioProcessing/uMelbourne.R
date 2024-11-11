# This script takes the relative country level NACE data and fills in the aefall.csv
# file from Matthew Cantele to run the scenarios in the U Melbourne CGE model.
# 
# Benjamin Blanz, 2024

# load the mappings and the template for aefall.csv
mapping.sectors <- read.csv("helperData/melbourne/p21b.csv")
mapping.regions <- read.csv("helperData/melbourne/r32.csv")
aefall.base <- read.csv("helperData/melbourne/afeall.csv")
regions <- unique(mapping.regions$mapping)
# aefall.template <- read.csv("helperData/melbourne/afeall.csv")
ENDW_COMMi <- unique(aefall.base$ENDW_COMMi)

# collect the scenario files that are relative impacts at the CNT level 
files <- list.files('scenarios',pattern = 'NACE-aggCNT-rel.csv',recursive = T)

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
		region <- aefall.base$REGr[r.i]
		data.row <- which(apply(data, 1, function(r) any(r %in% c(region,toupper(region),tolower(region)))))
		if(length(data.row)==1){
			value <- mean(as.numeric(data[data.row,sector.nace]))
		} else if (length(data.row)>1) {
			stop(paste('ambiguous region country identifier',region,'\n'))
		}
		aefall.scenario$Value[r.i] <- value
	}
	write.csv(aefall.scenario,paste0('scenarios/forMelbourne/',outputFilename))
	# sink(file=paste0('scenarios/forMelbourne/',outputFilename))
	# cat('ENDW_COMMi,PROD_COMMj,REGr,Value\n')
	# for(endo in ENDW_COMMi){
	# 	for(sector in unique(mapping.sectors$mapping)){
	# 		for(region in regions){
	# 			if (endo =='capital'){
	# 				sector.nace <- mapping.sectors[which(mapping.sectors$mapping==sector),'mappingNACE']
	# 				data.row <- which(apply(data, 1, function(r) any(r %in% c(region,toupper(region),tolower(region)))))
	# 				if(length(data.row)==1){
	# 					value <- mean(as.numeric(data[data.row,sector.nace]))
	# 				} else if (length(data.row)>1) {
	# 					stop(paste('ambiguous region country identifier',region,'\n'))
	# 				} else {
	# 					value <- 0
	# 				}
	# 			} else {
	# 				value <- 0
	# 			}
	# 			cat(sprintf("%s\n",paste(endo,sector,region,sprintf('%0.10f',value),sep=',')))
	# 		}
	# 	}
	# }
	# sink()
}
cat('done\n')
