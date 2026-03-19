data(daacs_data, package = 'ShinyQDA')
daacs_data$rock_file <- NA
for(i in seq_len(nrow(daacs_data))) {
	filename <- paste0('data-raw/daacs_', stringr::str_pad(daacs_data[i,]$id, width = 5, pad = '0'), '.txt')
	cat(likert:::label_wrap_mod(daacs_data[i,]$qda_text, width = 80), file = filename)
	daacs_data[i,]$rock_file <- filename
}
daacs_data |>
	dplyr::relocate(qda_text, .after = last_col()) |>
	dplyr::select(!rock_file) |>
	write.csv(file = 'data-raw/daacs.csv', row.names = FALSE)
# daacs_data |>
# 	dplyr::select(!qda_text) |>
# 	write.csv(file = 'data-raw/daacs_attributes.csv', row.names = FALSE)


daacs_data <- read.csv('data-raw/daacs.csv')

# Try converting to ROCK files
rock_sources <- rock::convert_df_to_source(
	daacs_data,
	# output = 'daacs-raw/test/',
	oneFile = FALSE,
	attributesFile = 'inst/shiny/data/ROCK_attributes.yml',
	cols_to_utterances = 'qda_text',
	cols_to_ciids = c(cid = "id"),
	cols_to_attributes = names(daacs_data)[3:15]
)
rock_sources[[1]]

rocker <- rock::parse_source(rock_sources[[1]])
rocker$attributesDf

remotes::install_github("dreamRs/shinytreeview")

list.files(project_dir, pattern = '*.rock')

# Testing

rock_files <- rock::parse_sources(path = project_dir, filesWithYAML = c(
	paste0(project_dir, '/ROCK_attributes.yml'),
	paste0(project_dir, '/ROCK_codebook.yml')
))
ls(rock_files)
length(rock_files)
rock_files$attributesDf |> View() # Attributes
rock_files$sourceDf |> View()
rock_files$deductiveCodeTrees

length(rock_files$parsedSources[[1]])
names(rock_files$parsedSources[[1]])
rock_files$parsedSources[[1]]$attributesDf

rock_files$parsedSources[[1]]$codings

uid <- '836759kk'

out_file <- 'inst/shiny/data/daacs-1.rock'
rock <- rock::parse_source(out_file)
uid <- '836759kk'
add_code <- 'motivation'
delete_code <- 'motivation'

df <- rock[["rawSourceDf"]]
# rock$qdt |> View()
rock$convenience
rock$attributesDf
ls(rock$attributes)
names(rock$attributes[[1]])


# 2026-03-09 Questions
# Is there a parse_codebook function? I see codebook_to_yaml
# filesWithYAML = yaml_files in parse_sources doesn't connect attributes to each rock file
# also appears there is a bug in parse_sources when set, it reads the attributes file for each ROCK file
# Can the add code drop down be expanded always

# collect_coded_fragments add to analyses tab
# snoe_plot

##### Codebook
codebook <- yaml::read_yaml('inst/shiny/data/ROCK_codebook.yml')




out_file <- paste0(project_dir, '/daacs_00001.rock')
rock::clean_source(
	input = 'data-raw/daacs_00001.txt',
	output = out_file
)
rock::prepend_ids_to_source(
	input = out_file,
	output = out_file,
	preventOverwriting = FALSE
)


# Add codes manually
# Attributes editor, should be stored as YML
# Can have multiple data frames where a class is defined and attributes for that class
# Tab for qdt

?convert_csv_to_source
rock::convert_csv_to_source()

