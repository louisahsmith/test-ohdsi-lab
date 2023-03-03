library(CohortGenerator)
library(DatabaseConnector)

connectionDetails <- createConnectionDetails(dbms = "redshift",
                                             server = "ohdsi-lab-redshift-cluster-prod.clsyktjhufn7.us-east-1.redshift.amazonaws.com/ohdsi_lab",
                                             port = 5439,
                                             user = keyring::key_get("redshiftUser"),
                                             password = keyring::key_get("redshiftPassword")
)

# my tables on the database
mySchema <- paste0("work_", keyring::key_get("redshiftUser"))

# use webapi to pull cohort definition from atlas
cohortIds <- 2 # cohort ids from atlas
baseUrl <- "https://atlas.roux-ohdsi-prod.aws.northeastern.edu/WebAPI"

ROhdsiWebApi::authorizeWebApi(baseUrl, 
                              authMethod = "db", 
                              webApiUsername = keyring::key_get("redshiftUser"), 
                              webApiPassword = keyring::key_get("redshiftPassword"))

cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(baseUrl = baseUrl,
                                                               cohortIds = cohortIds)

# choose what the table names should be called that hold the cohort and 
# statistics about it
cohortTableNames <- getCohortTableNames(cohortTable = "endometriosis")

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

