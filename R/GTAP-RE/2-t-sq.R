# GTAP-RE (rational expectations and adaptive recursive), 2-t: temporary (2018) agricultural productivity change in France (protocol Table 2.1)
# Scenario definitions, shocks and solver settings are in R/common.R.
# Run from the project root: Rscript R/GTAP-RE/2-t-sq.R
source("R/common.R")

run_jobs(macromip_jobs("GTAP-RE", "2-t"))
