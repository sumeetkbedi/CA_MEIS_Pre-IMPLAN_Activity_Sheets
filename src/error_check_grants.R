##GRANTS DATA - read in CSV file and fix the congressional district and county fips code columns
grants <- read.csv(file.path(temp_path, paste0(f_year, all_g_data)))

grants <- grants %>%
  rename("recipient_county_code" = prime_award_transaction_recipient_county_fips_code,
         "recipient_congressional_district" = prime_award_transaction_recipient_cd_current)

grants$recipient_county_code <- as.numeric(substring(grants$recipient_county_code, 2))
grants$recipient_congressional_district <- gsub("CA-", "", grants$recipient_congressional_district) %>%
  as.numeric(grants$recipient_congressional_district)

#Now read in the business type to IMPLAN crosswalk - this will help us assign IMPLAN codes to grants
btype2implan <- read.csv(file.path(raw_path, paste0(btype_crosswalk)), fileEncoding = "UTF-8-BOM")

#Prior to running crosswalk, pull out the VA direct payments/benefits data - this does not get matched to an IMPLAN code - and write into CSV file
va_benefits <- grants %>%
  filter(assistance_type_code == 10 | assistance_type_code == 6,
         awarding_agency_name == "Department of Veterans Affairs")
grants <- grants %>%
  filter(!(assistance_type_code == 10 | assistance_type_code == 6))

#write.csv(va_benefits, file.path(temp_path, paste0(f_year, va_ben_data)), row.names = F)

#Merge crosswalk to grants data so that IMPLAN code column is paired to grants
grants <- merge(grants, btype2implan, by = ("business_types_description"), all.x = T, all.y = F)

#Fix issues with special characters in grants' award description column, and then run the tier 1 check function on grants
grants$transaction_description <- gsub("/","",
                                 gsub(",","",
                                      gsub(r"(\\)","",
                                           gsub('"',"", as.character(grants$transaction_description)))))