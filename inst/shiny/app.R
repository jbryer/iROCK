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

# iROCK_options <- iROCK::iROCK_options()
# NOTE: You can change iROCK options here
# iROCK_options$utterance_highlight_color <- 'yellow'
# yaml::write_yaml(iROCK_options, file = 'inst/shiny/_iROCK.yml')
iROCK_options <- yaml::read_yaml('_iROCK.yml')

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
