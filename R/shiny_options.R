#' Configuration options for the iROCK Shiny application.
#'
#' @param app_dir directory where the Shiny app is located. If the `_iROCK.yml` file exists in
#'         that directory then the values from that file will be returned, otherwise the default
#'         parameters will be returned.
#' @return a list object with configurable options for the iROCK Shiny application, including:
#' \describe{
#'   \item{fixed_style}{}
#'   \item{color_palette}{}
#'   \item{utterance_highlight_color}{The background color }
#' }
#' @rdname iROCK
#' @export
iROCK_options <- function(app_dir) {
	# These are the default options
	irock_options <- list(
		fixed_style = 'font-family: monospace; font-size: 12px;',

		color_palette = c(
			"#89C5DA", "#DA5724", "#74D944", "#CE50CA", "#3F4921", "#C0717C", "#CBD588", "#5F7FC7",
			"#673770", "#D3D93E", "#38333E", "#508578", "#D7C1B1", "#689030", "#AD6F3B", "#CD9BCD",
			"#D14285", "#6DDE88", "#652926", "#7FDCC0", "#C84248", "#8569D5", "#5E738F", "#D1A33D",
			"#8A7C64", "#599861"),

		utterance_highlight_color = 'yellow',

		# Default attributes for every new code.
		code_attributes = c('label', 'description', 'instruction',
							 'ucr', 'ucr_prefix', 'ucr_url', 'ucid_url',
							 'fillcolor', 'color'),

		code_attribute_types = c(
			description = 'textAreaInput',
			instruction = 'textAreaInput',
			color = 'colourInput',
			fillcolor = 'colourInput'
		),

		# aesthetics use the dot format
		aesthetics = list(
			edges = list(

			),
			nodes = list(

			)
		),

		ace_editor_options = list(
			theme = 'github',
			fontSize = 12,
			wordWrap = FALSE,
			showLineNumbers = TRUE,
			highlightActiveLine = TRUE,
			showPrintMargin = TRUE,
			height = '600px'
		)
	)

	options_file <- file.path(app_dir, '_iROCK.yml')
	if(file.exists(options_file)) {
		options <- yaml::read_yaml(options_file)
		for(i in names(options)) {
			irock_options[[i]] <- options[[i]]
		}
	} else {
		warning(paste0('_iROCK.yml not found in ', app_dir, '. Using default values.'))
	}

	return(irock_options)
}
