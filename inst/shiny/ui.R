link_rock <- tags$a(
    "🤘 ROCK",
    href = "https://rock.science",
    target = "_blank"
)

page_navbar(
    title = 'iROCK',
    id = 'nav',
    navbar_options = navbar_options(collapsible = TRUE),
	tags$head(
	    tags$script(src = "https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"),
	    tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css"),
	    tags$script(src = "confirm.js")
	),
    nav_panel(
        title = "Coding",
        layout_sidebar(
            sidebar = sidebar(
            	# "Documents",
            	uiOutput('project_selection'),
            	actionButton(inputId = 'new_project', label = 'New Project', icon = icon('folder-plus')),
            	fileInput(
            		inputId = 'upload_files',
            		label = 'Upload File(s)',
            		multiple = FALSE,
            		accept = c('.csv', '.txt', '.rock'),
            		buttonLabel = 'Browse...',
            		placeholder = 'No file selected'
            	),
            	uiOutput('file_list'),
            	hr(),
            	uiOutput('delete_selected_file'),
            	actionButton(
            		inputId = 'delete_all_files',
            		label = 'Delete all files',
            		icon = icon('trash')
            	),
            	actionButton(
            		inputId = 'delete_project',
            		label = 'Delete Project',
            		icon = icon('trash')
            	),
            	downloadButton(
            		outputId = 'download_project',
            		label = 'Download Project'
            	)
            ),
            layout_sidebar(
                sidebar = sidebar(
                    id = 'coding_sidebar',
                    # 'Coding Options here...',
                    div('Selected ID: ', textOutput('selected_uid')),
                    uiOutput('code_input'),
                    hr(),
                    strong('Codes'),
                    uiOutput('selected_codes'),
                    position = 'right',
                    open = FALSE
                ),
                tabsetPanel(
                	tabPanel(
                		'Coding',
                		uiOutput('document_view')
                	),
                	# tabPanel(
                	# 	'Attributes',
                	# 	uiOutput('selected_attribues')
                	# ),
                	tabPanel(
                		'Raw',
                		verbatimTextOutput('document_view_raw')
                	)
                ),
                border = TRUE
            ),
            border_radius = TRUE,
            fillable = TRUE,
            shinyjs::useShinyjs(debug = TRUE)
        ),
    ),
    # nav_panel(
    #     title = "Attributes",
    #     DT::dataTableOutput('attributes_table')
    # ),
    nav_panel(
    	title = "Analysis",
    	sidebarLayout(
    		sidebarPanel(
    			selectInput(
    				inputId = 'analysis_type',
    				label = 'Analysis Type',
    				choices = c('Soft Non-numeric Occurrence Estimation (SNOE) plot' = 'snoe',
    							'Coded fragments overview' = 'coded_fragments')
    			),
    			uiOutput('file_selection'),
    			actionButton(
    				inputId = 'run_analysis',
    				label = 'Run Analysis'
    			)
    		),
    		mainPanel(
    			uiOutput('analysis_results')
    		)
    	)
    ),
    nav_panel(
        title = 'Codebook',
        tabsetPanel(
        	tabPanel(
        		'Codes',
        		fluidRow(
        			column(
        				3,
        				actionButton(
        					inputId = 'new_code_modal',
        					label = 'New Code'
        					# icon = icon('square-plus')
        				),
        				br(), br(),
        				shinyTree("codebook_tree", dragAndDrop=TRUE, sort = FALSE, wholerow = TRUE, unique = TRUE)
        			),
        			column(
        				9,
        				uiOutput('codebook_values')
        			)
        		)
        	),
        	tabPanel(
        		'YAML',
        		uiOutput('codebook_yaml')
        	)
        )


    ),
    nav_spacer(),
    nav_item(link_rock)
)
