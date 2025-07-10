#Code for creating a file to help apportion VA direct payments across counties and districts

districts_vets$county_or_part <- as.numeric(districts_vets$county_or_part)
districts_vets <- rename(districts_vets, dist_vets = B21001_002E)
counties_vets$county <- as.numeric(counties_vets$county)
counties_vets <- rename(counties_vets, cnty_vets = B21001_002E)

result <- merge(x=districts_vets, y=counties_vets, by.x="county_or_part", by.y="county", x.all=FALSE, y.all=FALSE)

#work on making new column and calculating % of county total next
result$percent_cnty_total <- with(result, (dist_vets/cnty_vets))

#drop not needed columns and export file as csv to 'output/folder'
result <- subset(result, select = c("county_or_part", "congressional_district", "percent_cnty_total")) 
write_csv(result, file.path(temp_path, paste0(f_year, vet_crosswalk)))
