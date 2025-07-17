##CONTRACTS DATA - read in CSV
contracts <- read.csv(file.path(temp_path, paste0(f_year, all_c_data)))

#Read in the NAICS to NAICS crosswalks that update 2007 and 2017 NAICS for 2022
naics2naics07 <- read.xlsx(file.path(raw_path, naics_crosswalk07))
naics2naics17 <- read.xlsx(file.path(raw_path, naics_crosswalk17))

#Rewrite the 2007 and 2017 NAICS codes in the contracts dataframe by matching it to those in the crosswalk dataframes
for (i in 1:nrow(naics2naics07)) {
  contracts$naics_code[grep(naics2naics07$`2007_NAICS`[i],contracts$naics_code)] <- naics2naics07$`2022_NAICS`[i]
}

for (i in 1:nrow(naics2naics17)) {
  contracts$naics_code[grep(naics2naics17$`2017_NAICS`[i],contracts$naics_code)] <- naics2naics17$`2022_NAICS`[i]
}

#Now load in the NAICS to IMPLAN crosswalk and merge to contracts - this will assign contracts entries to their appropriate IMPLAN code based on 2012 and 2017 NAICS codes
naics2implan <- read.xlsx(file.path(raw_path, implan_crosswalk))
naics2implan <- naics2implan %>%
  rename(naics_code = "NaicsCode", implan_code = "Implan528Index") %>%
  distinct(naics_code, implan_code, .keep_all = T)

contracts <- merge(contracts, naics2implan, by = ("naics_code"), all.x = T, all.y = F)

#Next, hard code any contract entries with a NAICS code starting with 236118 and 92 to IMPLAN codes 56 and 510
contracts$implan_code[startsWith(as.character(contracts$naics_code), "92")] <- "510"
contracts$implan_code[startsWith(as.character(contracts$naics_code), "236118")] <- "56"

#Define index for construction contracts entries with NAICS 237310 - they need to be specifically fixed before moving forward
constr_ind_237310 <- which(contracts$naics_code == "237310" & is.na(contracts$implan_code))

#Pull out construction contracts with NAICS code 237310 and apply their specific fix using 2 word searches with contract_check function
construction_contracts_237310 <- contracts[constr_ind_237310,]
contracts <- contracts[-constr_ind_237310,]

construction_contracts_test1 <- construction_contracts_237310[contract_check(patterns = repair_implan_55, data = construction_contracts_237310$transaction_description),]
construction_contracts_237310 <- construction_contracts_237310[!(contract_check(patterns = repair_implan_55, data = construction_contracts_237310$transaction_description)),]

construction_contracts_test2 <- construction_contracts_test1[contract_check(patterns = aircraft_implan_55, data = construction_contracts_test1$transaction_description),]
construction_contracts_test2$implan_code <- 55
construction_contracts_test1 <- construction_contracts_test1[!(contract_check(patterns = aircraft_implan_55, data = construction_contracts_test1$transaction_description)),]
construction_contracts_test1$implan_code <- 57

#Pull out the remaining construction contracts into its own dataframe, and drop from the main contracts dataframe
constr_ind <- which(substr(contracts$naics_code,1,2) == "23" & is.na(contracts$implan_code))
construction_contracts <- contracts[constr_ind,]
contracts <- contracts[-constr_ind,]

#Run the IMPLAN code 55 word search on the construction contracts - this will assign IMPLAN code 55 to contracts based on their award description
implan_55_contracts <- construction_contracts[contract_check(patterns = repair_implan_55, data = construction_contracts$transaction_description),]
implan_55_contracts$implan_code <- 55

construction_contracts <- construction_contracts[!(contract_check(patterns = repair_implan_55, data = construction_contracts$transaction_description)),]

#Run one more word search to identify construction contracts that are deemed new and set to IMPLAN code 51
implan_51_contracts <- construction_contracts[contract_check(patterns = new_implan_51, data = construction_contracts$transaction_description),]
implan_51_contracts$implan_code <- 51

construction_contracts <- construction_contracts[!(contract_check(patterns = new_implan_51, data = construction_contracts$transaction_description)),]

#Bring back all these dataframes into the main contracts dataframe, and then drop the separate dataframes from environment
contracts_list <- list(contracts, construction_contracts_237310, construction_contracts_test1, construction_contracts_test2,
                       implan_55_contracts, implan_51_contracts, construction_contracts)
contracts <- Reduce(function(x,y) merge(x, y, all=TRUE), contracts_list)

rm(construction_contracts_237310, construction_contracts_test1, construction_contracts_test2,
   implan_55_contracts, implan_51_contracts, construction_contracts, contracts_list)

#Fix issues with special characters in contracts' award description column, and then run the tier 1 check function on contracts
contracts$transaction_description <- gsub("/","",
                                    gsub(",","",
                                         gsub(r"(\\)","",
                                              gsub("\"","",
                                                   gsub('"',"", as.character(contracts$transaction_description))))))

contracts$recipient_name <- gsub("[()]", "", as.character(contracts$recipient_name))

contracts$recipient_county_name[contracts$recipient_county_name == ""] <- NA

contracts$prime_award_transaction_recipient_cd_current <- gsub("CA-", "", contracts$prime_award_transaction_recipient_cd_current) %>%
  as.numeric(contracts$prime_award_transaction_recipient_cd_current)

contracts <- contracts %>%
  rename("recipient_congressional_district" = prime_award_transaction_recipient_cd_current)