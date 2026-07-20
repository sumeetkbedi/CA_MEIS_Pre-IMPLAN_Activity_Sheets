##PART 2: Run a GET request to ziplook.house.gov to fill in remaining district errors in error_contracts file##
#Pull out the unique zip codes from error_contracts
zip_list <- unique(error_contracts$recipient_zip_4_code)

#Define an empty dataframe to store data into, and run for loop for GET request to the URL using the unique zip codes
zip_dist_cw <- NULL

for(zip_code in zip_list) {
  response <- GET(url = paste0(ziplook_url, zip_code))
  if(response$status_code != 200) {
    warning(url, " failed ", response$status_code)
    next
  }
  content <- content(response, "text")
  content <- read_html(content)
  district <- gsub(".+?([0-9]{1,}).+", "\\1", xml_text(xml_find_all(content, xpath = "//tr[2]/td[3]")))
  zip_dist_cw <- rbind(zip_dist_cw, c(zip_code, district))
}

zip_dist_cw <- as.data.frame(zip_dist_cw)
colnames(zip_dist_cw) <- c("zip_code", "district")

#Write crosswalk to file. Check to ensure no weird district values come out. If so, correct them, and read back into environment
#write.csv(zip_dist_cw, file.path(temp_path, paste0(f_year, zip_dist_crosswalk)), row.names = F)

zip_dist_cw <- read.csv(file.path(temp_path, paste0(f_year, zip_dist_crosswalk)))

#Loop through crosswalk to fill in district values based on zip code in error_contracts
for (i in 1:nrow(zip_dist_cw)) {
  error_contracts$recipient_congressional_district[grep(zip_dist_cw$zip_code[i],error_contracts$recipient_zip_4_code)] <- zip_dist_cw$district[i]
}