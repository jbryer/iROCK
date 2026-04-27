#' Link to the ROCK project
#' Internal function.
link_rock <- shiny::tags$a(
    "🤘 ROCK",
    href = "https://rock.science",
    target = "_blank"
)


#' iROCK Shiny UI
#'
#' @export
#' @rdname iROCK
iROCK_ui <- function() {
	bslib::page_navbar(
	    title = 'iROCK',
	    id = 'nav',
	    navbar_options = bslib::navbar_options(collapsible = TRUE),
		shiny::tags$head( # TODO: Should these be in the package?
			shiny::tags$script(src = "https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"),
			shiny::tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css"),
			shiny::tags$script(src = "confirm.js")
		),
		bslib::nav_panel(
			title = "Project",
			bslib::layout_sidebar(
				sidebar = bslib::sidebar(
					shiny::uiOutput('project_selection'),
					shiny::actionButton(
						inputId = 'new_project',
						label = 'New Project',
						icon = shiny::icon('folder-plus')),
					shiny::actionButton(
						inputId = 'delete_project',
						label = 'Delete Project',
						icon = shiny::icon('trash')
					),
					shiny::downloadButton(
						outputId = 'download_project',
						label = 'Download Project'
					),
				),
				shiny::uiOutput('project_properties')
			),

		),
	    bslib::nav_panel(
	        title = "Coding",
	        bslib::layout_sidebar(
	            sidebar = bslib::sidebar(
	            	# "Documents",
	            	shiny::fileInput(
	            		inputId = 'upload_files',
	            		label = 'Upload File(s)',
	            		multiple = FALSE,
	            		accept = c('.csv', '.txt', '.rock'),
	            		buttonLabel = 'Browse...',
	            		placeholder = 'No file selected'
	            	),
	            	shinyTree::shinyTree(
	            		outputId = 'rock_file',
	            		search = FALSE,
	            		checkbox = FALSE,
	            		multiple = FALSE
	            	),
	            	shiny::hr(),
	            	shiny::uiOutput('delete_selected_file'),
	            	# shiny::actionButton(
	            	# 	inputId = 'delete_all_files',
	            	# 	label = 'Delete all files',
	            	# 	icon = shiny::icon('trash')
	            	# ),
	            ),
	            bslib::layout_sidebar(
	                sidebar = bslib::sidebar(
	                    id = 'coding_sidebar',
	                    shiny::div('Selected ID: ', shiny::textOutput('selected_uid')),
	                    shiny::uiOutput('code_input'),
	                    shiny::hr(),
	                    shiny::strong('Codes'),
	                    shiny::uiOutput('selected_codes'),
	                    position = 'right',
	                    open = FALSE
	                ),
	                shiny::tabsetPanel(
	                	shiny::tabPanel(
	                		title = 'Coding',
	                		shiny::uiOutput('document_view')
	                	),
	                	shiny::tabPanel(
	                		title = 'Raw',
	                		# Full list of options here: https://github.com/trestletech/shinyAce
	                		shinyAce::aceEditor(
	                			outputId = 'document_view_raw_ace',
	                			selectionId = "selection",
	                			value = NULL,
	                			placeholder = "Select a document in the left menu...",
	                			debounce = 4000, # How long (in milliseconds) before updates are sent to the server
	                			readOnly = FALSE,
	                			theme = aceEditor$theme,
	                			fontSize = aceEditor$fontSize,
	                			wordWrap = aceEditor$wordWrap,
	                			showLineNumbers = aceEditor$showLineNumbers,
	                			highlightActiveLine = aceEditor$highlightActiveLine,
	                			showPrintMargin = aceEditor$showPrintMargin,
	                			height = aceEditor$height
	                		)
	                	),
	                	shiny::tabPanel(
	                		title = 'Attributes',
	                		shiny::uiOutput('selected_attribues')
	                	)
	                ),
	                border = TRUE
	            ),
	            border_radius = TRUE,
	            fillable = TRUE,
	            shinyjs::useShinyjs(debug = TRUE)
	        ),
	    ),
	    bslib::nav_panel(
	        title = "Attributes",
	        DT::DTOutput('attributes_table')
	    ),
	    bslib::nav_panel(
	    	title = "Analysis",
	    	shiny::sidebarLayout(
	    		shiny::sidebarPanel(
	    			shiny::selectInput(
	    				inputId = 'analysis_type',
	    				label = 'Analysis Type',
	    				choices = c('Soft Non-numeric Occurrence Estimation (SNOE) plot' = 'snoe',
	    							'Coded fragments overview' = 'coded_fragments')
	    			),
	    			shiny::uiOutput('file_selection'),
	    			shiny::actionButton(
	    				inputId = 'run_analysis',
	    				label = 'Run Analysis'
	    			)
	    		),
	    		shiny::mainPanel(
	    			shiny::uiOutput('analysis_results')
	    		)
	    	)
	    ),
		bslib::nav_panel(
	        title = 'Codebook',
	        shiny::tabsetPanel(
	        	shiny::tabPanel(
	        		'Codes',
	        		shiny::fluidRow(
	        			shiny::column(
	        				3,
	        				shiny::actionButton(
	        					inputId = 'new_code_modal',
	        					label = 'New Code'
	        					# icon = icon('square-plus')
	        				),
	        				shiny::br(), shiny::br(),
	        				shinyTree::shinyTree(
	        					outputId = "codebook_tree",
	        					dragAndDrop = FALSE,
	        					sort = FALSE,
	        					wholerow = TRUE,
	        					unique = TRUE)
	        			),
	        			shiny::column(
	        				9,
	        				shiny::uiOutput('codebook_values')
	        			)
	        		)
	        	),
	        	shiny::tabPanel(
	        		'YAML',
	        		shiny::uiOutput('codebook_yaml')
	        	)
	        )


	    ),
		shiny::uiOutput('about_tab'),
		bslib::nav_spacer(),
		bslib::nav_item(shiny::tags$a(
			"🤘 ROCK",
			href = "https://rock.science",
			target = "_blank"
		))
	)
}

