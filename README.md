# Ohdsi lab (a.k.a "Pharmetrics")

## Set-up

### git/github
Set up git/github to use in RStudio:
```r
usethis::use_git_config(user.name = "{your name}", user.email = "{your email}")
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
```
See here for more: https://happygitwithr.com/https-pat.html

### Packages
You should generally use [`renv`](https://rstudio.github.io/renv/articles/renv.html) so that your package environment for a given project is contained. On the Amazon Workspaces virtual desktop, the version of the package you're using may depend on what other users have installed, which is not ideal. `renv` will allow you to maintain consistency of the package versions for your project. Within a new R project, initiate an environment:
```r
renv::init()
```

If you are on Windows (including the Amazon Workspaces environment), you should also have this in your `.Renviron`:
```
PATH="${RTOOLS40_HOME}\usr\bin;${PATH}"
```

Now install whatever packages you generally use. In particular, you will want to install OHDSI's HADES packages:
```r
options(install.packages.compile.from.source = "never")
remotes::install_github("ohdsi/Hades", upgrade = "always")
```

### Drivers

If accessing the database *outside* of the Amazon Workspaces virtual desktop, you will need to download some drivers. 
```r
DatabaseConnector::downloadJdbcDrivers("redshift")
```

If you *are* using Amazon Workspaces virtual desktop, the drivers should already be there, by you should also add this to your `.Renviron`:
```
DATABASECONNECTOR_JAR_FOLDER = 'C:\JDBCDrivers'
```

## Connecting

Use the `keyring` package to store your username and password via the prompts (you have received this in your email):

```r
keyring::key_set("lab_user")
keyring::key_set("lab_password")
```

Then connect to the database:

```r
library(DatabaseConnector)

con <- connect(dbms = "redshift",
               server = "ohdsi-lab-redshift-cluster-prod.clsyktjhufn7.us-east-1.redshift.amazonaws.com/ohdsi_lab",
               port = 5439,
               user = keyring::key_get("lab_user"),
               password = keyring::key_get("lab_password"))
```

Check that the connection worked:
```r
dbIsValid(con)
```

If you want to use [`dbplyr`](https://dbplyr.tidyverse.org/):
```r
library(dbplyr)
person <- tbl(con, inDatabaseSchema("omop_cdm_53_pmtx_202203", "person"))
```

You can now print the top few rows of the `person` table by running:
```r
person
```
but if you want to pull the whole table into your R session, you'll need to run:
```r
person <- collect(person)
```

## Snippets

Update your Rstudio with ohdsi_lab snippets to give you autocompletion for common code you'll
need for using ohdsi lab. 

1. Run `usethis::edit_rstudio_snippets()` or find Tools -> Edit Code Snippets...
2. Open snippets/ohdsi_lab_snippets in RStudio
3. Select all, copy, and paste at the bottom of the file
4. Sometimes, RStudio doesn't like extra spaces. Be sure any white space highlighted in red is removed. You should re-add the white space so the file is exactly the same though. 

to use the snippets, start typing ohdsi... in your script and you'll see a little autocompletion menu come up with some items labelled 'snippets'. Chose the snippet you want. They are hopefully named somewhat intuitively. 
