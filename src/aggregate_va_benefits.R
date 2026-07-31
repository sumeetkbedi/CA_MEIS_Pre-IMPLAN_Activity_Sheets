##Code to aggregate the cleaned VA benefits data for statewide, county, and district totals##

#Read in cleaned va benefits data
va_benefits <- read.csv(file.path(temp_path, paste0(f_year, clean_v_data)))

#Statewide aggregation
va_benefits_stateagg <- sum(va_benefits$spending)
print(va_benefits_stateagg)

#County and district aggregation
va_benefits_countiesagg <- va_benefits %>%
  rename(county = recipient_county_name) %>%
  group_by(county) %>%
  summarize(spending = sum(spending)) %>%
  filter(!is.na(spending) & spending != 0)

va_benefits_districtsagg <- va_benefits %>%
  rename(district = congressional_district) %>%
  group_by(district) %>%
  summarize(spending = sum(spending)) %>%
  filter(!is.na(spending) & spending != 0)