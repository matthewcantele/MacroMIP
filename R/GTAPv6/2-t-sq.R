# GTAPv6, 2-t: temporary (2018) agricultural productivity change in France (protocol Table 2.1)
# Scenario definitions, shocks and solver settings are in R/common.R.
# Run from the project root: Rscript R/GTAPv6/2-t-sq.R
source("R/common.R")

run_jobs(macromip_jobs("GTAPv6", "2-t"))
