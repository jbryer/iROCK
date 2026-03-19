#' Run the iROCK Shiny application
#'
#' @param project_dir directory where ROCK project files are located.
#' @param options the results of [iROCK::iROCK_options()]
#' @param ... other parameters passed to [shiny::shinyApp()].
#' @export
#' @import shiny rock yaml
#' @importFrom colourpicker colourInput
#' @importFrom shinyalert shinyalert
#' @importFrom shinyTree shinyTree
#' @importFrom dplyr filter select
#' @importFrom bslib page_navbar nav_panel layout_sidebar sidebar nav_spacer nav_item navbar_options
#' @importFrom shinyjs useShinyjs runjs
#' @importFrom shinyAce aceEditor
#' @importFrom shinyTree shinyTree get_selected renderTree
#' @importFrom DT DTOutput renderDT datatable
#' @rdname iROCK
iROCK <- function(
	project_dir = getwd(),
	options = iROCK_options(),
	...
) {
	ui <- iROCK_ui
	server <- iROCK_server

	app_env <- new.env()
	assign('projects_location', project_dir, app_env)
	for(i in names(options)) {
		assign(i, options[[i]], app_env)
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
