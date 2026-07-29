##Code to repair VA benefits where the entries have a district value of 90##

#Read in VA crosswalk generated from lines 28 and 31 of run_master_analysis, and va_benefits (if written to file previously)
vet_cw <- read.csv(file.path(temp_path, paste0(f_year, vet_crosswalk)))
va_benefits <- read.csv(file.path(temp_path, paste0(f_year, va_ben_data)))

#Merge the crosswalk to the va_benefits dataframe
va_benefits <- merge(va_benefits, vet_cw, by.x = "recipient_county_code", by.y = "county_or_part")

#Calculate the spending column by multiping USAspending data by county-district breakdown, keep necessary columns, and write to file
va_benefits <- va_benefits %>%
  mutate(spending = federal_action_obligation * percent_cnty_total) %>%
  select(all_of(dp_final_cols))

write.csv(va_benefits, file.path(temp_path, paste0(f_year, clean_v_data)), row.names = F)