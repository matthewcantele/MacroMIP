# GTAP-RE (rational expectations and adaptive recursive), 1-o2-p: persistent country-level labour supply reduction in Spain (protocol Table 2.2)
# Scenario definitions, shocks and solver settings are in R/common.R.
# Run from the project root: Rscript R/GTAP-RE/1-o2-p-sq.R
source("R/common.R")

run_jobs(macromip_jobs("GTAP-RE", "1-o2-p"))
