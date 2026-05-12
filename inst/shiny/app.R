library(iROCK)
library(shiny)

# Where should projects be save
projects_dir <- getwd()

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
