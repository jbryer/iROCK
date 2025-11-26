library(shiny)
library(dplyr)
library(rock)
library(bslib)
library(shinytreeview) # remotes::install_github("dreamRs/shinytreeview")
library(colourpicker)

rock::opts$set(preventOverwriting = FALSE)

project_dir <- paste0(getwd(), '/data/')

fixed_style = 'font-family: monospace; font-size: 12px;'

color_palette <- c(
	"#89C5DA", "#DA5724", "#74D944", "#CE50CA", "#3F4921", "#C0717C", "#CBD588", "#5F7FC7",
	"#673770", "#D3D93E", "#38333E", "#508578", "#D7C1B1", "#689030", "#AD6F3B", "#CD9BCD",
	"#D14285", "#6DDE88", "#652926", "#7FDCC0", "#C84248", "#8569D5", "#5E738F", "#D1A33D",
	"#8A7C64", "#599861")

codebook <- list(
	list(text = 'strategies',
		 color = color_palette[1]),
	list(text = "metacognition",
		 color = color_palette[2],
		 nodes = list(
		 	list(text = 'planning',
		 		 color = color_palette[3]),
		 	list(text = 'monitoring',
		 		 color = color_palette[4]),
		 	list(text = 'evaluation',
		 		 color = color_palette[5])
		 )),
	list(text = 'selfefficacy',
		 color = color_palette[6],
		 nodes = list(
		 	list(text = 'mathematics',
		 		 color = color_palette[7]),
		 	list(text = 'reading',
		 		 color = color_palette[8]),
		 	list(text = 'writing',
		 		 color = color_palette[9]),
		 	list(text = 'online',
		 		 color = color_palette[10])
		 ))
)
