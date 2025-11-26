link_rock <- tags$a(
    "🤘 ROCK",
    href = "https://rock.science",
    target = "_blank"
)

page_navbar(
    title = 'iROCK',
    id = 'nav',
    navbar_options = navbar_options(collapsible = TRUE),
    # sidebar = sidebar(
    #     shinyjs::useShinyjs(debug = TRUE),
    #     # tags$head(tags$script(type="text/javascript", src="custom.js")),
    #     conditionalPanel(
    #         "input.nav == 'Coding'",
    #         "Documents",
    #         fileInput(
    #             inputId = 'upload_files',
    #             label = 'Upload File(s)',
    #             multiple = TRUE,
    #             buttonLabel = 'Browse...',
    #             placeholder = 'No file selected'
    #         ),
    #         uiOutput('file_list')
    #     )
    # ),
    nav_panel(
        title = "Coding",
        layout_sidebar(
            sidebar = sidebar(
            	"Documents",
            	fileInput(
            		inputId = 'upload_files',
            		label = 'Upload File(s)',
            		multiple = TRUE,
            		buttonLabel = 'Browse...',
            		placeholder = 'No file selected'
            	),
            	uiOutput('file_list')
            ),
            layout_sidebar(
                sidebar = sidebar(
                    id = 'coding_sidebar',
                    # 'Coding Options here...',
                    div('Selected ID: ', textOutput('selected_uid')),
                    uiOutput('code_tree'),
                    # shinytreeview::treecheckInput(
                    # 	inputId = 'utterance_codes',
                    # 	label = 'Codes',
                    # 	choices = codebook,
                    # 	borders = FALSE,
                    # 	multiple = TRUE,
                    # 	levels = 3,
                    # 	return_value = 'name'
                    # ),

                    textOutput(outputId = "tree_selections"),
                    position = 'right',
                    open = FALSE
                ),
                tabsetPanel(
                	tabPanel(
                		'Coding',
                		uiOutput('document_view')
                	),
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
    nav_panel(
        title = "Attributes",
        "Attributes table here..."
    ),
    nav_panel(
        title = 'Setup',
        fluidRow(
        	column(
        		width = 4,
        		uiOutput('codebook_tree')
        	),
        	column(
        		width = 8,
        		uiOutput('code_details')
        	)
        )

    ),
    nav_spacer(),
    nav_item(link_rock)
)
