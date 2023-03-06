library(DatabaseConnector)
library(dplyr)
library(dbplyr)

con <- connect(dbms = "redshift",
               connectionString = "jdbc:redshift://ohdsi-lab-redshift-cluster-prod.clsyktjhufn7.us-east-1.redshift.amazonaws.com:5439/ohdsi_lab",
               user = keyring::key_get("redshiftUser"),
               password = keyring::key_get("redshiftPassword"))


obs_per = tbl(con, "omop_cdm_53_pmtx_202203.observation_period")

person = tbl(con, "omop_cdm_53_pmtx_202203.person") 

death = tbl(con, "omop_cdm_53_pmtx_202203.death") 

person %>%
  inner_join(obs_per, by = "person_id")  %>%
  inner_join(death, by = "person_id")

person %>%
  inner_join(obs_per, by = "person_id")  %>%
  inner_join(death, by = "person_id") %>%
  show_query()


install.packages('RPostgres')

library(RPostgres)
dbname = ohdsi_lab
host = "jdbc:redshift://ohdsi-lab-redshift-cluster-prod.clsyktjhufn7.us-east-1.redshift.amazonaws.com"
port = 5439

pconn_r <- dbConnect(RPostgres::Postgres(),
                     host = host,
                     port = port,
                     user = keyring::key_get("redshiftUser"),
                     password = keyring::key_get("redshiftPassword"),
                     dbname = dbname,
                     sslmode='require')