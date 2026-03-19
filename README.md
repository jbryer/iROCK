
<!-- README.md is generated from README.Rmd. Please edit that file -->

# iROCK: Shiny Application for the Reproducible Open Coding Kit (ROCK)

<!-- badges: start -->

[![](https://www.r-pkg.org/badges/version/iROCK?color=orange)](https://cran.r-project.org/package=iROCK)
[![](https://img.shields.io/badge/devel%20version-0.1.0-blue.svg)](https://github.com/jbryer/iROCK)
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
remotes::install_github("dreamRs/shinytreeview")
remotes::install_github('jbryer/iROCK')
```

Start the Shiny application:

``` r
iROCK::iROCK(project_dir = 'inst/shiny/projects')
```

Alternatively, you can deply the iROCK Shiny application using your own
projects by using the template below.

``` r
library(iROCK)
library(shiny)

ui <- server <- NULL

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

iROCK_options <- iROCK::iROCK_options()
# NOTE: You can change iROCK options here
# iROCK_options$utterance_highlight_color <- 'yellow'

# Where should projects be save
projects_dir <- file.path(getwd(), 'projects')

##### DO NOT CHANGE BELOW ######################################################
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

### Development

This R package is developed using `devtools`.

``` r
devtools::document()
devtools::check_man()
devtools::install()
devtools::check(cran = TRUE)
```
