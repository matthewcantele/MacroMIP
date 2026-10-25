# GTAP-RE (rational expectations and adaptive recursive), 1-p: persistent labour productivity reduction in Spain (protocol Table 2.1)
# Scenario definitions, shocks and solver settings are in R/common.R.
# Run from the project root: Rscript R/GTAP-RE/1-p-sq.R
source("R/common.R")

run_jobs(macromip_jobs("GTAP-RE", "1-p"))
