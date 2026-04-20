#' iROCK Shiny Server
#'
#' @param input Shiny input object.
#' @param output Shiny output object.
#' @param session Shiny session object.
#' @export
#' @rdname iROCK
iROCK_server <- function(input, output, session) {
	selected_utterance <- shiny::reactiveValues(
		uid = NULL,
		rendered = FALSE
	)

	output$selected_uid <- shiny::renderText({
		selected_utterance$uid
	})

	output$project_selection <- shiny::renderUI({
		projects <- list.dirs(
			path = projects_location,
			recursive = FALSE,
			full.names = FALSE)
		shiny::selectInput(
			inputId = 'project',
			label = 'Project',
			choices = projects
		)
	})

	# TODO: use file.path instead of paste0 to use system path separator
	project_dir <- shiny::reactive({
		file.path(projects_location, input$project)
	})

	project_options_file <- shiny::reactive({
		file.path(projects_location, input$project, '_ROCKproject.yml')
	})

	get_project_options <- shiny::reactivePoll(
		intervalMillis = 500,
		session = session,
		checkFunc = function() {
			rock_file <- project_options_file()
			if(length(rock_file) == 1) {
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
			project <- NULL
			project_file <- project_options_file()
			if(length(project_file) == 1) {
				if(file.exists(project_file)) {
					project <- yaml::read_yaml(project_file)
				}
			}
			return(project)
		}
	)

	##### Project management ###################################################
	shiny::observeEvent(input$new_project, {
		shiny::showModal(
			shiny::modalDialog(
				title = 'New Project',
				shiny::textInput(
					inputId = 'new_project_dir',
					label = 'Project Name',
					width = '100%'
				),
				footer = shiny::tagList(
					shiny::modalButton('Cancel'),
					shiny::actionButton(
						inputId = 'create_new_project',
						label = 'Create')
				)
			)
		)
	})

	shiny::observeEvent(input$delete_project, {
		shinyalert::shinyalert(
			title = 'Confirm Project Deletion',
			text = paste0('Are you sure you want to delete ', input$project,
						  ' project? This operation cannot be undone.'),
			type = 'warning',
			confirmButtonText = 'Yes',
			cancelButtonText = 'Cancel',
			showCancelButton = TRUE,
			callbackR = function(x) {
				if(x) {
					unlink(project_dir(), recursive = TRUE)
					projects <- list.dirs(
						path = projects_location,
						recursive = FALSE,
						full.names = FALSE)
					shiny::updateSelectInput(
						session = session,
						inputId = 'project',
						choices = projects
					)
				}
			}
		)
	})

	shiny::observeEvent(input$create_new_project, {
		# TODO: Should make sure the name is good
		new_dir <- file.path(projects_location, input$new_project_dir)
		dir.create(path = new_dir, recursive = TRUE)
		template_dir <- file.path(find.package('iROCK'), 'template')
		if(!dir.exists(template_dir)) {
			template_dir <- file.path(find.package('iROCK'), 'inst', 'template')
			if(!dir.exists(template_dir)) {
				stop('Could not find template directory!')
			}
		}
		for(i in list.files(template_dir)) {
			file.copy(from = file.path(template_dir, i),
					  to = file.path(projects_location, input$new_project_dir, i))
		}
		shiny::updateSelectInput(
			session = session,
			inputId = 'project',
			choices = list.dirs(path = projects_location, recursive = FALSE, full.names = FALSE),
			selected = input$new_project_dir
		)
		shiny::removeModal()
	})

	output$project_properties <- shiny::renderUI({
		project <- get_project_options()
		ui <- list()
		if(is.null(project)) {
			# TODO: Create new default project file
			# stop('No _ROCKproject.yml found!')
		} else {
			fields <- project[['_ROCKproject']][['project']]
			for(i in names(fields)) {
				ui[[length(ui) + 1]] <- shiny::textInput(
					inputId = paste0('rock_options_', i),
					label = i,
					value = fields[[i]],
					width = '100%'
				)
			}
			ui[[length(ui) + 1]] <- shiny::actionButton(
				inputId = 'save_project_options',
				label = 'Save',
				icon = icon('save')
			)
		}

		do.call(shiny::div, ui)
	})

	observeEvent(input$save_project_options, {
		project <- get_project_options()
		fields <- project[['_ROCKproject']][['project']]
		for(i in names(fields)) {
			project[['_ROCKproject']][['project']][[i]] <- input[[paste0('rock_options_', i)]]
		}
		yaml::write_yaml(
			project,
			file = project_options_file()
		)
	})

	##### Codebook #############################################################
	codebook_codes <- shiny::reactive({
		codebook <- get_codebook_file()
		codes <- c()
		if(!is.null(codebook)) {
			codes <- sapply(codebook[['ROCK_codebook']][['codes']],
							FUN = function(x) { x[['id']] })
			codes <- as.character(codes)
			codes <- codes[!is.null(codes)]
			codes <- codes[codes != 'NULL']
		}
		return(codes)
	})

	get_codebook_file <- shiny::reactivePoll(
		intervalMillis = 500,
		session = session,
		checkFunc = function() {
			codebook_file <- paste0(project_dir(), '/ROCK_codebook.yml')
			if(file.exists(codebook_file)) {
				file.info(codebook_file)$mtime[1]
			} else {
				return("")
			}
		},
		valueFunc = function() {
			codebook <- NULL
			codebook_file <- paste0(project_dir(), '/ROCK_codebook.yml')
			if(file.exists(codebook_file)) {
				codebook <- yaml::read_yaml(codebook_file)
			}
			return(codebook)
		}
	)

	# Using a reactivePoll in case the file is changed outside the Shiny app
	get_rock_file <- shiny::reactivePoll(
		intervalMillis = 500,
		session = session,
		checkFunc = function() {
			if(!is.null(input$rock_file)) {
				rock_file <- shinyTree::get_selected(input$rock_file,
													 format = "classid")[[1]]
				rock_file <- paste0(project_dir(), '/', rock_file)
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
			rock <- NULL
			if(!is.null(input$rock_file)) {
				rock_file <- shinyTree::get_selected(input$rock_file,
													 format = "classid")[[1]]
				rock_file <- paste0(project_dir(), '/', rock_file)
				if(file.exists(rock_file)) {
					if(!file.info(rock_file)$isdir) {
						rock <- rock::parse_source(rock_file)
					}
				}
			}
			return(rock)
		}
	)

	##### File upload ##########################################################
	observeEvent(input$upload_files, {
		files <- input$upload_files
		shiny::showModal(
			ui = shiny::modalDialog(
				shiny::uiOutput('file_upload_modal'),
				size = 'l',
				easyClose = FALSE,
				title = 'Upload file(s)',
				footer = shiny::tagList(
					shiny::modalButton('Cancel'),
					shiny::actionButton(inputId = 'save', label = 'Save')
				)
			)
		)
	})

	output$file_upload_modal <- shiny::renderUI({
		ui <- list()
		files <- input$upload_files

		ui[[length(ui) + 1]] <- p(paste0('Uploading file',
										 ifelse(nrow(files) > 1, 's', ''),
										 ': ', paste0(files$name, collapse = ', ')))

		file_ext <- tools::file_ext(files[1,]$datapath)

		if(files[1,]$type == 'text/plain') {
			# TODO: This parameters are currently not used yet
			ui[[length(ui) + 1]] <- shiny::checkboxInput(
				inputId = 'removeNewlines',
				label = 'Remove all newline characters from the source before starting to clean them',
				value = FALSE)
			ui[[length(ui) + 1]] <- shiny::checkboxInput(
				inputId = 'removeTrailingNewlines',
				label = 'Remove trailing newline characters',
				value = TRUE
			)
		} else if(files[1,]$type == 'text/csv') {
			df <- read.csv(files[1,]$datapath)

			# Guess the text column
			df_char <- df[,sapply(df, class) == 'character',drop=FALSE]
			text_col <- apply(df_char,
							  MARGIN = 2,
							  FUN = function(x) { max(nchar(x)) })
			text_col_selected <- ifelse(
				length(text_col) > 0,
				names(text_col)[text_col == max(text_col)],
				NULL
			)

			# Guess the ID column
			n_unique <- apply(df, 2, FUN = function(x) { length(unique(x)) })
			n_length <- apply(df, MARGIN = 2, FUN = function(x) { max(nchar(x)) })
			id_col <- n_unique[n_unique == nrow(df) & n_length < 64]
			if(length(id_col) == 0) {
				df$id <- 1:nrow(df)
				id_col <- c(id = 'id')
			}

			ui[[length(ui) + 1]] <- shiny::selectInput(
				inputId = 'id_column',
				label = 'ID Column',
				multiple = FALSE,
				choices = names(id_col),
				selected = names(id_col)[1],
				width = '100%'
			)
			ui[[length(ui) + 1]] <- shiny::selectInput(
				inputId = 'text_column',
				label = 'Text Column',
				multiple = FALSE,
				choices = names(text_col),
				selected = text_col_selected,
				width = '100%'
			)
			ui[[length(ui) + 1]] <- shiny::selectInput(
				inputId = 'attribute_column',
				label = 'Attribute Column(s)',
				multiple = TRUE,
				choices = names(df),
				width = '100%'
			)
		}
		do.call(tagList, ui)
	})

	shiny::observeEvent(input$save, {
		files <- input$upload_files
		if(files[1,]$type == 'text/plain') {
			# TODO: if the user uploads a .rock file should probably not processes it.
			for(i in seq_len(nrow(files))) {
				out_file <- paste0(project_dir(), '/', tools::file_path_sans_ext(files[i,]$name), '.rock')
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
		} else if(files[1,]$type == 'text/csv') {
			df <- read.csv(files[1,]$datapath)
			rock_sources <- rock::convert_df_to_source(
				df,
				oneFile = FALSE,
				attributesFile = paste0(project_dir(), '/ROCK_attributes.yml'),
				cols_to_utterances = input$text_column,
				cols_to_ciids = c(cid = input$id_column), # TODO: user should select identifier
				cols_to_attributes = input$attribute_column
			)
			for(i in seq_len(length(rock_sources))) {
				out_file <- paste0(project_dir(), '/',
								   tools::file_path_sans_ext(files[1,]$name), '-',
								   df[i,input$id_column,drop=TRUE],
								   '.rock')
				cat(
					rock_sources[[i]],
					file = out_file,
					sep = '\n'
				)
			}
		}
		rock_files(list.files(project_dir(), pattern = '.rock'))
		removeModal()
	})

	##### Code Editing #########################################################
	output$code_input <- shiny::renderUI({
		shiny::selectizeInput(
			inputId = 'new_code',
			label = 'Enter new code',
			choices = c('', codebook_codes()),
			# choices = codebook_codes(),
			selected = '',
			multiple = FALSE,
			options = list(create = TRUE)
		)
	})

	shiny::observeEvent(input$new_code, {
		if(input$new_code != '') {
			code_pattern <- "^[A-Za-z][A-Za-z0-9_]+$"
			if(!grepl(code_pattern, input$new_code)) {
				shinyalert::shinyalert(
					title = 'Invalid code',
					text = 'Invalid code. Codes can only contain alpha numeric characters and beging with a letter.'
				)
			} else {
				update_utterance(
					rock = get_rock_file(),
					uid = selected_utterance$uid,
					add_code = input$new_code)
				# Add code to codebook
				if(!input$new_code %in% codebook_codes()) {
					params <- list(
						id = input$new_code,
						yaml_file = codebook_file <- paste0(project_dir(), '/ROCK_codebook.yml')
					)
					for(i in code_attributes) {
						params[[i]] <- ''
					}
					do.call(new_code, params)
				}
			}

			shiny::updateSelectizeInput(
				session = session,
				inputId = 'new_code',
				choices = codebook_codes(),
				selected = '')
		}
	})

	# Render list of existing codes for utterance
	output$selected_codes <- shiny::renderUI({
		rock <- get_rock_file()
		ui <- list()
		uid <- selected_utterance$uid
		if(!is.null(uid)) {
			df <- rock[["rawSourceDf"]]
			all_codes <- rock$rawCodings$codes
			df_selected <- df |> dplyr::filter(uids == uid)
			codes <- all_codes[df_selected[,all_codes] == 1]
			for(code in codes) {
				ui[[length(ui) + 1]] <- div(
					code, ' ',
					shiny::actionLink(
						inputId = paste0('delete_code_', code),
						label = ' ',
						icon = icon('trash')
					)
					# TODO: add edges here
				)
			}
		}
		do.call(div, ui)
	})

	# Delete code from an utterance
	shiny::observe({
		rock <- get_rock_file()
		uid <- selected_utterance$uid
		if(!is.null(uid)) {
			df <- rock[["rawSourceDf"]]
			all_codes <- rock$rawCodings$codes
			df_selected <- df |> dplyr::filter(uids == uid)
# TODO: need to handle '>', '->', '|' within the code
			codes <- all_codes[df_selected[,all_codes] == 1]
			for(code in codes) {
				val <- input[[paste0('delete_code_', code)]]
				if(!is.null(val)) {
					if(val == 1) {
						update_utterance(
							rock = get_rock_file(),
							uid = uid,
							delete_code = code
						)
					}
				}
			}
		}
	})

	output$selected_attribues <- shiny::renderUI({
		ui <- list()
		rock <- get_rock_file()
		if(!is.null(rock$attributes[[1]])) {
			for(i in names(rock$attributes[[1]])) {
				ui[[length(ui) + 1]] <- shiny::textInput(
					inputId = i,
					label = i,
					value = rock$attributes[[1]][i]
				)
			}
			ui[[length(ui) + 1]] <- shiny::actionButton(
				inputId = 'update_attributes',
				label = 'Update',
				icon = shiny::icon('floppy-disk')
			)
		} else {
			ui <- shiny::div('None')
		}
		do.call(shiny::div, ui)
	})

	shiny::observeEvent(input$update_attributes, {
print('Updating attributes...')
		# TODO: actually save

	})

	# Raw view of the ROCK file
	output$document_view_raw <- shiny::renderText({
		rock <- get_rock_file()
		paste0(rock$sourceDf$utterances_raw, collapse = '\n')
	})

	# When the user clicks a different document, collapse the right side bar and
	# make the selected uid null.
	selected_rock_file <- reactiveVal('')
	shiny::observeEvent(input$rock_file, {
		rock_file <- shinyTree::get_selected(input$roc)
		if(length(rock_file) > 0) {
			rock_file <- rock_file[[1]]
			if(rock_file != selected_rock_file()) {
				bslib::toggle_sidebar('coding_sidebar', open = FALSE)
				selected_utterance$uid <- NULL
			}
		}
	})

	# Bit of a hack for now. If the user tries to expand the right sidebar but
	# an utterance has not been selected, this will collapse the sidebar. Better
	# option is to disable the button but I haven't found a way to do that yet.
	shiny::observeEvent(input$coding_sidebar, {
		if(is.null(selected_utterance$uid)) {
			bslib::toggle_sidebar('coding_sidebar', open = FALSE)
		}
	})

	# Render the document. When a user clicks on a row/line the edit_utterance
	# event will be triggered by JavaScript.
	output$document_view <- shiny::renderUI({
		shiny::req(input$rock_file)
		rock <- get_rock_file()
		# TODO: This will collapse the sidebar anytime a code is changed
		uid <- selected_utterance$uid
		if(is.null(uid)) {
			bslib::toggle_sidebar('coding_sidebar', open = FALSE)
		} else {
			bslib::toggle_sidebar('coding_sidebar', open = TRUE)
			df <- rock[["rawSourceDf"]]
			all_codes <- rock$rawCodings$codes
			df_selected <- df |> dplyr::filter(uids == uid)
			codes <- all_codes[df_selected[,all_codes] == 1]
		}

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
			bgcolor <- 'white' # TODO: add to iROCK options
			if(!is.null(uid)) {
				if(uid == df[i,]$uids) {
					bgcolor = utterance_highlight_color
				}
			}
			style <- paste0(fixed_style, '; background-color: ', bgcolor, ';')
			ui[[length(ui) + 1]] <- tags$tr(
				shiny::tags$td(shiny::HTML(
					paste0("<div style='", style, "' ",
						   "onclick='Shiny.onInputChange(\"edit_utterance\", \"",
						   df[i,]$uids, ";", as.integer(Sys.time()), "\")' ",
						   ">[[uid=", df[i,]$uids, "]]</div>"))),
				shiny::tags$td(shiny::HTML(
					paste0("<div id='div", df[i,]$uids, "'",
						   "onclick='Shiny.onInputChange(\"edit_utterance\", \"",
						   df[i,]$uids, ";", as.integer(Sys.time()), "\")' ",
						   "style = '", style, "'>",
						   df[i,]$utterances_clean, " ",
						   # utterance_codes, # TODO: color code these
						   "</div>")
				)),
				shiny::tags$td(shiny::HTML(
					paste0("<div style='", style, "' ",
						   "onclick='Shiny.onInputChange(\"edit_utterance\", \"",
						   df[i,]$uids, ";", as.integer(Sys.time()), "\")' ",
						   ">", utterance_codes, "</div>")))
			)
		}

		do.call(tags$table, ui)
	})

	# Event when the user clicks on a row/line to edit.
	# Note that the event value is uid, semicolon, system time. The time is added
	# to ensure that Shiny updates when a new row is reselected.
	shiny::observeEvent(input$edit_utterance, {
		rock <- get_rock_file()
		old_utterance <- selected_utterance$uid
		if(!is.null(old_utterance)) {
			# If previous row/line was selected, make the background white again
			shinyjs::runjs(paste0(
				"document.getElementById('div", selected_utterance$uid, "').style.backgroundColor = 'white';"
			))
		}
		selected_utterance$uid <- strsplit(input$edit_utterance, ';')[[1]][1]

		# Update tree
		df <- rock[["rawSourceDf"]]
		all_codes <- rock$rawCodings$codes
		df_selected <- df |> dplyr::filter(uids == selected_utterance$uid)
		codes <- all_codes[df_selected[,all_codes] == 1]

		shinyjs::runjs(paste0(
			"document.getElementById('div", selected_utterance$uid, "').style.backgroundColor = 'yellow';"
		))
		bslib::toggle_sidebar('coding_sidebar', open = TRUE)
		selected_utterance$rendered <- TRUE
	})

	##### Modal editing ########################################################
	# shiny::observeEvent(input$save_utterance, {
	# 	selected_utterance$uid <- NULL
	# 	shiny::removeModal()
	# })

	output$document_view_raw <- shiny::renderText({
		req(input$rock_file)
		rock_file <- shinyTree::get_selected(input$rock_file,
											 format = "classid")[[1]]
		rock_file <- paste0(project_dir(), '/', rock_file)
		if(file.exists(rock_file)) {
			txt <- scan(file = rock_file, what = character(), sep = '\n', quiet = TRUE)
			txt <- paste0(txt, collapse = '\n')
			return(txt)
		} else {
			return('')
		}
	})

	shiny::observeEvent(input$rock_file, {
		req(input$rock_file)
		rock_file <- shinyTree::get_selected(input$rock_file,
											 format = "classid")[[1]]
		rock_file <- paste0(project_dir(), '/', rock_file)
		if(file.exists(rock_file)) {
			txt <- scan(file = rock_file, what = character(), sep = '\n', quiet = TRUE)
			txt <- paste0(txt, collapse = '\n')
			shinyAce::updateAceEditor(
				session,
				"document_view_raw_ace",
				value = txt
			)
		}
	})

	# output$document_view_raw_ace <- shinyAce::aceEditor({
	#
	# })

	observe({
cat(input$document_view_raw_ace)
		req(input$rock_file)
		rock_file <- shinyTree::get_selected(input$rock_file,
											 format = "classid")[[1]]
		rock_file <- paste0(project_dir(), '/', rock_file)
		if(file.exists(rock_file)) {

		}
	})

	##### File listing #########################################################
	rock_files <- shiny::reactiveVal()
	shiny::observeEvent(input$project, {
		rock_files(list.files(project_dir(), pattern = '.rock', recursive = TRUE))
	})

	output$rock_file <- shinyTree::renderTree({
		files <- rock_files()
		nodes <- list()
		for(i in files) {
			nodes[[i]] <- i
		}
		return(nodes)
	})

	output$delete_selected_file <- shiny::renderUI({
		req(input$rock_file)
		rock_file <- shinyTree::get_selected(input$rock_file, format = "classid")[[1]]
		if(!is.null(rock_file)) {
			shiny::actionButton(
				inputId = 'delete_file',
				label = paste0('Delete ', rock_file),
				icon = shiny::icon('trash')
			)
		}
	})

	shiny::observeEvent(input$delete_file, {
		shinyalert::shinyalert(
			title = 'Confirm file deletion',
			text = paste0('Are you sure you want to delete ', input$rock_file, '? ',
						  'This operation cannot be undone.'),
			confirmButtonText = 'Yes',
			showCancelButton = TRUE,
			cancelButtonText = 'Cancel',
			callbackR = function(x) {
				if(x) {
					rock_file <- shinyTree::get_selected(input$rock_file, format = "classid")[[1]]
					unlink(paste0(project_dir(), '/', rock_file))
					rock_files(list.files(project_dir(), pattern = '.rock'))
				}
			}
		)
	})

	# shiny::observeEvent(input$delete_all_files, {
	# 	shinyalert::shinyalert(
	# 		title = 'Confirm file deletion',
	# 		text = paste0('Are you sure you want to delete all files? ',
	# 					  'This operation cannot be undone.'),
	# 		confirmButtonText = 'Yes',
	# 		showCancelButton = TRUE,
	# 		cancelButtonText = 'Cancel',
	# 		callbackR = function(x) {
	# 			if(x) {
	# 				all_files <- list.files(project_dir())
	# 				unlink(paste0(project_dir(), '/', all_files))
	# 				rock_files(list.files(project_dir(), pattern = '.rock'))
	# 			}
	# 		}
	# 	)
	# })

	##### Attributes Tables ####################################################
	output$attributes_table <- DT::renderDT({
		yaml_files =
		rock_files <- rock::parse_sources(path = project_dir())#, filesWithYAML = yaml_files)
		DT::datatable(rock_files$attributesDf, editable = TRUE)
	})

	shiny::observeEvent(input$attributes_table_cell_edit, {
		row  <- input$attributes_table_cell_edit$row
		col <- input$attributes_table_cell_edit$col
		# TODO: save changes
print(paste0('Changing cell ', row, ', ', col, ' to ', input$attributes_table_cell_edit$value))
		# rv$data[row, col] <- input$attributes_table_cell_edit$value
	})

	##### Codebook #############################################################
	output$codebook_tree <- shinyTree::renderTree({
		yml <- get_codebook_file()
		# TODO: need to add lots of checking.
		codebook <- yml[['ROCK_codebook']]
		codes <- codebook[['codes']]
		tree <- list()
		for(i in seq_len(length(codes))) {
			id <- codes[[i]][['id']]
			if(!is.null(id)) {
				tree[[id]] <- i
			}
		}
		return(tree)
	})

	output$codebook_values <- shiny::renderUI({
		req(input$codebook_tree)

		ui <- list()
		id <- shinyTree::get_selected(input$codebook_tree, format = "classid")[[1]]
		ui[[1]] <- p(paste0('Code ID: ', id))

		yml <- yaml::read_yaml(paste0(project_dir(), '/ROCK_codebook.yml'))
		codebook <- yml[['ROCK_codebook']]
		codes <- codebook[['codes']]
		selected_code <- sapply(codes, FUN = function(x) { x['id'] == id})
		code <- codes[selected_code]
		if(length(code) > 0) {
			code <- code[[1]]
			for(j in seq_len(length(code))) {
				attr <- names(code)[j]
				value <- code[[j]]
				if(is.list(value)) {
					# TODO: nested list
				} else if(attr != 'id') {
					FUN <- get_input_type(attr)
					ui[[length(ui) + 1]] <- FUN(
						inputId = attr,
						label = attr,
						value = value,
						width = '100%'
					)
				}
			}

			ui[[length(ui) + 1]] <- actionButton(
				inputId = 'save_code_edits',
				label = paste0('Save ', id))
		} else {
			warning('Could not find code to edit.')
		}

		do.call(div, ui)
	})

	shiny::observeEvent(input$save_code_edits, {
		id <- shinyTree::get_selected(input$codebook_tree, format = "classid")[[1]]
		params <- list(
			yaml_file = paste0(project_dir(), '/ROCK_codebook.yml'),
			id = id
		)
		yml <- yaml::read_yaml(paste0(project_dir(), '/ROCK_codebook.yml'))
		codebook <- yml[['ROCK_codebook']]
		codes <- codebook[['codes']]
		selected_code <- sapply(codes, FUN = function(x) { x['id'] == id})
		code <- codes[selected_code]
		if(length(code) > 0) {
			code <- code[[1]]
			for(j in seq_len(length(code))) {
				attr <- names(code)[j]
				value <- code[[j]]
				if(is.list(value)) {
					# TODO: nested list
				} else if(attr != 'id') {
					params[[attr]] <- input[[attr]]
				}
			}
		}

		do.call(update_code, params)
	})

	get_input_type <- function(x) {
		FUN <- shiny::textInput
		if(x %in% names(code_attribute_types)) {
			type <- code_attribute_types[x]
			FUN <- switch(
				EXPR = type,
				textAreaInput = shiny::textAreaInput,
				colourInput = colourpicker::colourInput,
				numericInput = shiny::numericInput,
				shiny::textInput
			)
		}
		return(FUN)
	}

	output$new_code_ui <- shiny::renderUI({
		ui <- list()
		ui[[length(ui) + 1]] <- shiny::textInput(
			inputId = 'new_id',
			label = 'ID'
		)
		for(i in code_attributes) {
			FUN <- get_input_type(i)
			ui[[length(ui) + 1]] <- FUN(
				inputId = paste0('new_', i),
				label = i,
				width = '100%'
			)
		}
		do.call(div, ui)
	})

	shiny::observeEvent(input$add_new_code, {
		params <- list(
			yaml_file = paste0(project_dir(), '/ROCK_codebook.yml'),
			id = input$new_id
		)
		for(i in code_attributes) {
			params[[i]] <- input[[paste0('new_', i)]]
		}
		do.call(new_code, params)
		shiny::removeModal()
	})

	shiny::observeEvent(input$new_code_modal, {
		shiny::showModal(
			shiny::modalDialog(
				title = 'New Code',
				shiny::uiOutput('new_code_ui'),
				size = 'xl',
				easyClose = FALSE,
				footer = shiny::tagList(
					shiny::modalButton('Cancel'),
					shiny::actionButton('add_new_code', 'Add')
				)
			)
		)
	})

	output$codebook_yaml <- shiny::renderUI({
		# TODO: check that file exists
		codebook_file <- paste0(project_dir(), '/ROCK_codebook.yml')
		if(file.exists(codebook_file)) {
			# yml <- yaml::read_yaml(codebook_file)
			yml_raw <- scan(file = codebook_file, what = character(), sep = '\n') |>
				paste0(collapse = '\n')
			shinyAce::aceEditor(
				outputId = 'codebook_yaml',
				value = yml_raw,
				placeholder = '',
				showPrintMargin = FALSE
			)
		} else {
			return(NULL)
		}
	})

	output$code_details <- shiny::renderUI({
		code <- input$codebook_code
		ui <- list()
		if(!is.null(code)) {
			ui[[length(ui) + 1]] <- shiny::textInput(
				inputId = 'code_name',
				label = 'Code',
				value = code
			)
			ui[[length(ui) + 1]] <- shiny::textInput(
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

	##### Analyses #############################################################
	output$file_selection <- shiny::renderUI({
		rock_files <- list.files(project_dir(), pattern = '*.rock')
		shiny::checkboxGroupInput(
			inputId = 'file_selection',
			label = 'Files to include',,
			choices = rock_files,
			selected = rock_files,
			width = '100%'
		)
	})

	get_parsed_sources <- shiny::eventReactive(input$run_analysis, {
		files <- input$file_selection
		ps <- rock::parse_sources(
			project_dir(),
			regex = paste0(files, collapse = '|')
		)
		return(ps)
	})

	output$analysis_results <- shiny::renderUI({
		ps <- get_parsed_sources()
		input$run_analysis
		ui <- list()
		if(input$analysis_type == 'snoe') {
			ui[[length(ui) + 1]] <- plotOutput('snoe_plot')
		} else if(input$analysis_type == 'coded_fragments') {
			ui[[length(ui) + 1]] <- htmlOutput('coded_fragments')
		}
		do.call(div, ui)
	})

	output$snoe_plot <- shiny::renderPlot({
		ps <- get_parsed_sources()
		rock::snoe_plot(ps)
	})

	output$coded_fragments <- shiny::renderText({
		ps <- get_parsed_sources()
		rock::collect_coded_fragments(
			ps,
			outputViewer = FALSE,
			rawResult = FALSE,
			includeCSS = TRUE,
			returnHTML = TRUE,
			add_html_tags = TRUE)
	})


	##### Project export/import ################################################
	output$download_project <- shiny::downloadHandler(
		filename = function() {
			paste0(input$project, '.ROCKproject')
		},
		content = function(file) {
			# path <- paste0(getwd(), '/', project_dir())
			path <- project_dir()
			rock::export_ROCKproject(
				path = path,
				output = file
			)
		}
	)

	##### About tab/instructions ###############################################
	output$about_tab <- renderUI({
		ui <- NULL
		about_file <- file.path(find.package('iROCK'), 'about.md')
		if(!file.exists(about_file)) {
			about_file <- file.path(find.package('iROCK'), 'inst', 'about.md')
		}
		if(file.exists(about_file)) {
			ui <- bslib::nav_panel(
				title = 'About',
				shiny::includeMarkdown(about_file)
			)
		}
		return(ui)
	})
}
