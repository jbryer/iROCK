library(shiny)
library(dplyr)
library(rock)
library(bslib)
library(shinytreeview) # remotes::install_github("dreamRs/shinytreeview")
library(shinyTree)
library(colourpicker)
library(yaml)
library(shinyAce)
library(iROCK)
library(shinyalert)

# TODO: eventually the server.R and ui.R should be package functions so that these options can be
#       passed as function parameters. This will allow for running locally (i.e. interactivelly) or
#       as a deployed shiny server.
projects_location <- 'projects'

rock::opts$set(preventOverwriting = FALSE)

fixed_style = 'font-family: monospace; font-size: 12px;'

color_palette <- c(
	"#89C5DA", "#DA5724", "#74D944", "#CE50CA", "#3F4921", "#C0717C", "#CBD588", "#5F7FC7",
	"#673770", "#D3D93E", "#38333E", "#508578", "#D7C1B1", "#689030", "#AD6F3B", "#CD9BCD",
	"#D14285", "#6DDE88", "#652926", "#7FDCC0", "#C84248", "#8569D5", "#5E738F", "#D1A33D",
	"#8A7C64", "#599861")
utterance_highlight_color <- 'yellow'

# Default attributes for every new code.
code_attributes <- c('label', 'description', 'instruction',
					 'ucr', 'ucr_prefix', 'ucr_url', 'ucid_url',
					 'fillcolor', 'color')
code_attribute_types <- c(
	description = 'textAreaInput',
	instruction = 'textAreaInput',
	color = 'colourInput',
	fillcolor = 'colourInput'
)

# aesthetics use the dot format
aesthetics <- list(
	edges = list(

	),
	nodes = list(

	)
)
