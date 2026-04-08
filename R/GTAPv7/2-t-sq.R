require(teems)
require(data.table)

# mappings
REG <- data.table::fread("./mappings/euWB7.csv")
sectors <- data.table::fread("./mappings/agriculture.csv")
ENDW <- data.table::fread("./mappings/labor_diff.csv")

# load GTAP HAR files, apply set mappings, and aggregate data
.data <- ems_data(
  dat_input = Sys.getenv("GTAP11c_dat"),
  par_input = Sys.getenv("GTAP11c_par"),
  set_input = Sys.getenv("GTAP11c_set"),
  REG = "./mappings/euWB7.csv",
  COMM = "./mappings/agriculture.csv",
  ACTS = "./mappings/agriculture.csv",
  ENDW = "./mappings/labor_diff.csv"
)

# scenario
scenario <- "2-t"
forcings <- c(4, -40, -20, 20, 40)
sfid <- "sq"

# shock base
aoall <- data.table::CJ(
  ACTSa = unique(sectors$mapping),
  REGr = unique(REG$mapping),
  Value = 0
)

source_model <- "GTAPv7"
model_files <- ems_example(source_model)

model <- ems_model(
  model_file = model_files[["model_file"]],
  closure_file = model_files[["closure_file"]],
  var_omit = c(
    "atall",
    "avaall",
    "tfe",
    "tfd",
    "tfm",
    "tgd",
    "tgm",
    "tid",
    "tim"
  )
)

write_dir <- file.path(".", "runs", source_model)

if (!dir.exists(write_dir)) {
  dir.create(write_dir, recursive = T)
}

for (f in seq_along(forcings)) {
  main_f <- forcings[f]
  hash <- ifelse(main_f == 4, 0, main_f)

  if (hash < 0) {
    hash <- paste0("n", abs(hash))
  } else if (hash > 0) {
    hash <- paste0("p", hash)
  }

  write_sub_dir <- paste(scenario, sfid, hash, sep = "-")

  # set the output subdirectory name within write_dir
  ems_option_set(write_sub_dir = write_sub_dir)

  # shocks
  aoall[!ACTSa %in% c("svces", "food", "mnfcs", "livestock") &
    REGr == "fra", Value := main_f]

  # load shock
  shock <- ems_custom_shock(
    var = "aoall",
    input = aoall
  )

  # validate inputs, write solver files, and return the CMF path
  cmf_path <- ems_deploy(
    write_dir = write_dir,
    .data = .data,
    model = model,
    shock = shock
  )

  # run the Docker-based solver and parse results
  n_subintervals <- 1

  if (abs(main_f) > 10) {
    n_subintervals <- ceiling(abs(main_f) / 10)
  }

  outputs <- ems_solve(
    cmf_path = cmf_path,
    matrix_method = "LU",
    solution_method = "mod_midpoint",
    steps = c(2, 4, 6),
    n_subintervals = n_subintervals,
    laA = 400
  )

  if (!all.equal(aoall,
    outputs$dat$aoall,
    check.attributes = FALSE,
    tolerance = 1e-6
  )) {
    stop(paste("Error on ", write_sub_dir))
  }

  result_dir <- file.path("results", source_model, write_sub_dir)

  if (!dir.exists(result_dir)) {
    dir.create(result_dir, recursive = TRUE)
  }

  file.copy(file.path(write_dir, write_sub_dir, "model_diagnostics.txt"), result_dir)
  saveRDS(outputs, file.path(result_dir, "results.RDS"))
  rm(outputs)
}