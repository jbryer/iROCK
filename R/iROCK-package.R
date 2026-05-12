#' Run the iROCK Shiny application
#'
#' @param app_dir directory where to run the iROCK Shiny application.
#' @param project_dir directory where ROCK project files are located. The default is the `project`
#'        subdirectory to `app_dir`.
#' @param options the results of [iROCK::iROCK_options()]
#' @param ... other parameters passed to [shiny::shinyApp()].
#' @export
#' @import shiny rock
#' @rdname iROCK
iROCK <- function(
	app_dir = getwd(),
	project_dir = file.path(app_dir, 'projects'),
	options = iROCK_options(app_dir),
	...
) {
	ui <- iROCK_ui
	server <- iROCK_server

	app_env <- new.env()
	assign('projects_location', project_dir, app_env)
	for(i in names(options)) {
		assign(i, options[[i]], app_env)
	}

	for(i in names(iROCK_options)) {
		assign(i, iROCK_options[[i]], app_env)
	}

	environment(ui) <- as.environment(app_env)
	environment(server) <- as.environment(app_env)

	app <- shiny::shinyApp(
		ui = ui,
		server = server,
		...
	)
	runApp(app, ...)
}
