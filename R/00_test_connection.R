library(dplyr)
library(dbplyr)
library(DatabaseConnector)

con <- connect(dbms = "redshift",
               server = "ohdsi-lab-redshift-cluster-prod.clsyktjhufn7.us-east-1.redshift.amazonaws.com/ohdsi_lab",
               port = 5439,
               user = keyring::key_get("lab_user"),
               password = keyring::key_get("lab_password")
)

person <- tbl(con, inDatabaseSchema("omop_cdm_53_pmtx_202203", "person"))

tally(person) # 34808145
demographics <- count(person, gender_concept_id, ethnicity_concept_id, race_concept_id)
demographics # only gender, matches what atlas says

disconnect(con)
