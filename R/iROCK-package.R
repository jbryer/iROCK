#' Run the iROCK Shiny application
#'
#' @param ... other parameters passed to [shiny::runApp()].
#' @export
#' @importFrom shiny runApp
iROCK_shiny <- function(...) {
	pkg_dir <- find.package('iROCK')
	shiny::runApp(appDir = paste0(pkg_dir, '/shiny/'))
}
