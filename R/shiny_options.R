#' Configuration options for the iROCK Shiny application.
#'
#' @return a list object with configurable options for the iROCK Shiny application, including:
#' \describe{
#'   \item{fixed_style}{}
#'   \item{color_palette}{}
#'   \item{utterance_highlight_color}{The background color }
#' }
#' @rdname iROCK
#' @export
iROCK_options <- function() {
	list(
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
		)
	)
}
