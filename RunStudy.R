# create log file ----
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

# compute incidence prevalence ----

# create zip file ----
info(logger, "EXPORT RESULTS")
zip(
  zipfile = here(resultsFolder, "Results.zip"),
  files = list.files(resultsFolder),
  root = resultsFolder
)
