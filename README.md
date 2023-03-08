# Ohdsi lab (a.k.a "Pharmetrics")

# Set-up

1. Set up git/github to use in RStudio

```r
usethis::use_git_config(user.name = "your name", user.email = "your email")
usethis::create_github_token()
gitcreds::gitcreds_set()
```
2. Also add the GitHub PAT to the `.Renviron`, along with some paths:

```r
usethis::edit_r_environ()
```
`.Renviron` needs to look like this:
```
GITHUB_PAT=your_pat_here
PATH="${RTOOLS40_HOME}\usr\bin;${PATH}"
DATABASECONNECTOR_JAR_FOLDER = 'C:\JDBCDrivers'
```

- see here for more: https://happygitwithr.com/https-pat.html

Install HADES packages:

```r
options(install.packages.compile.from.source = "never")
remotes::install_github("ohdsi/Hades", upgrade = "always")
```
I don't actually think I needed to do this because I think they were already there, possibly because I downloaded them when I first opened DBeaver, but if there are no drivers in 'C:\JDBCDrivers', run this (after changing the renviron above). Probably, this is only necessary if accessing the database outside of workspaces. 

```r
DatabaseConnector::downloadJdbcDrivers("redshift")
```

# Connecting

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

# Snippets

Update your Rstudio with ohdsi_lab snippets to give you autocompletion for common code you'll
need for using ohdsi lab. 

1. `usethis::edit_rstudio_snippets()` 
2. Open snippets/ohdsi_lab_snippets in RStudio
3. Select all, copy, and paste at the bottom of the file
4. Sometimes, RStudio doesn't like extra spaces. Be sure any white space highlighted
in red is removed. You should re-add the white space so the file is exactly the same though. 

to use the snippets, start typing ohdsi... in your script and you'll see a little autocompletion menu
come up with some items labelled 'snippets'. Chose the snippet you want. They are hopefully named somewhat
intuitively. 
