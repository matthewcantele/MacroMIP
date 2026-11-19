# Shared configuration, scenario definitions and run helpers for the MacroMIP
# s1 stylized shock experiments (protocol v1-2, 17.03.2026).
#
# Scripts are run from the project root:
#   Rscript R/GTAP-RE/1-p-sq.R     # one model x scenario
#   Rscript R/run_all.R            # every model x scenario, in parallel
#
# Requires teems >= 1.0.1, the teems-solver image >= 1.1.0 and the GTAP 11c
# database (see "Setup" in README.md); check_setup() reports what is missing.

for (pkg in c("teems", "data.table")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("package '", pkg, "' is not installed: install.packages(\"", pkg, "\")", call. = FALSE)
  }
}
if (packageVersion("teems") < "1.0.1") {
  stop("teems >= 1.0.1 is required, found ", packageVersion("teems"),
    ": install.packages(\"teems\")",
    call. = FALSE
  )
}
library(teems)
library(data.table)

# ------------------------------------------------------------------------------
# configuration
# ------------------------------------------------------------------------------

# 2017 base year, shock in 2018 (protocol 2.1), run out to 2100 (protocol 3.3)
ALLTIME <- c(
  2017, 2018, 2020, 2022, 2024, 2026, 2028, 2030, 2035, 2040, 2045, 2050,
  2060, 2070, 2080, 2090, 2100
)
SFID <- "sq"

# GTAP 11c (reference year 2017): paths to the data, parameter and set files
GTAP_ENV <- c(dat = "GTAP11c_dat", par = "GTAP11c_par", set = "GTAP11c_set")
DAT <- Sys.getenv(GTAP_ENV[["dat"]])
PAR <- Sys.getenv(GTAP_ENV[["par"]])
SET <- Sys.getenv(GTAP_ENV[["set"]])

# resources: concurrent jobs, and MPI tasks x OpenMP threads per intertemporal
# job (static jobs run LU on MACROMIP_TASKS * MACROMIP_THREADS threads); on a
# 32-core box 8 jobs x (2 x 2) gave ~30% more throughput than 4 x (4 x 2).
# The default number of jobs is what the cores allow, up to 8; an intertemporal
# job at 27 sectors also needs about 8 GB of memory
N_TASKS <- as.integer(Sys.getenv("MACROMIP_TASKS", "2"))
N_THREADS <- as.integer(Sys.getenv("MACROMIP_THREADS", "2"))
WORKERS <- as.integer(Sys.getenv(
  "MACROMIP_WORKERS",
  max(1L, min(8L, parallel::detectCores() %/% (N_TASKS * N_THREADS), na.rm = TRUE))
))

# rerun jobs whose results already exist
OVERWRITE <- Sys.getenv("MACROMIP_OVERWRITE", "0") == "1"

# accuracy (share of results to 4 significant figures) below which a Gragg run
# is repeated with twice the subintervals, up to MAX_SUBINTERVALS
ACCURACY_MIN <- 80
MAX_SUBINTERVALS <- 8L

# intertemporal shocks larger than this are solved with adaptive DoPri54
# (ems_RK()): on GTAP-RE 2-p +40 it matched Gragg 2-4-6 over 4 subintervals
# (median relative difference 1e-5) in a third of the time, while Gragg over
# one subinterval was faster than DoPri54 on the small shocks
RK_ABOVE <- 10

# ------------------------------------------------------------------------------
# sets (element names after aggregation, see mappings/)
# ------------------------------------------------------------------------------

REG_MAP <- "./mappings/euPartners.csv"
REG <- unique(fread(REG_MAP)$mapping)
ENDW <- unique(fread("./mappings/labor_diff.csv")$mapping)
LABOUR <- c("sklab", "unsklab")

sector_set <- function(map) {
  unique(fread(file.path("mappings", paste0(map, ".csv")))$mapping)
}

# one sector set for every scenario, so the broad sectors are composed
# identically across the pairs (pairs 1 and 2 were first run on smaller sets,
# agri_cns.csv and agriculture.csv, and rerun on this one)
SECTOR_MAP <- "manufacturing"

# agriculture: all crops and farming types (protocol 2.2.1), forestry and
# fishing (frsfsh) excluded; the eight GTAP crops are one aggregate
AGRI <- c("crops", "livestock")

# manufacturing: NACE C, processed food included
MANUF <- c(
  "food", "tex", "wap", "lea", "lum", "ppp", "p_c", "chm", "bph", "rpp",
  "nmm", "i_s", "nfm", "fmp", "ele", "eeq", "ome", "mvh", "otn", "omf"
)

# ------------------------------------------------------------------------------
# models
# ------------------------------------------------------------------------------

# all three models ship with teems. format: database format the model reads;
# runs: result directory name and ems_model() coefficient assignments for each
# variant
MODELS <- list(
  GTAPv6 = list(
    format = "GTAPv6",
    intertemporal = FALSE,
    runs = list(GTAPv6 = list())
  ),
  GTAPv7 = list(
    format = "GTAPv7",
    intertemporal = FALSE,
    runs = list(GTAPv7 = list())
  ),
  # GTAP-RE version 2 (GTAPv7.1 core) shipped with teems
  `GTAP-RE` = list(
    format = "GTAPv7",
    intertemporal = TRUE,
    runs = list(
      `GTAP-RE_rational` = list(),
      `GTAP-RE_recursive` = list(REDELTA = 0)
    )
  )
)

# set and index names of the shocked variables by database format
NAMES <- list(
  GTAPv6 = list(
    sector_sets = "TRAD_COMM", endw_set = "ENDW_COMM",
    acts = "PROD_COMMj", endw = "ENDW_COMMi",
    labour_var = "qo", labour_idx = "NSAV_COMMi", cgds = "cgds"
  ),
  GTAPv7 = list(
    sector_sets = c("COMM", "ACTS"), endw_set = "ENDW",
    acts = "ACTSa", endw = "ENDWe",
    labour_var = "qe", labour_idx = "ENDWMSe", cgds = NULL
  )
)

# ------------------------------------------------------------------------------
# scenarios (protocol Tables 2.1 and 2.2)
# ------------------------------------------------------------------------------

# forcings: the first is the primary specification (hash 0); other: the shock
# to sectors outside `target` paired with each forcing
SCENARIOS <- list(
  `1-p` = list(
    type = "sector_endw", map = SECTOR_MAP, region = "esp", endw = LABOUR,
    target = c(AGRI, "cns"), timing = "persistent",
    forcings = c(-4, -1, -2, -6, -8, -10),
    other = c(-4, -1, -2, -6, -8, -10) * 0.25
  ),
  `1-t` = list(
    type = "sector_endw", map = SECTOR_MAP, region = "esp", endw = LABOUR,
    target = c(AGRI, "cns"), timing = "temporary",
    forcings = c(-4, -1, -2, -6, -8, -10),
    other = c(-1, 0, -2, -3, -4, -5)
  ),
  `1-o2-p` = list(
    type = "labour_supply", map = SECTOR_MAP, region = "esp",
    timing = "persistent",
    forcings = c(-1, -0.25, -0.5, -1.5, -2, -2.5)
  ),
  `1-o2-t` = list(
    type = "labour_supply", map = SECTOR_MAP, region = "esp",
    timing = "temporary",
    forcings = c(-1, -0.25, -0.5, -1.5, -2, -2.5)
  ),
  `2-p` = list(
    type = "output", map = SECTOR_MAP, region = "fra",
    target = AGRI, timing = "persistent",
    forcings = c(4, -40, -20, 20, 40)
  ),
  `2-t` = list(
    type = "output", map = SECTOR_MAP, region = "fra",
    target = AGRI, timing = "temporary",
    forcings = c(4, -40, -20, 20, 40)
  ),
  `3-p` = list(
    type = "sector_endw", map = SECTOR_MAP, region = "deu",
    endw = "capital", target = MANUF, timing = "persistent",
    forcings = c(-5, -1, -2.5, -7.5, -10),
    other = 0
  ),
  `3-t` = list(
    type = "sector_endw", map = SECTOR_MAP, region = "deu",
    endw = "capital", target = MANUF, timing = "temporary",
    forcings = c(-5, -1, -2.5, -7.5, -10),
    other = 0
  )
)

# sensitivity: primary runs of pairs 1 and 2 with livestock treated as
# non-agriculture, as in the earlier runs
LIVESTOCK_NONAG <- c("1-p", "1-t", "2-p", "2-t")

scenario_models <- function(scenario) {
  # a persistent shock needs an intertemporal model
  if (endsWith(scenario, "-p")) {
    names(Filter(\(m) m$intertemporal, MODELS))
  } else {
    names(MODELS)
  }
}

run_hash <- function(f, primary) {
  if (f == primary) {
    return("0")
  }
  paste0(ifelse(f < 0, "n", "p"), abs(f))
}

# ------------------------------------------------------------------------------
# shocks
# ------------------------------------------------------------------------------

# a full shock table for one forcing; zeros everywhere but the shocked tuples
build_shock <- function(sc, model, main, other, livestock_ag = TRUE) {
  m <- MODELS[[model]]
  nm <- NAMES[[m$format]]
  acts <- c(sector_set(sc$map), nm$cgds)
  target <- sc$target

  if (!livestock_ag) {
    target <- setdiff(target, "livestock")
  }

  cols <- switch(sc$type,
    sector_endw = setNames(list(ENDW, acts, REG), c(nm$endw, nm$acts, "REGr")),
    output = setNames(list(acts, REG), c(nm$acts, "REGr")),
    labour_supply = setNames(list(LABOUR, REG), c(nm$labour_idx, "REGr"))
  )

  if (m$intertemporal) {
    cols$Year <- ALLTIME
  }

  shk <- do.call(CJ, cols)
  shk[, Value := 0]

  hit <- shk$REGr == sc$region
  if (m$intertemporal) {
    hit <- hit & if (sc$timing == "persistent") shk$Year != ALLTIME[1] else shk$Year == ALLTIME[2]
  }

  if (sc$type == "labour_supply") {
    shk[hit, Value := main]
  } else {
    a <- shk[[nm$acts]]
    if (sc$type == "sector_endw") {
      hit <- hit & shk[[nm$endw]] %in% sc$endw
    }

    # capital goods (cgds) are never shocked
    shk[hit & a %in% target, Value := main]
    if (sc$type == "sector_endw") {
      shk[hit & !a %in% c(target, nm$cgds), Value := other]
    }
  }

  var <- switch(sc$type,
    sector_endw = "afeall",
    output = "aoall",
    labour_supply = nm$labour_var
  )

  list(var = var, input = shk)
}

# ------------------------------------------------------------------------------
# jobs
# ------------------------------------------------------------------------------

# one job per model run x forcing (plus the livestock sensitivity runs)
macromip_jobs <- function(model, scenario) {
  sc <- SCENARIOS[[scenario]]
  m <- MODELS[[model]]
  stopifnot(!is.null(sc), !is.null(m))
  stopifnot(model %in% scenario_models(scenario))

  primary <- sc$forcings[1]
  other <- rep_len(sc$other %||% 0, length(sc$forcings))

  specs <- lapply(seq_along(sc$forcings), \(i) {
    list(
      main = sc$forcings[i], other = other[i], livestock_ag = TRUE,
      sub = paste(scenario, SFID, run_hash(sc$forcings[i], primary), sep = "-")
    )
  })

  if (scenario %in% LIVESTOCK_NONAG) {
    specs <- c(specs, list(list(
      main = primary, other = other[1], livestock_ag = FALSE,
      sub = paste(scenario, SFID, "0", "lvsnonag", sep = "-")
    )))
  }

  jobs <- list()
  for (run in names(m$runs)) {
    for (s in specs) {
      jobs[[length(jobs) + 1]] <- list(
        model = model,
        run = run,
        scenario = scenario,
        sub = s$sub,
        map = sc$map,
        forcing = s$main,
        shock = build_shock(sc, model, s$main, s$other, s$livestock_ag),
        method = if (m$intertemporal && abs(s$main) > RK_ABOVE) "DoPri54" else "Gragg",
        # Gragg subintervals for the large agricultural productivity shocks
        n_subintervals = max(1L, as.integer(ceiling(abs(s$main) / 10)))
      )
    }
  }

  jobs
}

# ------------------------------------------------------------------------------
# data and models (loaded once in the parent process, shared by forked jobs)
# ------------------------------------------------------------------------------

.cache <- new.env()

macromip_data <- function(model, map) {
  m <- MODELS[[model]]
  key <- paste(m$format, map, m$intertemporal, sep = "|")

  if (is.null(.cache[[key]])) {
    nm <- NAMES[[m$format]]

    if (m$format == "GTAPv6") {
      if (is.null(.cache$v6)) {
        .cache$v6 <- GTAP_convert(DAT, PAR, SET, target = "GTAPv6")
      }
      inputs <- .cache$v6[c("dat", "par", "set")]
    } else {
      inputs <- list(DAT, PAR, SET)
    }

    set_maps <- c(
      REG = REG_MAP,
      setNames(rep(file.path("mappings", paste0(map, ".csv")), length(nm$sector_sets)), nm$sector_sets),
      setNames("./mappings/labor_diff.csv", nm$endw_set)
    )

    .cache[[key]] <- do.call(ems_data, c(
      list(
        dat_input = inputs[[1]],
        par_input = inputs[[2]],
        set_input = inputs[[3]],
        time_steps = if (m$intertemporal) ALLTIME
      ),
      as.list(set_maps)
    ))
  }

  .cache[[key]]
}

macromip_model <- function(model, run) {
  key <- paste("model", run, sep = "|")

  if (is.null(.cache[[key]])) {
    m <- MODELS[[model]]

    # the model and closure files shipped with teems
    dir <- file.path(tempdir(), "models")
    dir.create(dir, showWarnings = FALSE)
    files <- ems_example(model, dir)

    .cache[[key]] <- do.call(ems_model, c(
      list(
        model_file = files[["model_file"]],
        closure_file = files[["closure_file"]]
      ),
      m$runs[[run]]
    ))
  }

  .cache[[key]]
}

# ------------------------------------------------------------------------------
# solving
# ------------------------------------------------------------------------------

solve_job <- function(job, cmf_path, n_subintervals) {
  m <- MODELS[[job$model]]

  if (job$method == "DoPri54") {
    ems_RK(
      cmf_path = cmf_path,
      solution_method = "DoPri54",
      matrix_method = "SBBD",
      n_tasks = N_TASKS,
      n_threads = N_THREADS
    )
  } else if (m$intertemporal) {
    ems_solve(
      cmf_path = cmf_path,
      matrix_method = "SBBD",
      n_tasks = N_TASKS,
      n_threads = N_THREADS,
      solution_method = "Gragg",
      steps = c(2L, 4L, 6L),
      n_subintervals = n_subintervals
    )
  } else {
    ems_solve(
      cmf_path = cmf_path,
      matrix_method = "LU",
      n_threads = N_TASKS * N_THREADS,
      solution_method = "Gragg",
      steps = c(2L, 4L, 6L),
      n_subintervals = n_subintervals
    )
  }
}

# from the solver log: Gragg, the share of results accurate to 4 significant
# figures; DoPri54, the estimated accuracy face value out of 10 (an indicator)
run_accuracy <- function(run_dir) {
  diag <- readLines(file.path(run_dir, "model_diagnostics.txt"), warn = FALSE)
  pattern <- "(?<=Accuracy \\(solution, 4 figures\\): |Estimated accuracy face value )[0-9.]+"
  acc <- regmatches(diag, regexpr(pattern, diag, perl = TRUE))
  if (length(acc)) as.numeric(acc[length(acc)]) else NA_real_
}

# the shocked tuples must come back unchanged
check_shock <- function(job, outputs) {
  input <- job$shock$input
  idx <- setdiff(names(input), "Value")
  out <- as.data.table(outputs$dat[[job$shock$var]])
  cmp <- merge(input, out[, c(idx, "Value"), with = FALSE], by = idx, all.x = TRUE)
  isTRUE(all.equal(cmp$Value.x, cmp$Value.y, tolerance = 1e-6))
}

run_job <- function(job) {
  run_dir <- file.path("runs", job$run, job$sub)
  result_dir <- file.path("results", job$run, job$sub)
  result_file <- file.path(result_dir, "results.RDS")
  status <- list(run = job$run, sub = job$sub, forcing = job$forcing)

  if (file.exists(result_file) && !OVERWRITE) {
    return(c(status, status = "skipped"))
  }

  unlink(run_dir, recursive = TRUE)
  dir.create(run_dir, recursive = TRUE)

  log <- file(file.path(run_dir, "macromip.log"), open = "wt")
  sink(log)
  sink(log, type = "message")
  on.exit({
    sink(type = "message")
    sink()
    close(log)
  })

  t0 <- Sys.time()
  res <- tryCatch(
    {
      ems_option_set(tempdir = normalizePath(run_dir))

      cmf_path <- ems_deploy(
        .data = macromip_data(job$model, job$map),
        model = macromip_model(job$model, job$run),
        shock = ems_custom_shock(var = job$shock$var, input = job$shock$input)
      )

      n_sub <- job$n_subintervals
      repeat {
        outputs <- solve_job(job, cmf_path, n_sub)
        accuracy <- run_accuracy(run_dir)
        if (job$method != "Gragg" || is.na(accuracy) || accuracy >= ACCURACY_MIN ||
          n_sub >= MAX_SUBINTERVALS) {
          break
        }
        message("accuracy ", accuracy, "% with ", n_sub, " subinterval(s); retrying")
        n_sub <- n_sub * 2L
      }

      if (!check_shock(job, outputs)) {
        stop("shock values not recovered from the solution")
      }

      dir.create(result_dir, recursive = TRUE, showWarnings = FALSE)
      file.copy(file.path(run_dir, "model_diagnostics.txt"), result_dir, overwrite = TRUE)
      saveRDS(outputs, result_file)

      list(
        status = "ok", method = job$method, accuracy = accuracy,
        n_subintervals = if (job$method == "Gragg") n_sub else NA_integer_
      )
    },
    error = function(e) {
      message("ERROR: ", conditionMessage(e))
      list(status = "failed", error = conditionMessage(e))
    }
  )

  c(status, res, minutes = round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 1))
}

# everything a solve needs beyond the R packages: stop with all that is
# missing, before any data is loaded
check_setup <- function() {
  problems <- character()

  paths <- Sys.getenv(GTAP_ENV)
  for (v in names(paths)) {
    if (!nzchar(paths[[v]])) {
      problems <- c(problems, paste0("environment variable ", v, " is not set"))
    } else if (!file.exists(paths[[v]])) {
      problems <- c(problems, paste0(v, " points to a missing file: ", paths[[v]]))
    }
  }

  image <- paste0("teems:", ems_option_get("docker_tag"))
  if (!nzchar(Sys.which("docker"))) {
    problems <- c(problems, "docker is not on the PATH")
  } else if (system2("docker", c("image", "inspect", image), stdout = FALSE, stderr = FALSE) != 0) {
    problems <- c(problems, paste0(
      "Docker image ", image, " not found (or the Docker daemon is not reachable)"
    ))
  }

  if (.Platform$OS.type != "unix") {
    problems <- c(problems, "jobs are forked, which needs Linux or macOS (on Windows use WSL)")
  }

  if (length(problems)) {
    stop("setup is incomplete, see \"Setup\" in README.md:\n",
      paste0("  - ", problems, collapse = "\n"),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

# run jobs WORKERS at a time; each job is a forked process with its own solve
run_jobs <- function(jobs) {
  check_setup()

  # load data and models before forking so the jobs share them
  for (job in jobs) {
    macromip_data(job$model, job$map)
    macromip_model(job$model, job$run)
  }

  message(length(jobs), " job(s), ", WORKERS, " at a time")
  status <- parallel::mclapply(jobs, run_job,
    mc.cores = WORKERS,
    mc.preschedule = FALSE
  )

  status <- rbindlist(lapply(seq_along(status), \(i) {
    s <- status[[i]]
    if (inherits(s, "try-error")) {
      s <- list(run = jobs[[i]]$run, sub = jobs[[i]]$sub, status = "failed", error = as.character(s))
    }
    as.data.table(s)
  }), fill = TRUE)

  dir.create("results", showWarnings = FALSE)
  log_file <- file.path("results", format(Sys.time(), "run_log_%Y%m%d_%H%M%S.csv"))
  fwrite(status, log_file)
  print(status)

  if (any(status$status == "failed")) {
    warning(sum(status$status == "failed"), " job(s) failed, see ", log_file)
  }

  invisible(status)
}
