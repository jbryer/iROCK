#' Run the iROCK Shiny application
#'
#' @param ... other parameters passed to [shiny::runApp()].
#' @export
#' @import shiny dplyr rock bslib shinytreeview shinyTree colourpicker yaml shinyAce shinyalert
iROCK <- function(...) {
	pkg_dir <- find.package('iROCK')
	shiny::runApp(appDir = paste0(pkg_dir, '/shiny/'), ...)
}
