##PART 1: Check if contracts without a district value actually have one in the cleaned data##
#Read in needed contract files - the 1 missing only districts, the main errors file, and the cleaned file
error_contracts <- read.csv(file.path(err_check_path, paste0(f_year, contract_errors)))
clean_contracts <- read.csv(file.path(temp_path, paste0(f_year, clean_c_data)))

#Make a list of unique recipient names and zip codes from contract_errors
error_cont_biz <- unique(data.frame(recipient_name = error_contracts$recipient_name,
                                    recipient_zip_4_code = error_contracts$recipient_zip_4_code))

#Loop over this list to see if it's in the good contracts. If so, it will overwrite the NA district value with the right district
#Exception: if the business has more than 1 district assigned to it, it will be skipped over
for(i in 1:nrow(error_cont_biz)) {
  k <- grepl(error_cont_biz$recipient_name[i], clean_contracts$recipient_name) &
    grepl(error_cont_biz$recipient_zip_4_code[i], clean_contracts$recipient_zip_4_code)
  if(sum(k) > 0) {
    district <- clean_contracts$recipient_congressional_district[k]
    if(length(unique(district)) > 1) {
      next
    }
    error_contracts$recipient_congressional_district[k] <- district[1]
  }
}


#error_cont_biz <- unique(data.frame(recipient_name = error_contracts$recipient_name,
#                                    recipient_zip_4_code = error_contracts$recipient_zip_4_code,
#                                    cd = error_contracts$recipient_congressional_district))

#clean_cont_biz <- unique(data.frame(recipient_name = clean_contracts$recipient_name,
#                                    recipient_zip_4_code = clean_contracts$recipient_zip_4_code,
#                                    cd = clean_contracts$recipient_congressional_district))

#cont_merged <- merge(error_cont_biz, clean_cont_biz, by.x = c("recipient_name", "recipient_zip_4_code"),
#                     by.y = c("recipient_name", "recipient_zip_4_code"), all = T)

#cont_merged <- cont_merged %>%
#  filter((cont_merged$cd.x == 90))# %>%
  #select(!(cd.x))

#write.csv(cont_merged, file.path(err_check_path, "combined_contract_biz.csv"), row.names = F)
