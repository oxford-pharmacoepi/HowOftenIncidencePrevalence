renv::activate()
renv::restore()

library(DBI)
library(CDMConnector)
library(IncidencePrevalence)
library(dplyr)
library(here)
library(log4r)
library(readr)
library(zip)

# Connection details
# Examples how to create a connection:
# https://darwin-eu.github.io/CDMConnector/articles/a04_DBI_connection_examples.html
db <- dbConnect("...")

# connection details
databaseAcronym <- "..." # acronym for the database in capital letters
cdmDatabaseSchema <- "..." # schema where cdm tables are
resultsDatabaseSchema <- "..." # schema where you have write permission
resultsStem <- "..." # please provide an stem to write permanent tables
minCellCount <- 5 # minimum cell counts to be exported

cdm <- cdmFromCon(
  con = db,
  cdmSchema = c(schema = cdmDatabaseSchema),
  writeSchema = c(schema = resultsDatabaseSchema, prefix = resultsStem),
  cdmName = databaseAcronym
)

# Count number of individuals in database to see if we connected correctly
cdm$person %>%
  tally() %>%
  computeQuery()

# run analysis
source("RunStudy.R")

# happy for the long journey
cat("Study finished\n-Please see the zip folder created with all the generated csv files")
