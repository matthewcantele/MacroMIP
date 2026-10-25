# GTAP-INT, 2-p: persistent agricultural productivity change in France (protocol Table 2.1)
# Scenario definitions, shocks and solver settings are in R/common.R.
# Run from the project root: Rscript R/GTAP-INT/2-p-sq.R
source("R/common.R")

run_jobs(macromip_jobs("GTAP-INT", "2-p"))
