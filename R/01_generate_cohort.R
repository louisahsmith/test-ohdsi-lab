# Before you do this, do some stuff in ATLAS
# - Build the cohort in atlas
# - Build a concept set (you can optimize to help)
# - Use the concept set to create a cohort definition
# - Export the json to a .json text file into Studio


library(CohortGenerator)
library(DatabaseConnector)
library(dplyr)
library(dbplyr)
library(magrittr)
library(magrittr)

connectionDetails <- createConnectionDetails(dbms = "redshift",
                                             server = "ohdsi-lab-redshift-cluster-prod.clsyktjhufn7.us-east-1.redshift.amazonaws.com/ohdsi_lab",
                                             port = 5439,
                                             user = keyring::key_get("redshiftUser"),
                                             password = keyring::key_get("redshiftPassword"))

# use webapi to pull cohort definition from atlas
cohortIds <- 398# cohort ids from atlas
baseUrl <- "https://atlas.roux-ohdsi-prod.aws.northeastern.edu/WebAPI"

ROhdsiWebApi::authorizeWebApi(baseUrl, 
                              authMethod = "db", 
                              webApiUsername = keyring::key_get("redshiftUser"), 
                              webApiPassword = keyring::key_get("redshiftPassword"))

cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(baseUrl = baseUrl,
                                                               cohortIds = cohortIds)

# my tables on the database
mySchema <- paste0("work_", keyring::key_get("redshiftUser"))

# this directory contains json files with the cohort definition copy-pasted from Atlas
# cohortDefinitionSet <- CDMConnector::readCohortSet("cohorts")

cohortDefinitionSet

# choose what the table names should be called that hold the cohort and 
# statistics about it
cohortTableNames <- getCohortTableNames(cohortTable = "hiv_pos")

# create empty tables in the {mySchema}.cohort table
createCohortTables(connectionDetails = connectionDetails,
                   cohortTableNames = cohortTableNames,
                   cohortDatabaseSchema = mySchema)

# find people matching cohort definition
cohortsGenerated <- generateCohortSet(connectionDetails = connectionDetails,
                                      cdmDatabaseSchema = "omop_cdm_53_pmtx_202203",
                                      cohortDatabaseSchema = mySchema,
                                      cohortTableNames = cohortTableNames,
                                      cohortDefinitionSet = cohortDefinitionSet)
# this is just a record of the cohort generated
