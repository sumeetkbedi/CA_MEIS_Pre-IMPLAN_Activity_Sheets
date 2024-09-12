#This file stores parameters for the master analysis script. 
#Comment out parameters that are not needed. 
#For specific instructions on how to use this file, see README.md

##General Global Variables##
f_year = "2023" #Fiscal year of target data 
year = "2024" #Report output year
state = "CALIFORNIA" #Target state for report, used for naming conventions

#General Paths to Folders
output_path = file.path("output")
temp_path = file.path("data", "temp")
raw_path = file.path("data", "raw")
err_check_path = file.path("Error_Check_Data")

##USAspending.gov API Variables##

##THE FOLLOWING FILTERS ARE MANDATORY AND MUST HAVE A VALID VALUE FOR THE SCRIPT TO RUN

agency_type = c("awarding", "awarding", "awarding", "awarding")
agency_tier = c("toptier", "toptier", "toptier", "toptier")
agency_name = c("Department of Homeland Security", "Department of Defense", "Department of Veterans Affairs", "Department of Energy")
#tier_name = 

date_type = "action_date"

date_range_start = "2022-10-01"
date_range_end = "2023-09-30"

##The following filters are OPTIONAL - comment out the line if you do not require a filter
#select award types to apply to filter
awards = c("A", "B", "C", "D", "02", "03", "04", "05", "06", "10")

#select Location filters, at minimum location_country MUST have a valid entry to use the location filter 
#Cannot use 'location_county' and 'location_district' in the same query, must pick one or the other
recipient_locations_country = c("USA")

#recipient_locations_state = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")
#recipient_locations_state = c("CA")

#recipient_locations_county = c()
#recipient_locations_district = c() 

##census_api_call variables##
c_key = "8df2ad0b1d54d9a4a19c1d97bed2e94e44995571" #DELETE BEFORE POSTING TO GITHUB!!!
state_fips = "06"
dist_list = "01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52" 
c_year = 2022


##make_va_benefits_cw variables##
vet_crosswalk <- "_va_apportioning.csv"


##filter_usaspending variables##
contract_columns = c("federal_action_obligation", "awarding_agency_name", "awarding_sub_agency_name", "transaction_description", "funding_office_name", "recipient_name", "recipient_county_name", "prime_award_transaction_recipient_cd_current", "recipient_zip_4_code", "naics_code")
grant_columns = c("federal_action_obligation", "awarding_agency_name", "awarding_sub_agency_name", "transaction_description", "funding_office_name", "recipient_name", "prime_award_transaction_recipient_county_fips_code", "recipient_county_name", "prime_award_transaction_recipient_cd_current", "recipient_zip_code", "recipient_zip_last_4_code", "assistance_type_code", "business_types_description")

c_label <- "Contracts"
g_label <- "Assistance"

all_c_data = "_all_contract_spending.csv"
all_g_data = "_all_grant_spending.csv"


##contract_check variables##
repair_implan_60 <- c("repair", "rpr", "maint", "renovat", "replac", "inspect", "install", "restor", "reroof", "re-roof", "reshingle", "re-shingle", 
               "service", "upgrade", "retrofit", "remov", "ratif", "relocat", "modif", "modern", "clean", "convert", "change", "alter", "repaint",
               "re-paint", "remediat", "repav", "re-pav", "abate", "adjust", "annual", "test", "rehab", "realign", "remodel", "improv", "broke", "expans",
               "revis", "restrip", "substit", "patch", "dredg", "resurfac", "outdat", "reconfig", "refurb", "rerout", "replen", "troubleshoot",
               "correct", "updat", "treatment", "quarterly", "yearly")

aircraft_implan_60 <- c("aircraft", "carrier", "airplane", "airfield", "taxiway", "runway")

new_implan_56 <- c("construct", "rebuild")


##error_check_contracts variables##
naics_crosswalk07 <- "2007_to_2022_NAICS.xlsx"
naics_crosswalk17 <- "2017_to_2022_NAICS.xlsx"
implan_crosswalk <- "2022_NAICS_to_IMPLAN.xlsx"

clean_c_data = "_cleaned_contracts.csv"
contract_errors <- "_contract_errors.csv"


##check_contract_district_part2 variables## 
ziplook_url = "https://ziplook.house.gov/htbin/ziplook_find?"
zip_dist_crosswalk = "_zip_code_to_district_crosswalk.csv"


##error_check_grants variables##
btype_crosswalk <- "business_type_to_implan546_crosswalk.csv"
clean_g_data = "_cleaned_grants.csv"
grant_errors <- "_grant_errors.csv"


##repair_and_weight contracts and grants variable##
final_cols = c("spending", "awarding_agency_name", "funding_office_name", "recipient_county_name",
         "recipient_congressional_district", "implan_code")


##repair_and_weight_direct_payments variable##
clean_v_data = "_cleaned_va_benefits.csv"


##concatenate_usaspending variables##
concat_u_data = "_concatenated_usaspending.csv"


##split_usaspending variables##
doe = "Department of Energy"


##natsec_doe variables##
doe_offices = c("526 ICBMSW", "ACCTG DISB STA NR 503000", "COMMANDER SUBMARINE FORCE",
                "DEF ADVANCED RESEARCH PROJECTS AGCY", "DEPT OF COMMERCE NIST", "DOD SUPPLY ACTIVITY",
                "EM-ENVIRONMENTAL MGMT CON BUS CTR", "F59900 SAF FMBIB'", "IDAHO OPERATIONS OFFICE",
                "MISSILE DEFENSE AGENCY", "MISSILE DEFENSE AGENCY (MDA)", "NASA MARSHALL SPACE FLIGHT CENTER",
                "NNSA M&O CONTRACTING", "NNSA NAVAL REACTORS LAB FLD OFFICE", "NNSA NON-M&O CNTRACTING OPS DIV",
                "NNSA OFFICE OF THE ADMIN FUNDS", "NNSA OTHER FUNDS", "NNSA WEAPONS ACTIVITIES FUNDS",
                "NNSA-DEFENSE NUCLEAR NONPRO FUNDS", "OFFICE OF NAVAL RESEARCH")


##aggregate_usaspending variables##
agg_state_u_data = "_aggregated_usaspending_statewide.csv"
agg_state_doe_data = "_aggregated_doespending_statewide.csv"


##generate_employment_dataframe Variables##
res_mult = 0.1825
national_sus_dhs = 148016
sus_dhs_mult = 0.142144789590548
ca_dhs_sup = national_sus_dhs * sus_dhs_mult

dod_shares = "dod_county_shares.xlsx"
dhs_va_foia_data = "_dhs_va_foia_emp.xlsx"


##create_implan_sheets variables##
blank_sheets = "Blank_Sheets_for_R"