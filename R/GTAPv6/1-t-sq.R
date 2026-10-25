# GTAPv6, 1-t: temporary (2018) labour productivity reduction in Spain (protocol Table 2.1)
# Scenario definitions, shocks and solver settings are in R/common.R.
# Run from the project root: Rscript R/GTAPv6/1-t-sq.R
source("R/common.R")

run_jobs(macromip_jobs("GTAPv6", "1-t"))
