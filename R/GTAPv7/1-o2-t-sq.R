# GTAPv7, 1-o2-t: temporary (2018) country-level labour supply reduction in Spain (protocol Table 2.2)
# Scenario definitions, shocks and solver settings are in R/common.R.
# Run from the project root: Rscript R/GTAPv7/1-o2-t-sq.R
source("R/common.R")

run_jobs(macromip_jobs("GTAPv7", "1-o2-t"))
