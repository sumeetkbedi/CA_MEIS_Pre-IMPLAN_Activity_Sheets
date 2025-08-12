#Defines function "split_usaspending" For pulling DOE data out of specified file/dataframe

split_usaspending <- function(file_name, is_doe) {
  usa_spending_data <- read.csv(file.path(temp_path, file_name))
  if(is_doe) {
    filter(usa_spending_data, awarding_agency_name == doe)
  }
    else {
      filter(usa_spending_data, awarding_agency_name != doe)
    }
}