##Code to repair VA benefits where the entries have a district value of 90##

#Read in VA crosswalk generated from lines 29 and 32 of master code
vet_cw <- read.csv(file.path(temp_path, paste0(f_year, vet_crosswalk)))

#Merge the crosswalk to the va_benefits dataframe
va_benefits <- merge(va_benefits, vet_cw, by.x = "recipient_county_code", by.y = "county_or_part")

#Drop the recipient_congressional_district column (which contains the 90s - the crosswalk's district column has the right values)
va_benefits <- va_benefits %>%
  select(-recipient_congressional_district)

#Last, multiply federal_action_obligation by the percent_cnty_total weight column to weigh the spending. Drop unneeded columns, and write dataframe to file
va_benefits <- va_benefits %>%
  mutate(fao_weighted = federal_action_obligation * percent_cnty_total)
  
va_benefits <- va_benefits %>%
  rename(spending = fao_weighted) %>%
  select(all_of(dp_final_cols))

write.csv(va_benefits, file.path(temp_path, paste0(f_year, clean_v_data)), row.names = FALSE)