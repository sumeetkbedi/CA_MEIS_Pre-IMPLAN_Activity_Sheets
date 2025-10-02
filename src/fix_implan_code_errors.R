## Code for cleaning up IMPLAN errors that come after running local IMPLAN models ##
# Read in clean contracts and the needed CSV file with all the unique combos of county-districts with IMPLAN code issues
final_usaspend <- read.csv(file.path(temp_path, paste0(f_year, concat_u_data)))
implan_code_fix <- read.csv(file.path(raw_path, paste0(year, "_county-district-implan_code_error_combos.csv")), fileEncoding = "UTF-8-BOM")

# Loop over the clean contracts to rewrite the error IMPLAN codes to the fixed IMPLAN code
for (i in 1:nrow(implan_code_fix)) {
  final_usaspend$implan_code[grepl(implan_code_fix$recipient_county_name[i], final_usaspend$recipient_county_name) &
                                grepl(implan_code_fix$recipient_congressional_district[i], final_usaspend$recipient_congressional_district) &
                                grepl(implan_code_fix$implan_code[i], final_usaspend$implan_code)] <- implan_code_fix$new_implan_code[i]
}

# Write to file and remove from environment
write.csv(final_usaspend, file.path(temp_path, paste0(f_year, concat_u_data)), row.names = F)
rm(final_usaspend, implan_code_fix)