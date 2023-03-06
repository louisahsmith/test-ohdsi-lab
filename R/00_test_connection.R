# load packages
library(dplyr)
library(dbplyr)
library(DatabaseConnector) # make sure 6.0 or later

# run the following one time and set these per the email
# keyring::key_set("redshiftUser")
# keyring::key_set("redshiftPassword")

con <- connect(dbms = "redshift",
               server = "ohdsi-lab-redshift-cluster-prod.clsyktjhufn7.us-east-1.redshift.amazonaws.com/ohdsi_lab",
               port = 5439,
               user = keyring::key_get("redshiftUser"),
               password = keyring::key_get("redshiftPassword")
)

person <- tbl(con, inDatabaseSchema("omop_cdm_53_pmtx_202203", "person"))

tally(person) # 34808145
demographics <- count(person, gender_concept_id, ethnicity_concept_id, race_concept_id)
demographics # only gender, matches what atlas says

disconnect(con)
