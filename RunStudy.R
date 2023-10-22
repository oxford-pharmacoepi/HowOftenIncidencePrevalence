# create log file ----
resultsFolder <- here("Results")
logFile <- here(resultsFolder, "log.txt")
if (file.exists(logFile)) {
  unlink(logFile)
}
logger <- create.logger()
logfile(logger) <- logFile
level(logger) <- "INFO"
info(logger, "LOGGER CREATED")

# cdm snapshot ----
info(logger, "CDM SNAPSHOT")
write_csv(snapshot(cdm), here(resultsFolder, "cdmSnapshot.csv"))
info(logger, "CDM SNAPSHOT DONE")

# instantiate cohorts ----
info(logger, "INSTANTIATE TARGET COHORT")
targetCohorts <- readCohortSet(here("Cohorts", "Target"))
cdm <- generateCohortSet(
  cdm = cdm,
  cohortSet = cohorts,
  name = "target_cohort",
  overwrite = TRUE
)
info(logger, "TARGET COHORT CREATED")

info(logger, "INSTANTIATE OUTCOME COHORT")
targetCohorts <- readCohortSet(here("Cohorts", "Outcome"))
cdm <- generateCohortSet(
  cdm = cdm,
  cohortSet = cohorts,
  name = "outcome_cohort",
  overwrite = TRUE
)
info(logger, "OUTCOME COHORT CREATED")

# compute incidence prevalence ----
info(logger, "INSTANTIATE DENOMINATOR COHORT")
cdm <- generateDenominatorCohortSet(
  cdm = cdm,
  name = "denominator",
  cohortDateRange = as.Date(c("2002-01-01", "2022-12-31")),
  sex = c("Both", "Male", "Female"),
  ageGroup = list(
    c(0, Inf), c(0, 2), c(3, 12), c(13, 17), c(18, 29), c(30, 39), c(40, 49),
    c(50, 59), c(60, 69), c(70, 79), c(80, 89), c(90, Inf)
  ),
  targetCohortTable = "target_cohort"
)
info(logger, "DENOMINATOR COHORT CREATED")

info(logger, "COMPUTE INCIDENCE")
inc <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator",
  outcomeTable = "outcome_cohort",
  interval = "overall",
  minCellCount = minCellCount
)
write_csv(
  x = inc, file = here(resultsFolder, paste0(cdmName(cdm), "_incidence.csv"))
)
info(logger, "INCIDENCE SAVED")

# create zip file ----
info(logger, "EXPORT RESULTS")
zip(
  zipfile = here(resultsFolder, "Results.zip"),
  files = list.files(resultsFolder),
  root = resultsFolder
)