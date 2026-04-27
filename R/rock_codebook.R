#' Create a new ROCK codebook.
#' @param yaml_file location of the codebook YAML file.
#' @return the YAML file.
#' @export
#' @rdname rock-codebook
new_rock_codebook <- function(yaml_file) {
	yml <- list(
		'ROCK_codebook' = list(
			"codes" = list(
				# list(id = 'code1')
			),
			'aesthetics' = list(
				list(
					'type' = 'default',
					'fillcolor' = '#DDDDFF',
					'fontcolor' = '#000044',
					'stroke' = '#000044',
					'shape' = 'box',
					'style' = 'rounded,filled'
				)
			)
		)
	)
	# yaml::as.yaml(yml) |> cat()
	yaml::write_yaml(yml, file = yaml_file)
	invisible(yaml::read_yaml(yaml_file))
}

#' Create a new ROCK project.
#'
#' @param dir directory to create the new `_ROCKproject.yml` file.
#' @export
#' @rdname rock-codebook
new_rock_project <- function(dir) {
	yml <- list(
		'_ROCKproject'
	)
	yaml::write_yaml(yml, file = paste0(dir, '/', '_ROCKproject.yml'))
}

#' Edit an existing code
#'
#' @export
#' @rdname rock-codebook
update_code <- function(
		yaml_file,
		id,
		...
) {
	if(missing(yaml_file)) {
		stop('yaml_file is required')
	}
	if(missing(id)) {
		stop('code id is required')
	}

	yml <- yaml::read_yaml(yaml_file)
	codes <- sapply(yml[['ROCK_codebook']][['codes']], FUN = function(x) { x[['id']] })
	pos <- which(codes == id)
	if(length(pos) == 1) {
		new_vals <- list(...)
		old_vals <- yml[['ROCK_codebook']][['codes']][[pos]]
		for(i in names(new_vals)) {
			old_vals[[i]] <- new_vals[[i]]
		}
		yml[['ROCK_codebook']][['codes']][[pos]] <- old_vals
	} else {
		warning(paste0('Code not found in codebook: ', id))
	}
	yaml::write_yaml(yml, file = yaml_file)
	invisible(yaml::read_yaml(yaml_file))
}

#' Adds a new code to the ROCK codebook.
#' @param yaml_file path to the YAML file (i.e. ROCK_codebook.yml).
#' @param id the ID for the new code.
#' @param ... any other fields to include with the new code.
#' @return the newly parsed codebook file (see [yaml::read_yaml()])
#' @rdname rock-codebook
#' @export
new_code <- function(
		yaml_file,
		id,
		...
) {
	if(missing(yaml_file)) {
		stop('yaml_file is required')
	}
	if(missing(id)) {
		stop('code id is required')
	}

	new_code <- list(...)
	new_code <- c(id = id, new_code)
	yml <- yaml::read_yaml(yaml_file)
	n_codes <- length(yml[['ROCK_codebook']][['codes']])
	yml[['ROCK_codebook']][['codes']][[n_codes + 1]] <- new_code
	yaml::write_yaml(yml, file = yaml_file)
	invisible(yaml::read_yaml(yaml_file))
}
