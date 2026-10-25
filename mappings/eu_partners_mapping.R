library(data.table)
library(countrycode)

# EU28, Norway and Switzerland at country level (protocol section 3.2), the
# main extra-EU trade partners at country level, and the WB7 regions for the
# rest of the world
full <- fread("./mappings/REG.csv")
WB7 <- fread("./mappings/WB7.csv")

europe <- !is.na(countrycode(full$REG, "iso3c", "eu28")) | full$REG %in% c("nor", "che")
partners <- c("usa", "chn", "rus", "tur", "jpn", "kor", "ind", "bra", "can", "mex", "aus", "sau")

full$mapping <- ifelse(europe | full$REG %in% partners,
  full$REG,
  WB7$mapping[match(full$REG, WB7$REG)]
)

# with usa and can resolved, rest of North America (Greenland, Bermuda, St Pierre
# and Miquelon) would be a region of its own; it joins lac
full$mapping[full$REG == "xna"] <- "lac"

fwrite(full, "./mappings/euPartners.csv")
