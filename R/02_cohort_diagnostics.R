library(DatabaseConnector)
library(CohortDiagnostics)

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

# run diagnostics on this cohort
# the export folder now has stuff that's safe to take off the server
# takes about 30 mins
executeDiagnostics(cohortDefinitionSet,
                   connectionDetails = connectionDetails,
                   cohortTable = "endometriosis",
                   cohortDatabaseSchema = mySchema,
                   cdmDatabaseSchema = "omop_cdm_53_pmtx_202203",
                   exportFolder = "export",
                   databaseId = "Pharmetrics",
                   minCellCount = 5
)

createMergedResultsFile(dataFolder = "export", 
                        sqliteDbPath = "endometriosisDiagnositics.sqlite")

launchDiagnosticsExplorer("endometriosisDiagnositics.sqlite")
