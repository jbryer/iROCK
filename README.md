
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
iROCK::iROCK_shiny()
```

### Development

This R package is developed using `devtools`.

``` r
devtools::document()
devtools::install()
devtools::check(cran = TRUE)
```
