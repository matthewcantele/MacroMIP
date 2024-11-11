#
# script to perform all the processing on the scenarios we got from James
#
# Benjamin Blanz 2024
# 

# Generates the helper data used to convert from absolute impacts to percentage
# reductions. Is based on the stocks specifed in the flood scenario file at NUTS3
# aggregates this to NUTS2 and country (CNT) level.
source('stockAggregation.R')

# Maps the NACE sectors in the original secnarios to the GTAP sectors.
source('sectorMappingNACE2GTAP.R')

# Maps the NACE sectors in the original scenarios to the GRACE sectors.
source('sectorMappingNACE2GRACE.R')

# aggregate the flood2010 and earthquake scenarios to country level
source('aggregateShocks.R')

# takes all the above outputs and calculates the relative impacts
source('relativizeShocks.R')

# takes the relative impacts and uses them to prepare the afeall.csv file 
# for U Melbourne
source('uMelbourne.R')
