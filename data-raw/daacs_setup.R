data(daacs_data, package = 'ShinyQDA')
daacs_data$rock_file <- NA
for(i in seq_len(nrow(daacs_data))) {
	filename <- paste0('data-raw/daacs_', stringr::str_pad(daacs_data[i,]$id, width = 5, pad = '0'), '.txt')
	cat(likert:::label_wrap_mod(daacs_data[i,]$qda_text, width = 80), file = filename)
	daacs_data[i,]$rock_file <- filename
}
daacs_data$qda_text <- NULL
write.csv(daacs_data, file = 'data-raw/daacs_attributes.csv', row.names = FALSE)


remotes::install_github("dreamRs/shinytreeview")

list.files(project_dir, pattern = '*.rock')

# Testing
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

rock <- rock::parse_source(out_file)
df <- rock[["rawSourceDf"]]
rock$qdt |> View()
rock$convenience

# Add codes manually
# Attributes editor, should be stored as YML
# Can have multiple data frames where a class is defined and attributes for that class
# Tab for qdt
