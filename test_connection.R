library(dplyr)
library(dbplyr)
library(DatabaseConnector)

con <- connect(dbms = "postgresql",
               server = "ohdsi-lab-redshift-cluster-prod.clsyktjhufn7.us-east-1.redshift.amazonaws.com/ohdsi_lab",
               port = 5439,
               user = "usr9",
               password = "2H2pS9G6ShKq")

person <- tbl(con, inDatabaseSchema("omop_cdm_53_pmtx_202203", "person"))

tally(person) # 34808145
demographics <- count(person, gender_concept_id, ethnicity_concept_id, race_concept_id)
demographics # only gender, matches what atlas says

disconnect(con)
