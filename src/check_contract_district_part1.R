##PART 1: Check if contracts without a district value actually have one in the cleaned data##
#Read in the two contract files - the errors file and the cleaned file
error_contracts <- read.csv(file.path(err_check_path, paste0(f_year, contract_errors)))
clean_contracts <- read.csv(file.path(temp_path, paste0(f_year, clean_c_data)))

#Make a list of unique recipient names, zip codes, and districts from clean_contracts.
#Be sure to check if any recipient name-zip code combo is in multiple rows (i.e., has multiple district values) and filter those out.
clean_cont_biz <- clean_contracts %>%
  select(recipient_name, recipient_zip_4_code, recipient_congressional_district) %>%
  rename(district = recipient_congressional_district) %>%
  distinct() %>%
  add_count(recipient_name, recipient_zip_4_code, name = "n_matches") %>%
  filter(n_matches == 1) %>%
  select(-n_matches)

#Left join this list to error_contracts, and check if any recipient name-zip code combo exists in the errors.
#If so, overwrite the error file's district value (if NA or 90) with the cleaned file's district value.
error_contracts <- error_contracts %>%
  left_join(clean_cont_biz, by = c("recipient_name", "recipient_zip_4_code")) %>%
  mutate(recipient_congressional_district = if_else(
    is.na(recipient_congressional_district) | recipient_congressional_district == 90,
    district, recipient_congressional_district)) %>%
  select(-district)