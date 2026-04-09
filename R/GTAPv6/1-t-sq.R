require(teems)
require(data.table)

# mappings
REG <- data.table::fread("./mappings/euWB7.csv")
sectors <- data.table::fread("./mappings/agri_cns.csv")
ENDW <- data.table::fread("./mappings/labor_diff.csv")

# load GTAP HAR files, apply set mappings, and aggregate data
.data <- ems_data(
  dat_input = Sys.getenv("GTAP11c_dat"),
  par_input = Sys.getenv("GTAP11c_par"),
  set_input = Sys.getenv("GTAP11c_set"),
  REG = "./mappings/euWB7.csv",
  TRAD_COMM = "./mappings/agri_cns.csv",
  ENDW_COMM = "./mappings/labor_diff.csv",
  target_format = "GTAPv6"
)

# scenario
scenario <- "1-t"
forcings <- c(4, 1, 2, 6, 8, 10) * -1
sub_forcings <- c(1, 0, 2, 3, 4, 5) * -1
sfid <- "sq"

# shock base
afeall <- data.table::CJ(
  ENDW_COMMi = unique(ENDW$mapping),
  PROD_COMMj = c(unique(sectors$mapping), "zcgds"),
  REGr = unique(REG$mapping),
  Value = 0
)

source_model <- "GTAPv6"
model_files <- ems_example(source_model)

model <- ems_model(
  model_file = model_files[["model_file"]],
  closure_file = model_files[["closure_file"]],
  var_omit = c(
    "atall",
    "tfd",
    "avaall",
    "tf",
    "tfm",
    "tgd",
    "tgm",
    "tpd",
    "tpm"
  )
)

write_dir <- file.path(".", "runs", source_model)

if (!dir.exists(write_dir)) {
  dir.create(write_dir, recursive = T)
}

for (f in seq_along(forcings)) {
  main_f <- forcings[f]
  hash <- ifelse(main_f == -4, 0, main_f)

  if (hash < 0) {
    hash <- paste0("n", abs(hash))
  } else if (hash > 0) {
    hash <- paste0("p", hash)
  }

  sub_f <- sub_forcings[f]
  write_sub_dir <- paste(scenario, sfid, hash, sep = "-")

  # set the output subdirectory name within write_dir
  ems_option_set(write_sub_dir = write_sub_dir)

  # shocks
  afeall[ENDW_COMMi %in% c("unsklab", "sklab") &
    PROD_COMMj %in% c("svces", "food", "mnfcs", "livestock", "zcgds") &
    REGr == "esp", Value := sub_f]
  afeall[ENDW_COMMi %in% c("unsklab", "sklab") &
    !PROD_COMMj %in% c("svces", "food", "mnfcs", "livestock", "zcgds") &
    REGr == "esp", Value := main_f]

  # load shock
  shock <- ems_custom_shock(
    var = "afeall",
    input = afeall
  )

  # validate inputs, write solver files, and return the CMF path
  cmf_path <- ems_deploy(
    write_dir = write_dir,
    .data = .data,
    model = model,
    shock = shock
  )

  # run the Docker-based solver and parse results
  outputs <- ems_solve(
    cmf_path = cmf_path,
    matrix_method = "LU",
    solution_method = "mod_midpoint",
    steps = c(2, 4, 6)
  )

  if (!all.equal(afeall,
    outputs$dat$afeall,
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
