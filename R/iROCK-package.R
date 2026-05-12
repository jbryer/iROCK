#' Run the iROCK Shiny application
#'
#' @param app_dir directory where to run the iROCK Shiny application.
#' @param projects_dir directory where ROCK projects are located. By default,
#'        it is the same as `app_dir`. Each ROCK project will be a subdirectory.
#' @param options the results of [iROCK::iROCK_options()]
#' @param ... other parameters passed to [shiny::shinyApp()].
#' @export
#' @import shiny rock
#' @rdname iROCK
iROCK <- function(
	app_dir = getwd(),
	projects_dir = app_dir,
	options = iROCK_options(app_dir),
	...
) {
	ui <- iROCK_ui
	server <- iROCK_server

	app_env <- new.env()
	assign('projects_location', projects_dir, app_env)
	for(i in names(options)) {
		assign(i, options[[i]], app_env)
	}

	for(i in names(iROCK_options)) {
		assign(i, iROCK_options[[i]], app_env)
	}

	if(!file.exists(file.path(app_dir, '_iROCK.yml'))) {
		ans <- utils::menu(
			title = paste0('Would you like to create a new iROCK project?\n', app_dir),
			choices = c('Yes', 'No')
		)
		if(ans == 2) {
			return(FALSE)
		} else if(ans == 1) {
			if(!dir.exists(app_dir)) {
				dir.create(app_dir, recursive = TRUE, showWarnings = FALSE)
			}
			message(paste0('Copying _iROCK.yml to ', app_dir))
			yaml::write_yaml(iROCK_options, file = file.path(app_dir, '_iROCK.yml'))
		}
		ans <- utils::menu(
			title = 'Would you like to create an app.R file?',
			choices = c('Yes', 'No')
		)
		if(ans == 1) {
			file.copy(
				from = file.path(find.package('iROCK'), 'shiny', 'app.R'),
				to = file.path(app_dir, 'app.R')
			)

		}
	}

	if(!dir.exists(projects_dir)) {
		message(paste0('Creating projects directory: ', projects_dir))
		dir.create(projects_dir, recursive = TRUE, showWarnings = FALSE)
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
