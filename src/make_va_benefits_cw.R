#Code for creating a file to help apportion VA direct payments across counties and districts

#Clean up the counties and districts veterans dataframes, and merge them together
districts_vets <- districts_vets %>%
  mutate(county_or_part = as.numeric(county_or_part)) %>%
  rename(dist_vets = B21001_002E)

counties_vets <- counties_vets %>%
  mutate(county = as.numeric(county)) %>%
  rename(cnty_vets = B21001_002E)

result <- merge(districts_vets, counties_vets, by.x = "county_or_part", by.y = "county", x.all= F, y.all= F)

#Make a column calculating the portion of a county's total veterans in a district, and select needed columns
result <- result %>%
  mutate(percent_cnty_total = dist_vets / cnty_vets) %>%
  select(county_or_part, congressional_district, percent_cnty_total)

#Export file as csv to temp data folder
write_csv(result, file.path(temp_path, paste0(f_year, vet_crosswalk)))