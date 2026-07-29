#R script to appropriately calculate contract spending for entries with multiple IMPLAN codes
#Read in CSV of cleaned contracts data
clean_contracts <- read.csv(file.path(temp_path, paste0(f_year, clean_c_data)))

#Modify the CewAvgRatio column so any NA values are just 1
clean_contracts$Ratio[is.na(clean_contracts$Ratio)] <- 1

#Multiply USAspending data by CewAvgRatio column to get the weighted spending data, keep necessary columns, and write to file
clean_contracts <- clean_contracts %>%
  mutate(spending = federal_action_obligation * Ratio) %>%
  select(all_of(final_cols))

write.csv(clean_contracts, file.path(temp_path, paste0(f_year, clean_c_data)), row.names = F)