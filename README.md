
# Set-up

Set up git/github to use in RStudio
```r
usethis::use_git_config(user.name = "your name", user.email = "your email")
usethis::create_github_token()
gitcreds::gitcreds_set()
```
Also add the GitHub PAT to the `.Renviron`, along with some paths:
```r
usethis::edit_r_environ()
```
`.Renviron` needs to look like this:
```
GITHUB_PAT=your_pat_here
PATH="${RTOOLS40_HOME}\usr\bin;${PATH}"
DATABASECONNECTOR_JAR_FOLDER = 'C:\JDBCDrivers'
```
Install HADES packages:
```r
options(install.packages.compile.from.source = "never")
remotes::install_github("ohdsi/Hades", upgrade = "always")
```
I don't actually think I needed to do this because I think they were already there, but if there are no drivers in 'C:\JDBCDrivers', run this:
```r
DatabaseConnector::downloadJdbcDrivers("postgresql")
```
Use the `keyring` package to store your username and password via the prompts:
```r
keyring::key_set("redshiftUser")
keyring::key_set("redshiftPassword")
```
Then connect to the database:
```r
library(dbplyr)
library(DatabaseConnector)

con <- connect(dbms = "redshift",
               server = "ohdsi-lab-redshift-cluster-prod.clsyktjhufn7.us-east-1.redshift.amazonaws.com/ohdsi_lab",
               port = 5439,
               user = keyring::key_get("redshiftUser"),
               password = keyring::key_get("redshiftPassword"))
```
Check that the connection worked:
```r
dbIsValid(con)
```
If you want to use `dbplyr`:
```r
library(dbplyr)
person <- tbl(con, inDatabaseSchema("omop_cdm_53_pmtx_202203", "person"))
```