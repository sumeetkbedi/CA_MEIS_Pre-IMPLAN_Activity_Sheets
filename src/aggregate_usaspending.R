#Defines function "statewide_aggregate" for aggregating USAspending and DOE spending data into each IMPLAN code for the state

statewide_aggregate <- function(dataframe, out_name) {
  dataframe  <- aggregate(dataframe$spending, by=list(dataframe$implan_code), FUN = "sum") %>%
    write.csv(file.path(temp_path, out_name), row.names = F)
}