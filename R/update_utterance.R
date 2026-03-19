#' Update an utterance within a rock file.
#'
#' @param rock a parsed ROCK source from either [rock::parse_source()] or [rock::parse_sources()].
#' @param uid the utterance ID.
#' @param codes vector of codes to assign the utterance. Note that specifying this parameter will
#'        ignore the `add_code` and `delete_code` parameters.
#' @param add_code a code to add to the utterance.
#' @param delete_code a code to remove from the utterance.
#' @export
update_utterance <- function(rock, uid, codes, add_code, delete_code) {
	df <- rock[["rawSourceDf"]]
	all_codes <- rock$rawCodings$codes
	utterance <- df |> dplyr::filter(uids == uid)
	exisiting_codes <- all_codes[utterance[,all_codes] == 1]

	if(!missing(codes) & (!missing(add_code) | !missing(delete_code))) {
		warning('Specifying codes parameter will override add_code and delete_code.')
	}

	if(!missing(add_code)) {
		exisiting_codes <- c(exisiting_codes, add_code)
	}

	if(!missing(delete_code)) {
		exisiting_codes <- exisiting_codes[exisiting_codes != delete_code]
	}

	if(!missing(codes)) {
		exisiting_codes <- codes
	}

	rock_raw <- df$utterances_raw
	row <- which(df$uids == uid)
	new_row <- paste0(
		rock$rawSourceDf[row,]$utterances_clean_with_uids, ' ',
		ifelse(length(exisiting_codes) > 0,
			   paste0('[[', exisiting_codes, ']]', collapse = ' '),
			   '')
	)
	if(new_row != rock_raw[row]) {
		rock_raw[row] <- new_row
		# TODO: Need to save attributes as well
		cat(rock_raw, sep = '\n', file = rock$arguments$originalSource)
	}
}
