

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

index = "efi"
schema = 'omop_cdm_53_pmtx_202203'
  
    
    concept                 = paste(schema, "concept", sep = ".")
    condition_occurrence    = paste(schema, "condition_occurrence", sep = ".")
    observation             = paste(schema, "observation", sep = ".")
    procedure_occurrence    = paste(schema, "procedure_occurrence", sep = ".")
    device_exposure         = paste(schema, "device_exposure", sep = ".")
 
  index_ = tolower(index)
  
  # gets a dataframe with columns of category (general description of the FI category)
  # and concept_id which is an OMOP concept ID for the FI category. FI categories can
  # be repeated with different concept IDs, but there should be no concept_id duplicates.
  # If the index is hfrs, there is an additional column called 'hfrs_score' which
  # holds the point value for the hfrs concept.
  # This function is documented in the package and pulls from data sources we generated
  # using the AoU tables. Code for generating these tables can be made available.
  categories_concepts <- getConcepts(index = index_)
  
  # get full list of concepts from the concept table
  # originally, this pulled from the All of Us cb_cohort and other
  # tables specific to all of us. Switching to the general concept table
  # made very little, except for hfrs. There were 51 additional concepts in the
  # concept table that were not in the AoU table. We're still not sure what the
  # difference is, but perhaps related to the is_selectable aspect of AoU...
  condition_concept_ids <- tbl(con, inDatabaseSchema("omop_cdm_53_pmtx_202203", "concept")) %>%
    filter(standard_concept == "S") %>%
    distinct(concept_id, name = concept_name, vocabulary_id) %>%
    filter(concept_id %in% !!unique(categories_concepts$concept_id)) %>%
    distinct()

  # The following four calls go find the presence of the concept IDs in the
  # condition occurrence, procedure, observation, and device tabes, limiting
  # the search to the person_ids and concepts in teh above condition_concept_ids
  # table. They also calculate a start year and month which are important for
  # later analyses that are dependent on when the FI event occurs.
  
  # go find instances of our concepts in the condition occurrence table
  cond_occurrences <- tbl(con, inDatabaseSchema("omop_cdm_53_pmtx_202203", "condition_occurrence")) %>%
    inner_join(condition_concept_ids, by = c("condition_concept_id" = "concept_id")) %>%
    inner_join(eligible, by = "person_id")  %>% collect()
  