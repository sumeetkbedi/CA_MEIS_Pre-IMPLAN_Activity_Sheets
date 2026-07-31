##EMPLOYMENT CALCULATIONS FOR NATIONAL SECURITY MILITARY AND CIVLIAN EMPLOYEES##

##Read in CSV file that contains statewide employment numbers, and define the values for statewide military, civilian, and DOE employees
#NOTE: Be sure to appropriately edit numbers in raw data employment file for your state of interest
##NOTE 2: be sure that you have ran line 28 (the census API call.) otherwise, military employment proportion will not work

state_emp <- read.csv(file.path(raw_path, paste0(state,"_emp.csv")), fileEncoding="UTF-8-BOM")

state_emp_mili = state_emp[1,1] + (state_emp[1,2] * res_mult)
state_emp_dod = sum(state_emp[1,5:8])
state_emp_dhs = state_emp[1,3]
state_emp_va = state_emp[1,4]
state_emp_civilian = state_dod_emp + state_dhs_emp + state_va_emp
state_emp_doe = state_emp[1,9] * doe_ns_adjustment

##Begin apportioning employment data by county and district, sectioning off based on employment type##
##Military employment - use districts_armedforces and counties_armedforces dataframes from Census API call

#COUNTY
counties_armedforces <- counties_armedforces[c("NAME", "B23025_006E")]
colnames(counties_armedforces) <- c("county", "armed_forces")
counties_armedforces$county <- gsub(' County, California', "", counties_armedforces$county)
counties_armedforces$county <- toupper(counties_armedforces$county)

mili_county <- counties_armedforces %>%
  mutate(af_perc = counties_armedforces$armed_forces / sum(counties_armedforces$armed_forces),
         mili_emp = state_emp_mili * af_perc) %>%
  select(county, mili_emp)

#DISTRICT
districts_armedforces <- districts_armedforces[c("congressional_district", "B23025_006E")]
districts_armedforces <- districts_armedforces %>%
  rename(district = congressional_district, armed_forces = B23025_006E) %>%
  mutate(district = as.numeric(district)) %>%
  group_by(district) %>%
  summarize(armed_forces = sum(armed_forces))

mili_district <- districts_armedforces %>%
  mutate(af_perc = districts_armedforces$armed_forces / sum(districts_armedforces$armed_forces),
         mili_emp = state_emp_mili * af_perc) %>%
  select(district, mili_emp)


##DOD civilian employment - use DOD County Shares Excel file##
dod_shares_county <- read.xlsx(file.path(raw_path, dod_shares), sheet = 1)
dod_shares_district <- read.xlsx(file.path(raw_path, dod_shares), sheet = 2)

#COUNTY - multiply the county share percentage by the statewide DOD employees to get each county's DOD employees
dod_county <- dod_shares_county %>%
  mutate(dod_emp = dod_shares_county$Share * state_emp_dod) %>%
  select(geography, dod_emp)

#DISTRICT - Multiply the dod_emp value for counties by each district's share of a county, and aggregate by district to get total DOD civilian employees per district
dod_district <- merge(dod_county, dod_shares_district)

dod_district <- dod_district %>%
  mutate(dod_emp = dod_district$dod_emp * dod_district$`%`) %>%
  select(District, dod_emp) %>%
  rename(district = District) %>%
  group_by(district) %>%
  summarize(dod_emp = sum(dod_emp))

dod_county <- dod_county %>%
  rename(county = "geography")


##Last employment data to localize is VA and DHS employment - read in dhs_va_foia_emp.csv file##
##REFER TO DOCUMENTATION FOR GUIDANCE ON HOW TO LOCALIZE THIS DATA##
dhs_va_county <- read.xlsx(file.path(raw_path, paste0(f_year, dhs_va_foia_data)), sheet = 1)
dhs_va_district <- read.xlsx(file.path(raw_path, paste0(f_year, dhs_va_foia_data)), sheet = 2)


##Merge the county employee dataframes into one dataframe, and the district employee dataframes into a second dataframe. Make sure all values are numeric, and replace NAs with 0s.
county_emp <- Reduce(function(x,y) merge(x = x, y = y, by = "county", all = T), list(dhs_va_county, dod_county, mili_county))
county_emp[is.na(county_emp)] <- 0

district_emp <- Reduce(function(x,y) merge(x = x, y = y, by = "district", all = T), list(dhs_va_district, dod_district, mili_district))
district_emp[is.na(district_emp)] <- 0


##Final step: add columns needed in the for loop code to generate activity sheets##
county_emp <- county_emp %>%
  mutate(implan_527 = mili_emp,
         implan_528 = (dhs_emp+va_emp+dod_emp),
         inverse_527 = (sum(mili_emp) - mili_emp),
         inverse_528 = (sum(implan_528) - implan_528))

district_emp <- district_emp %>%
  mutate(implan_527 = mili_emp,
         implan_528 = (dhs_emp+va_emp+dod_emp))

#EXTRA: Code for grabbing county and district employment used in mastersheets#
#county_emp <- county_emp %>%
#  rename("civil_emp" = implan_528) %>%
#  mutate(total_emp = mili_emp + civil_emp) %>%
#  select(-c(implan_527, inverse_527, inverse_528))

#district_emp <- district_emp %>%
#  rename("civil_emp" = implan_528) %>%
#  mutate(total_emp = mili_emp + civil_emp) %>%
#  select(-c(implan_527))

#emp_list <- list("counties" = county_emp, "districts" = district_emp)
#write.xlsx(emp_list, file.path(temp_path, paste0(f_year, "_direct_employment.xlsx")), row.names = F)