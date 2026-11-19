# Every model x scenario of the MacroMIP s1 experiments in one queue, run
# MACROMIP_WORKERS jobs at a time (see R/common.R for resources).
#
# Run from the project root:
#   Rscript R/run_all.R                        # everything
#   Rscript R/run_all.R GTAP-RE 3-p 3-t        # filter by model and/or scenario
#   Rscript R/run_all.R --dry-run              # list the jobs only
source("R/common.R")

args <- commandArgs(trailingOnly = TRUE)
dry_run <- "--dry-run" %in% args
args <- setdiff(args, "--dry-run")

models <- intersect(args, names(MODELS))
scenarios <- intersect(args, names(SCENARIOS))
unknown <- setdiff(args, c(models, scenarios))
if (length(unknown)) {
  stop("unknown model or scenario: ", paste(unknown, collapse = ", "))
}
if (!length(models)) models <- names(MODELS)
if (!length(scenarios)) scenarios <- names(SCENARIOS)

jobs <- list()
for (s in scenarios) {
  for (m in intersect(scenario_models(s), models)) {
    jobs <- c(jobs, macromip_jobs(m, s))
  }
}

# largest first so the long intertemporal runs do not trail at the end:
# intertemporal before static, then by sector count and subintervals
size <- vapply(jobs, \(j) {
  MODELS[[j$model]]$intertemporal * 100 + length(sector_set(j$map)) + j$n_subintervals
}, numeric(1))
jobs <- jobs[order(-size)]

message(sprintf(
  "%d jobs: %s", length(jobs),
  paste(names(table(vapply(jobs, `[[`, "", "run"))), table(vapply(jobs, `[[`, "", "run")), sep = " ", collapse = ", ")
))

if (dry_run) {
  print(rbindlist(lapply(jobs, \(j) j[c("run", "sub", "map", "forcing", "n_subintervals")])))
} else {
  run_jobs(jobs)
}
