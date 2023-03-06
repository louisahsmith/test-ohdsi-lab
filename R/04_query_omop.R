

library(DatabaseConnector)
library(dplyr)
library(dbplyr)
library(magrittr)
# remotes::install_github("roux-ohdsi/aouFI")
library(aouFI)

con <- connect(dbms = "redshift",
               connectionString = "jdbc:redshift://ohdsi-lab-redshift-cluster-prod.clsyktjhufn7.us-east-1.redshift.amazonaws.com:5439/ohdsi_lab",
               user = keyring::key_get("redshiftUser"),
               password = keyring::key_get("redshiftPassword"))



tbl(con, "work_usr12.hiv_pos") %>%
  distinct(person_id = subject_id) -> eligible



dev %>% collect()

test = omop2fi(con = con, eligible = eligible, index = "vafi", schema = "omop_cdm_53_pmtx_202203")

test %>% collect() -> fi

querySql(con, "ROLLBACK")


test %>% head()


tbl(con, "omop_cdm_53_pmtx_202203.concept") %>% head() %>% select(1:5) %>% collect()
