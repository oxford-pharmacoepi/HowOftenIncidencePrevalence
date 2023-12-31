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
snapshot(cdm) %>%
  mutate(result_type = "CDM snapshot") %>%
  write_csv(here(resultsFolder, paste0(cdmName(cdm), "_snapshot.csv")))
info(logger, "CDM SNAPSHOT DONE")

# instantiate cohorts ----
info(logger, "INSTANTIATE TARGET COHORT")
targetCohorts <- readCohortSet(here("Cohorts", "Target"))
cdm <- generateCohortSet(
  cdm = cdm,
  cohortSet = targetCohorts,
  name = "target_cohort",
  overwrite = TRUE
)
info(logger, "TARGET COHORT CREATED")

info(logger, "INSTANTIATE OUTCOME TARGET COHORT")
outcomeCohorts <- readCohortSet(here("Cohorts", "OutcomeTarget"))
cdm <- generateCohortSet(
  cdm = cdm,
  cohortSet = outcomeCohorts,
  name = "outcome_target",
  overwrite = TRUE
)
info(logger, "OUTCOME TARGET COHORT CREATED")

info(logger, "INSTANTIATE ASTHMA COHORT")
outcomeCohorts <- readCohortSet(here("Cohorts", "OutcomeAsthma"))
cdm <- generateCohortSet(
  cdm = cdm,
  cohortSet = outcomeCohorts,
  name = "outcome_asthma",
  overwrite = TRUE
)
info(logger, "OUTCOME ASTHMA COHORT CREATED")

# compute incidence prevalence ----
info(logger, "INSTANTIATE DENOMINATOR COHORT")
cdm <- generateDenominatorCohortSet(
  cdm = cdm,
  name = "denominator",
  cohortDateRange = as.Date(c("2002-01-01", "2022-12-31")),
  sex = c("Both", "Male", "Female"),
  ageGroup = list(
    c(0, 150), c(0, 2), c(3, 12), c(13, 17), c(18, 29), c(30, 39), c(40, 49),
    c(50, 59), c(60, 69), c(70, 79), c(80, 89), c(90, 150)
  ),
  overwrite = TRUE
)
info(logger, "DENOMINATOR COHORT CREATED")

info(logger, "COMPUTE INCIDENCE")
inc <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator",
  outcomeTable = "outcome_asthma",
  interval = "overall",
  minCellCount = minCellCount
) %>%
  mutate(result_type = "Incidence estimates")
write_csv(
  x = inc, file = here(resultsFolder, paste0(cdmName(cdm), "_incidence_asthma.csv"))
)
info(logger, "INCIDENCE SAVED")

# compute incidence prevalence target ----
info(logger, "INSTANTIATE DENOMINATOR COHORT")
cdm <- generateDenominatorCohortSet(
  cdm = cdm,
  name = "denominator_target",
  cohortDateRange = as.Date(c("2002-01-01", "2022-12-31")),
  sex = c("Both", "Male", "Female"),
  ageGroup = list(
    c(0, 150), c(0, 2), c(3, 12), c(13, 17), c(18, 29), c(30, 39), c(40, 49),
    c(50, 59), c(60, 69), c(70, 79), c(80, 89), c(90, 150)
  ),
  targetCohortTable = "target_cohort",
  overwrite = TRUE
)
info(logger, "DENOMINATOR COHORT CREATED")

info(logger, "COMPUTE INCIDENCE")
inc <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator_target",
  outcomeTable = "outcome_target",
  interval = "overall",
  minCellCount = minCellCount
) %>%
  mutate(result_type = "Incidence estimates")
write_csv(
  x = inc, file = here(resultsFolder, paste0(cdmName(cdm), "_incidence_target.csv"))
)
info(logger, "INCIDENCE SAVED")


# export cohort counts ----
exportCohort <- function(cohort, tblName = attr(cohort, "tbl_name")) {
  x <- cohortSet(cohort) %>%
    inner_join(cohortAttrition(cohort), by = "cohort_definition_id") %>%
    mutate(
      cdm_name = cdmName(attr(cohort, "cdm_reference")),
      result_type = "Cohort details",
      cohort_table_name = tblName
    )
  return(x)
}
for (nm in c("target_cohort", "outcome_target", "outcome_asthma", "denominator", "denominator_target")) {
  write_csv(
    x = exportCohort(cdm[[nm]], nm),
    file = here(resultsFolder, paste0(cdmName(cdm), "_counts_", nm, ".csv"))
  )
}

# create zip file ----
info(logger, "EXPORT RESULTS")
zip(
  zipfile = here(resultsFolder, "Results.zip"),
  files = list.files(resultsFolder),
  root = resultsFolder
)
