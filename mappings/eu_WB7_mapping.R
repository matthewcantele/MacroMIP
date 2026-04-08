library(data.table)
library(countrycode)

full <- fread("./mappings/REG.csv")
WB7 <- fread("./mappings/WB7.csv")

r_idx <- match(WB7$REG, full$REG)
full$WB7 <- WB7$mapping[r_idx]
full$mapping <- ifelse(!is.na(countrycode(full$REG, "iso3c", "eu28")),
  full$mapping,
  full$WB7
)

fwrite(full[, !"WB7"], "./mappings/euWB7.csv")