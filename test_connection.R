library(dplyr)
library(dbplyr)
library(DBI)
con <- DBI::dbConnect(odbc::odbc(), "pharmetrics", timeout = Inf)
# set the schema to avoid having to reference it
DBI::dbGetQuery(con, "set search_path to omop_cdm_53_pmtx_202203")
person <- tbl(con, "person") 
# or person <- tbl(con, in_schema("omop_cdm_53_pmtx_202203", "person"))

tally(person) # 34808145
demographics <- count(person, gender_concept_id, ethnicity_concept_id, race_concept_id)
demographics # only gender, matches what atlas says