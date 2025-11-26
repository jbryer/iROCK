function(input, output, session) {
	selected_utterance <- reactiveValues(
		uid = NULL,
		rendered = FALSE
	)

	output$selected_uid <- renderText({
		selected_utterance$uid
	})

	##### File upload ##############################################################################
	observeEvent(input$upload_files, {
		files <- input$upload_files
		showModal(
			ui = modalDialog(
				uiOutput('file_upload_modal'),
				size = 'l',
				easyClose = FALSE,
				title = 'Upload file(s)',
				footer = tagList(
					modalButton('Cancel'),
					actionButton(inputId = 'save', label = 'Save')
				)
			)
		)
	})

	output$file_upload_modal <- renderUI({
		ui <- list()
		files <- input$upload_files

		ui[[length(ui) + 1]] <- p(paste0('Uploading file',
										 ifelse(nrow(files) > 1, 's', ''),
										 ': ', paste0(files$name, collapse = ', ')))

		ui[[length(ui) + 1]] <- checkboxInput(
			inputId = 'removeNewlines',
			label = 'Remove all newline characters from the source before starting to clean them',
			value = FALSE)
		ui[[length(ui) + 1]] <- checkboxInput(
			inputId = 'removeTrailingNewlines',
			label = 'Remove trailing newline characters',
			value = TRUE
		)
		do.call(tagList, ui)
	})

	observeEvent(input$save, {
		files <- input$upload_files
print(files)
		for(i in seq_len(nrow(files))) {
			out_file <- paste0(project_dir, '/', tools::file_path_sans_ext(files[i,]$name), '.rock')
			rock::clean_source(
				input = files[i,]$datapath,
				output = out_file
			)
			rock::prepend_ids_to_source(
				input = out_file,
				output = out_file,
				preventOverwriting = FALSE
			)
		}
		rock_files(list.files(project_dir, pattern = '.rock'))
		removeModal()
	})

	##### Code Editing #############################################################################
	# get_rock_file <- reactive({
	# 	req(input$rock_file)
	# 	rock_file <- paste0(project_dir, '/', input$rock_file)
	# 	rock <- rock::parse_source(rock_file)
	# 	return(rock)
	# })

	get_rock_file <- reactivePoll(
		intervalMillis = 500,
		session = session,
		checkFunc = function() {
			if(!is.null(input$rock_file)) {
				rock_file <- paste0(project_dir, '/', input$rock_file)
				if(file.exists(rock_file)) {
					file.info(rock_file)$mtime[1]
				} else {
					return("")
				}
			} else {
				return("")
			}
		},
		valueFunc = function() {
			rock_file <- paste0(project_dir, '/', input$rock_file)
			rock <- rock::parse_source(rock_file)
			return(rock)
		}
	)

	output$code_tree <- renderUI({
		rock <- get_rock_file()
		df <- rock[["rawSourceDf"]]
		codes <- rock$rawCodings$codes
		if(is.null(codes)) {
			codes <- c()
		}
		if(is.null(input$edit_utterance)) {
			div('Please select an utterance.')
		} else {
			uid <- strsplit(input$edit_utterance, ';')[[1]][1]
			utterance <- rock$sourceDf |> dplyr::filter(uids == uid)
			selected <- codes[utterance[,codes] == 1]
			selected_utterance$rendered <- TRUE
			shinytreeview::treeviewInput(
				inputId = 'utterance_codes',
				label = 'Codes',
				choices = codebook,
				selected = selected,
				borders = FALSE,
				multiple = TRUE,
				# prevent_unselect = FALSE,
				# nodes_input = TRUE,
				levels = 3,
				return_value = 'name'
			)
		}
	})

	output$tree_selections <- renderPrint({
		input$utterance_codes
	})

	# Update rock file when the user clicks on code tree
	observeEvent(input$utterance_codes, {
	# observe({
print(selected_utterance$uid)
print(selected_utterance$rendered)
		# print(input$edit_utterance)
		if(is.null(input$edit_utterance) | !selected_utterance$rendered | is.null(selected_utterance$uid)) {
			return()
		}
		rock <- get_rock_file()
		uid <- strsplit(input$edit_utterance, ';')[[1]][1]
		utterance <- rock$sourceDf |> dplyr::filter(uids == uid)
		rock_raw <- rock$rawSourceDf$utterances_raw
		row <- which(rock$sourceDf$uids == uid)
print(input$utterance_codes) # When you unselect the last element nothing is updating
# print(input$utterance_codes_nodes)
		selections <- input$utterance_codes
		selected_codes <- selections

		new_row <- paste0(
			rock$rawSourceDf[row,]$utterances_clean_with_uids, ' ',
			ifelse(length(selected_codes) > 0,
				   paste0('[[', selected_codes, ']]', collapse = ' '),
				   '')
		)
		if(new_row != rock_raw[row]) {
			rock_raw[row] <- new_row
			rock_file <- paste0(project_dir, '/', input$rock_file)
print(paste0('Saving ', rock_file))
			cat(rock_raw, sep = '\n', file = rock_file)
			selected_utterance$uid <- NULL
			selected_utterance$rendered <- FALSE
print(paste0('Updating tree: ', paste0(selected_codes, collapse = ', ')))
			# updateTreeview(
			# 	inputId = 'utterance_codes',
			# 	selected = selected_codes
			# )
		}
	})

	output$document_view_raw <- renderText({
		rock <- get_rock_file()
		paste0(rock$sourceDf$utterances_raw, collapse = '\n')
	})

	output$document_view <- renderUI({
		req(input$rock_file)
		rock <- get_rock_file()
		# TODO: This will collapse the sidebar anytime a code is changed
		sidebar_toggle('coding_sidebar', open = FALSE)
		# if(is.null(selected_utterance())) {
		# 	sidebar_toggle('coding_sidebar', open = FALSE)
		# } else if(!selected_utterance() %in% rock$sourceDf$uids) {
		# 	sidebar_toggle('coding_sidebar', open = FALSE)
		# }
		ui <- list()
		df <- rock[["rawSourceDf"]]
		codes <- rock$rawCodings$codes
		if(is.null(codes)) {
			codes <- c()
		}
		for(i in seq_len(nrow(df))) {
			utterance_codes <- codes[rock$sourceDf[i,codes,drop=FALSE] == 1]
			if(is.null(utterance_codes)) {
				utterance_codes <- ''
			} else if(length(utterance_codes) == 0) {
				utterance_codes <- ''
			} else {
				utterance_codes <- paste0('[[', utterance_codes, ']]', collapse = ' ')
			}
			ui[[length(ui) + 1]] <- fluidRow(
				column(3, shiny::div(paste0('[[', df[i,]$uids, ']]')), style = fixed_style),
				column(9, HTML(
					paste0("<div id='div", df[i,]$uids, "'",
						   "onclick='Shiny.onInputChange(\"edit_utterance\", \"",
						   df[i,]$uids, ";", as.integer(Sys.time()), "\")' ",
						   "style = '", fixed_style, "'>",
						   df[i,]$utterances_clean, " ",
						   utterance_codes, # TODO: color code these
						   "</div>")
					# TODO: Add existing codes here
				))
			)
		}
		do.call(tagList, ui)
	})

	observeEvent(input$edit_utterance, {
		rock <- get_rock_file()
		old_utterance <- selected_utterance$uid
		if(!is.null(old_utterance)) {
			shinyjs::runjs(paste0(
				"document.getElementById('div", selected_utterance$uid, "').style.backgroundColor = 'white';"
			))
		}
		# selected_utterance(strsplit(input$edit_utterance, ';')[[1]][1])
		selected_utterance$uid <- strsplit(input$edit_utterance, ';')[[1]][1]

		# Update tree
		df <- rock[["rawSourceDf"]]
		codes <- rock$rawCodings$codes
		if(is.null(codes)) {
			codes <- c()
		}
print(paste0('Updating tree: ', paste0(codes, collapse = ', ')))
		updateTreeview(
			input = 'utterance_codes',
			selected = codes
		)

		shinyjs::runjs(paste0(
			"document.getElementById('div", selected_utterance$uid, "').style.backgroundColor = 'yellow';"
		))
		sidebar_toggle('coding_sidebar', open = TRUE)
	})

	##### Modal editting  ##########################################################################
	observeEvent(input$save_utterance, {
print(paste0('Saving ', selected_utterance$uid))
		selected_utterance$uid <- NULL
		removeModal()
	})

	output$edit_utterance_modal <- renderUI({
		req(input$rock_file)
		ui <- list()
		rock_file <- paste0(project_dir, '/', input$rock_file)
		rock <- rock::parse_source(rock_file)
		df <- rock[["rawSourceDf"]]
		uid <- selected_utterance$uid
		df_utterance <- df[df$uids == uid,]
		ui[[length(ui) + 1]] <- p(df_utterance[1,]$utterances_clean)
		return(do.call(tagList, ui))
	})


	output$document_view_raw <- renderText({
		req(input$rock_file)
		rock_file <- paste0(project_dir, '/', input$rock_file)
		if(file.exists(rock_file)) {
			txt <- scan(file = rock_file, what = character(), sep = '\n', quiet = TRUE)
			txt <- paste0(txt, collapse = '\n')
			return(txt)
		}
	})

	##### File listing #############################################################################
	rock_files <- reactiveVal(list.files(project_dir, pattern = '.rock'))

	output$file_list <- renderUI({
		files <- rock_files()
		nodes <- list()
		for(i in files) {
			nodes[[length(nodes) + 1]] <- list(text = i)
		}
		choices <- list(
			text = 'Data',
			nodes = nodes
		)
		treeviewInput(
			inputId = "rock_file",
			label = "Choose a document:",
			choices =  nodes,
			width = "100%",
			multiple = FALSE
		)
	})

	##### Codebook #################################################################################
	output$codebook_tree <- renderUI({
		shinytreeview::treeviewInput(
			inputId = 'codebook_code',
			label = 'Codebooks',
			choices = codebook,
			borders = FALSE,
			multiple = FALSE,
			prevent_unselect = TRUE,
			# nodes_input = TRUE,
			levels = 3,
			return_value = 'name'
		)
	})

	output$code_details <- renderUI({
		code <- input$codebook_code
		ui <- list()
		if(!is.null(code)) {
			ui[[length(ui) + 1]] <- textInput(
				inputId = 'code_name',
				label = 'Code',
				value = code
			)
			ui[[length(ui) + 1]] <- textInput(
				inputId = 'code_description',
				label = 'Description'
			)
			ui[[length(ui) + 1]] <- colourpicker::colourInput(
				inputId = 'code_color',
				label = 'Color',
				value = 'steelblue'
			)
		}
		do.call(div, ui)
	})
}
