##EMPLOYMENT CALCULATIONS FOR NATIONAL SECURITY MILITARY AND CIVLIAN EMPLOYEES##

##Read in CSV file that contains statewide employment numbers, and define the values for statewide military, civilian, and DOE employees
#NOTE: Be sure to go into this file and appropriately edit the numbers for your state of interest
##NOTE 2: be sure that you have ran line 28 - the census API call. otherwise, military employment proportion will not work

state_emp <- read.csv(file.path(raw_path, paste0(state,"_emp.csv")), fileEncoding="UTF-8-BOM")

mili_emp = state_emp[1,1] + (state_emp[1,2] * res_mult)
dod_emp = sum(state_emp[1,5:8])
dhs_emp = state_emp[1,3] + ca_dhs_sup
va_emp = state_emp[1,4]
civilian_emp = dod_emp + dhs_emp + va_emp
doe_emp = state_emp[1,9] * doe_ns_adjustment

##Begin apportioning military and civilian employment by county and district, sectioning off based on employment type##
##Start out with military employment - use districts_armedforces and counties_armedforces dataframes from Census API call

#COUNTY
counties_armedforces <- counties_armedforces[c("NAME", "B23025_006E")]
colnames(counties_armedforces) <- c("county", "armed_forces")
counties_armedforces$county <- gsub(' County, California', "", counties_armedforces$county)
counties_armedforces$county <- toupper(counties_armedforces$county)

mili_county <- counties_armedforces %>%
  mutate(af_perc = counties_armedforces$armed_forces / sum(counties_armedforces$armed_forces),
         mili_emp = mili_emp * af_perc) %>%
  select(county, mili_emp)

#DISTRICT
districts_armedforces <- districts_armedforces[c("congressional_district", "B23025_006E")]
districts_armedforces$congressional_district <- as.numeric(districts_armedforces$congressional_district)
districts_armedforces <- aggregate(districts_armedforces$B23025_006E, by = list(districts_armedforces$congressional_district), FUN = sum)
colnames(districts_armedforces) <- c("district", "armed_forces")

mili_district <- districts_armedforces %>%
  mutate(af_perc = districts_armedforces$armed_forces / sum(districts_armedforces$armed_forces),
         mili_emp = mili_emp * af_perc) %>%
  select(district, mili_emp)


##Next is DOD civilian employment - use DOD County Shares Excel file##
dod_shares_county <- read_excel(file.path(raw_path, dod_shares), sheet = 1)
dod_shares_district <- read_excel(file.path(raw_path, dod_shares), sheet = 2)

#Start out by calculating DOD employment by county - multiply the county share percentage by the statewide DOD employees to get each county's DOD employees
dod_county <- dod_shares_county %>%
  mutate("dod_emp" = dod_shares_county$Share * dod_emp) %>%
  select("geography", "dod_emp")

#Use the dod_county values to calculate the DOD employment by district. Multiply the DOD county_employees by each district's share of a county, and aggregate by district to get our total amount of DOD civilian employees per district
dod_district <- merge(dod_county, dod_shares_district)

dod_district <- dod_district %>%
  mutate("dod_emp" = dod_district$dod_emp * dod_district$`%`) %>%
  select(District, dod_emp)
dod_district <- aggregate(dod_district, by = list(dod_district$District), FUN = sum) %>%
  select("Group.1", "dod_emp") %>%
  rename(district = "Group.1")

dod_county <- dod_county %>%
  rename(county = "geography")


##Last employment data to localize is VA and DHS employment - read in dhs_va_foia_emp.csv file##
##REFER TO DOCUMENTATION FOR GUIDANCE ON HOW TO LOCALIZE THIS DATA##
dhs_va_county <- read.xlsx(file.path(raw_path, paste0(f_year, dhs_va_foia_data)), sheet = 1)
dhs_va_district <- read.xlsx(file.path(raw_path, paste0(f_year, dhs_va_foia_data)), sheet = 2)

#Add in the suppressed DHS employees - first get the percentage of DHS employees in each county/district within the state
dhs_va_county <- dhs_va_county %>%
  mutate(dhs_perc = dhs_emp / sum(dhs_emp))
dhs_va_district <- dhs_va_district %>%
  mutate(dhs_perc = dhs_emp / sum(dhs_emp))

#Now multiply the total state suppressed DHS employees by dhs_perc to get suppressed employees per county/district
dhs_va_county <- dhs_va_county %>%
  mutate(dhs_sup = dhs_perc * ca_dhs_sup)
dhs_va_district <- dhs_va_district %>%
  mutate(dhs_sup = dhs_perc * ca_dhs_sup)

#Last, add the suppressed employees to dhs_emp to get the total DHS employees for each county and district. Drop unneeded columns
dhs_va_county <- dhs_va_county %>%
  mutate(dhs_emp = dhs_emp + dhs_sup) %>%
  select(county, dhs_emp, va_emp)
dhs_va_district <- dhs_va_district %>%
  mutate(dhs_emp = dhs_emp + dhs_sup) %>%
  select(district, dhs_emp, va_emp)


##Merge the county employee dataframes into one dataframe, and the district employee dataframes into a second dataframe. Make sure all values are numeric, and replace NAs with 0s.
county_emp <- Reduce(function(x,y) merge(x = x, y = y, by = "county", all = TRUE), list(dhs_va_county, dod_county, mili_county))
county_emp[is.na(county_emp)] <- 0

district_emp <- Reduce(function(x,y) merge(x = x, y = y, by = "district", all = TRUE), list(dhs_va_district, dod_district, mili_district))
district_emp[is.na(district_emp)] <- 0


##Final step: add columns needed in the for loop code to generate activity sheets##
county_emp <- county_emp %>%
  mutate(implan_545 = mili_emp,
         implan_546 = (dhs_emp+va_emp+dod_emp),
         inverse_545 = (sum(mili_emp) - mili_emp),
         inverse_546 = (sum(implan_546) - implan_546))

district_emp <- district_emp %>%
  mutate(implan_545 = mili_emp,
         implan_546 = (dhs_emp+va_emp+dod_emp))

#EXTRA: Code for grabbing county and district employment used in mastersheets#
#county_emp <- county_emp %>%
#  rename("civil_emp" = implan_546) %>%
#  mutate(total_emp = mili_emp + civil_emp) %>%
#  select(-c(implan_545, inverse_545, inverse_546))

#district_emp <- district_emp %>%
#  rename("civil_emp" = implan_546) %>%
#  mutate(total_emp = mili_emp + civil_emp) %>%
#  select(-c(implan_545))

#emp_list <- list("counties" = county_emp, "districts" = district_emp)
#write.xlsx(emp_list, file.path(temp_path, paste0(f_year, "_direct_employment.xlsx")), row.names = F)