# GTAP-INT, 3-p: persistent manufacturing capital productivity reduction in Germany (protocol Table 2.1)
# Scenario definitions, shocks and solver settings are in R/common.R.
# Run from the project root: Rscript R/GTAP-INT/3-p-sq.R
source("R/common.R")

run_jobs(macromip_jobs("GTAP-INT", "3-p"))
