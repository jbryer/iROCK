
<!-- README.md is generated from README.Rmd. Please edit that file -->

# iROCK: Shiny Application for the Reproducible Open Coding Kit (ROCK)

<!-- badges: start -->

[![](https://www.r-pkg.org/badges/version/iROCK?color=orange)](https://cran.r-project.org/package=iROCK)
[![](https://img.shields.io/badge/devel%20version-0.2.0-blue.svg)](https://github.com/jbryer/iROCK)
[![Project Status: Active - The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

See the [ROCK](https://rock.science) website for more information on the
ROCK standard for qualitative data analysis.

### Getting Started

To install the latest development version, use the following command in
R:

``` r
remotes::install_github('jbryer/iROCK')
```

Start the Shiny application:

``` r
iROCK::iROCK('myROCK')
```

Alternatively, you can deply the iROCK Shiny application using your own
projects by using the template below.

``` r
library(iROCK)
library(shiny)

# Where should projects be save
projects_dir <- file.path(getwd(), 'projects')

##### DO NOT CHANGE BELOW ######################################################
ui <- server <- NULL

################################################################################
# TODO: Delete this before releasing to CRAN
# For development purposes. If the the app.R is run from the source tree then
# we will source the server.R and ui.R scripts. Otherwise we will use
# the functions in the installed package.
if(file.exists('../../R/iROCK-package.R') & require(devtools)) {
    message('Running iROCK using locally sourced files.')
    devtools::load_all('../../', quiet = TRUE)
    ui <- iROCK_ui
    server <- iROCK_server
} else {
    message('Running iROCK from the package.')
    ui <- iROCK::iROCK_ui
    server <- iROCK::iROCK_server
}
################################################################################

# Read _iROCK.yml and add any missing options
default_iROCK_options <- iROCK::iROCK_options(getwd())
iROCK_options <- NULL
if(file.exists('_iROCK.yml')) {
    iROCK_options <- yaml::read_yaml('_iROCK.yml')
    # If new options are defined in iROCK_options() then add them to _iROCK.yml
    missing_options <- names(default_iROCK_options)[
        !names(default_iROCK_options) %in% names(iROCK_options)]
    for(i in missing_options) {
        iROCK_options[[i]] <- default_iROCK_options[[i]]
    }
} else {
    iROCK_options <- default_iROCK_options
}

yaml::write_yaml(iROCK_options, file = '_iROCK.yml')

# Assign environment variable for the UI and server
app_env <- new.env()
assign('projects_location', projects_dir, app_env)
for(i in names(iROCK_options)) {
    assign(i, iROCK_options[[i]], app_env)
}
environment(server) <- as.environment(app_env)
environment(ui) <- as.environment(app_env)

# Run the Shiny app
shiny::shinyApp(
    ui = ui,
    server = server
)
```

You can download the [daacs.csv](inst/test_data/daacs.csv) file to test
the features and to follow the directions below.

![](man/figures/01_New_Project.png)

![](man/figures/02_New_Project_2.png)

![](man/figures/03_Project_Details.png)

![](man/figures/04_Upload_Files.png)

![](man/figures/05_Upload_files_options.png)

![](man/figures/06_Coding_View.png)

![](man/figures/07_Codeing_View_2.png)

![](man/figures/08_Coding_View_3.png)

![](man/figures/09_Edit_code.png)

![](man/figures/10_Raw_view.png)

![](man/figures/11_Attributes_View.png)

![](man/figures/12_All_attributes.png)

![](man/figures/13_Analysis_view.png)

![](man/figures/14_Codebook_view.png)

### Development

This R package is developed using `devtools`.

``` r
devtools::document()
devtools::check_man()
devtools::install()
devtools::check(cran = TRUE)
```
