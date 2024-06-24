##Master code for running MEIS analysis up until IMPLAN##

##Clear Environment##
rm(list = ls(all.names = TRUE))

##Load Libraries##
library(httr)
library(jsonlite)
library(openxlsx)
library(readxl)
library(tidyverse)
library(censusapi)
library(xml2)

##Load Parameters##
source("parameters.R")

##Load Function Scripts##
source("src/filter_usaspending.R")
source("src/contract_check.R")
source("src/t1_error_check.R")
source("src/concatenate_usaspending.R")
source("src/split_usaspending.R")
source("src/aggregate_usaspending.R")

##Load API obtaining data scripts##
#source("src/obtain_usaspending.R")
source("src/census_api_call.R")

##Make VA Apportioning File##
#source("src/make_va_benefits_cw.R")

##Load in USASpending.gov Data##
cfile_name <- list.files(path = temp_path, pattern = paste0(c_label, ".+\\.csv"))
gfile_name <- list.files(path = temp_path, pattern = paste0(g_label, ".+\\.csv"))

##Filter USAspending data##
filter_usaspending(cfile_name, state, contract_columns, paste0(f_year, all_c_data))
filter_usaspending(gfile_name, state, grant_columns, paste0(f_year, all_g_data))

##Run error check on USAspending data##
#CONTRACTS#
source("src/error_check_contracts.R")

#Run tier 1 check on contracts data to pull out cleaned contracts entries into file
contracts <- t1_check(contracts, file.path(temp_path, paste0(f_year, clean_c_data)), file.path(output_path, paste0(f_year, contract_errors)))
rm(contracts, naics2implan, naics2naics07, naics2naics17)

#Run R scripts parts 1 and 2, and do subsequent t1 checks, to fill in missing district values and reduce contract errors file
source("src/check_contract_district_part1.R")
error_contracts <- t1_check(error_contracts, file.path(temp_path, paste0(f_year, clean_c_data)), file.path(output_path, paste0(f_year, contract_errors)))

source("src/check_contract_district_part2.R")
error_contracts <- t1_check(error_contracts, file.path(temp_path, paste0(f_year, clean_c_data)), file.path(output_path, paste0(f_year, contract_errors)))
rm(clean_contracts, error_contracts, error_cont_biz, zip_dist_cw)


#GRANTS#
source("src/error_check_grants.R")
grants <- t1_check(grants, file.path(temp_path, paste0(f_year, clean_g_data)), file.path(output_path, paste0(f_year, grant_errors)))
rm(grants, btype2implan)

##Repair and weight contracts, grants, and direct payment data##
#CONTRACTS#
##First go through and manually fix contract errors file, and then run it through the T1 check again
manual_fixes_c <- read.csv(file.path(output_path, paste0(f_year, contract_errors)))
manual_fixes_c <- t1_check(manual_fixes_c, file.path(temp_path, paste0(f_year, clean_c_data)), file.path(output_path, paste0(f_year, contract_errors)))

#YOU CAN REPEAT THE 2 LINES OF CODE ABOVE OVER AND OVER AGAIN TO REPAIR AS MANY ERRORS AS YOU LIKE

#Run script to fix and weigh contracts
source("src/repair_and_weight_contracts.R")
rm(clean_contracts)


#GRANTS#
##First go through and manually fix grant errors file, and then run it through the T1 check again.
manual_fixes_g <- read.csv(file.path(output_path, paste0(f_year, grant_errors)))
manual_fixes_g <- t1_check(manual_fixes_g, file.path(temp_path, paste0(f_year, clean_g_data)), file.path(output_path, paste0(f_year, grant_errors)))

#YOU CAN REPEAT THE 2 LINES OF CODE ABOVE OVER AND OVER AGAIN TO REPAIR AS MANY ERRORS AS YOU LIKE

#Run script to fix and weigh grants
source("src/repair_and_weight_grants.R")
rm(clean_grants)


#VA DIRECT PAYMENTS#
source("src/repair_and_weight_direct_payments.R")
rm(vet_cw)

##Run concatenate function to combine usaspending contracts and grants data into one dataframe, and write into CSV##
concat_files <- concat_usaspending(pattern = paste0(f_year, "_cleaned.+\\.csv"))
write.csv(concat_files, file.path(temp_path, paste0(f_year, concat_u_data)), row.names = FALSE)


## PLACEHOLDER: RUN CODE TO FIX IMPLAN CODE ERRORS FOUND VIA RUNNING IMPLAN MODELS ##


##Load in concatenated spending file from temp folder as variable for splitting out DOE from DOD/DHS/VA concatenated usaspending##
ufile_name <- list.files(path = temp_path, pattern = paste0(f_year, concat_u_data))

usaspending <- split_usaspending(ufile_name, FALSE)
doespending <- split_usaspending(ufile_name, TRUE)

##Load an R script that filters the DOE spending to only national security-related data##
source("src/natsec_doe.R")

##Aggregate the DOD/DHS/VA USAspending, DOE spending, and VA benefits## 
#this gives you all the statewide spending info for the  DHS/DOD/VA IMPLAN activity sheet and the DOE IMPLAN activity sheet, as well as VA benefits at the state, county, and district level (for the Household Spending tab in the IMPLAN activity sheet)
statewide_aggregate(usaspending, (paste0(f_year, agg_state_u_data)))
statewide_aggregate(doe_ns_spending, (paste0(f_year, agg_state_doe_data)))

va_benefits_stateagg <- sum(va_benefits$spending)
va_benefits_countiesagg <- aggregate(va_benefits$spending, by=list(va_benefits$recipient_county_name), FUN = sum)
va_benefits_districtsagg <- aggregate(va_benefits$spending, by=list(va_benefits$congressional_district), FUN = sum)

##Load R script that provides employment calculations at statewide, county, and congressional district levels##
source("src/generate_employment_dataframe.R")

##Run for loop code to get IMPLAN activity sheets generated for counties and districts##
source("src/create_implan_sheets.R")

##Don't forget to insert code to empty temp folder except for "/data/temp/placeholderfortemp.txt"##